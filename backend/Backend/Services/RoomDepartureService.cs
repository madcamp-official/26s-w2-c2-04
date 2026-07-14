using System.Text.Json;
using Backend.Data;
using Backend.Endpoints;
using Backend.GameLogic;
using Backend.Hubs;
using Backend.Models;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services;

/// <summary>
/// 로그아웃/연결 끊김/명시적 나가기를 하나의 이탈 처리로 모으는 공용 로직.
/// Hub 안(IHubCallerClients)과 REST/백그라운드 워커(IHubContext.Clients) 양쪽에서
/// 같은 코드로 부를 수 있도록 IHubClients를 받는다.
/// </summary>
public static class RoomDepartureService
{
    private const int GracePeriodSeconds = 60;

    /// <summary>
    /// 로그아웃/연결 끊김 공용 진입점. WAITING 방은 즉시 이탈 처리하고,
    /// PLAYING 방은 유예 상태로 표시만 해둔다(확정 처리는 RoomDepartureWorker가 함).
    /// </summary>
    public static async Task HandleUserGoingOfflineAsync(
        AppDbContext db, GameStateStore stateStore, IHubClients<IClientProxy> gameHubClients,
        IHubClients<IClientProxy> socialHubClients, PresenceStore presence, int userId)
    {
        var memberships = await db.RoomPlayers
            .Include(p => p.Room).ThenInclude(r => r.Players)
            .Where(p => p.UserId == userId)
            .ToListAsync();

        foreach (var membership in memberships)
        {
            if (membership.Room.Status == RoomStatus.Waiting)
            {
                await FinalizePlayerDepartureAsync(db, stateStore, gameHubClients, socialHubClients, presence, membership.Room, membership);
            }
            else if (membership.DisconnectedAt is null)
            {
                membership.DisconnectedAt = DateTime.UtcNow;
                await gameHubClients.Group(GameHubMessages.GroupName(membership.RoomId))
                    .SendAsync("PlayerDisconnected", new { userId, graceSeconds = GracePeriodSeconds });
            }
        }

        await db.SaveChangesAsync();
    }

    /// <summary>
    /// 재접속 시 유예 상태를 취소한다. 유예 중이 아니었으면 아무 일도 안 한다.
    /// </summary>
    public static async Task CancelPendingDepartureAsync(
        AppDbContext db, IHubClients<IClientProxy> gameHubClients, RoomPlayer membership)
    {
        if (membership.DisconnectedAt is null)
            return;

        membership.DisconnectedAt = null;
        await db.SaveChangesAsync();
        await gameHubClients.Group(GameHubMessages.GroupName(membership.RoomId))
            .SendAsync("PlayerReconnected", new { userId = membership.UserId });
    }

    /// <summary>
    /// 방에서 실제로 제거하고(호스트 위임 포함), 알림을 보낸다. PLAYING 방이었으면 전원 탈주 여부도 확인한다.
    /// </summary>
    public static async Task FinalizePlayerDepartureAsync(
        AppDbContext db, GameStateStore stateStore, IHubClients<IClientProxy> gameHubClients,
        IHubClients<IClientProxy> socialHubClients, PresenceStore presence, Room room, RoomPlayer player)
    {
        var wasPlaying = room.Status == RoomStatus.Playing;
        var leavingUserId = player.UserId;
        var previousHostId = room.HostId;

        RoomEndpoints.LeaveRoom(db, room, player);
        await db.SaveChangesAsync();

        await presence.SetInGameAsync(leavingUserId, false);
        await SocialHub.BroadcastStatusAsync(db, presence, socialHubClients, leavingUserId);

        if (room.Players.Count == 0)
        {
            // 방 자체가 삭제됐다(Cascade로 Game도 이미 같이 삭제됨) - 남은 건 Redis에 걸린 상태 정리뿐.
            if (wasPlaying)
                await stateStore.RemoveAsync(room.Id);
            return;
        }

        var group = gameHubClients.Group(GameHubMessages.GroupName(room.Id));
        await group.SendAsync("PlayerLeft", new { userId = leavingUserId });
        if (room.HostId != previousHostId)
            await group.SendAsync("HostChanged", new { newHostId = room.HostId });

        if (wasPlaying)
            await CheckGameAbandonmentAsync(db, stateStore, gameHubClients, room, leavingUserId);
    }

    private static async Task CheckGameAbandonmentAsync(
        AppDbContext db, GameStateStore stateStore, IHubClients<IClientProxy> gameHubClients, Room room, int departedUserId)
    {
        if (room.Players.Count > 1)
        {
            await RemovePlayerFromGameAsync(db, stateStore, gameHubClients, room, departedUserId);
            return;
        }

        var winnerId = room.Players[0].UserId;
        var finalScores = await AbandonGameAsync(db, stateStore, room, winnerId);
        if (finalScores is null)
            return;

        await gameHubClients.Group(GameHubMessages.GroupName(room.Id)).SendAsync("GameOver", new
        {
            winnerId,
            finalScores = finalScores.Select(s => new { userId = s.PlayerId, score = s.Score }),
            reason = "abandoned",
        });
    }

    /// <summary>
    /// 부분 탈주(2명 이상 남음) 확정 시 게임 자체는 계속 진행하되, GameState에서도 그 플레이어를
    /// 완전히 제거해 다시는 그 사람 차례가 오지 않도록 한다.
    /// </summary>
    private static async Task RemovePlayerFromGameAsync(
        AppDbContext db, GameStateStore stateStore, IHubClients<IClientProxy> gameHubClients, Room room, int departedUserId)
    {
        await using var gameLock = await stateStore.AcquireLockAsync(room.Id);

        var state = await stateStore.LoadAsync(room.Id);
        if (state is null)
            return;

        var previousCurrentPlayerId = state.CurrentPlayerId;
        if (!GameEngine.RemovePlayer(state, departedUserId))
            return;

        await stateStore.SaveAsync(room.Id, state);

        var group = gameHubClients.Group(GameHubMessages.GroupName(room.Id));
        await group.SendAsync("StateSync", GameHubMessages.BuildFullSync(state));
        if (state.CurrentPlayerId != previousCurrentPlayerId)
            await group.SendAsync("TurnChanged", new { currentPlayerId = state.CurrentPlayerId, turnNumber = state.TurnNumber });
    }

    /// <summary>
    /// 진행 중이던 게임을 강제 종료하고, 남은 1인을 승자로 결과를 기록·랭킹에 반영한 뒤 방을 WAITING으로 되돌린다.
    /// 이미 종료 처리된 게임이면(경쟁 상황) null을 반환한다.
    /// </summary>
    private static async Task<IReadOnlyList<PlayerScore>?> AbandonGameAsync(
        AppDbContext db, GameStateStore stateStore, Room room, int winnerId)
    {
        await using var gameLock = await stateStore.AcquireLockAsync(room.Id);

        var state = await stateStore.LoadAsync(room.Id);
        var game = await db.Games.FirstOrDefaultAsync(g => g.RoomId == room.Id && g.Status == GameStatus.Playing);
        if (state is null || game is null)
            return null;

        var finalScores = state.PlayerOrder
            .OrderBy(id => id == winnerId ? 0 : 1)
            .ThenByDescending(id => state.Players[id].Points)
            .Select(id => new PlayerScore(id, state.Players[id].Points))
            .ToList();

        game.WinnerId = winnerId;
        game.StateJson = JsonSerializer.Serialize(state);
        await GameHub.RecordResultsAsync(db, game.Id, room, state, finalScores);

        game.Status = GameStatus.Finished;
        game.FinishedAt = DateTime.UtcNow;
        room.Status = RoomStatus.Waiting;

        await stateStore.RemoveAsync(room.Id);
        await db.SaveChangesAsync();

        return finalScores;
    }
}
