using Backend.Data;
using Backend.Hubs;
using Backend.Models;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services;

/// <summary>
/// 로그아웃/연결 끊김으로 PLAYING 방에서 유예 상태(RoomPlayer.DisconnectedAt)에 들어간 멤버를
/// 주기적으로 훑어, 1분 넘게 재접속하지 않았으면 확정적으로 방에서 내보낸다.
/// </summary>
public class RoomDepartureWorker(
    IServiceScopeFactory scopeFactory,
    GameStateStore stateStore,
    PresenceStore presence,
    IHubContext<GameHub> hubContext,
    IHubContext<SocialHub> socialHubContext,
    ILogger<RoomDepartureWorker> logger) : BackgroundService
{
    private static readonly TimeSpan GracePeriod = TimeSpan.FromSeconds(60);
    private static readonly TimeSpan TickInterval = TimeSpan.FromSeconds(5);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TickInterval);
        do
        {
            try
            {
                await ProcessExpiredDeparturesAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "방 이탈 유예 처리 중 오류");
            }

            try
            {
                await ProcessGhostMembersAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "유령 멤버 처리 중 오류");
            }
        } while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    private async Task ProcessExpiredDeparturesAsync(CancellationToken ct)
    {
        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var threshold = DateTime.UtcNow - GracePeriod;
        var expiredIds = await db.RoomPlayers
            .Where(p => p.DisconnectedAt != null && p.DisconnectedAt <= threshold)
            .Select(p => p.Id)
            .ToListAsync(ct);

        foreach (var id in expiredIds)
        {
            // 그 사이 재접속해 취소됐을 수 있으니 다시 조회해서 확인한다.
            var membership = await db.RoomPlayers
                .Include(p => p.Room).ThenInclude(r => r.Players)
                .FirstOrDefaultAsync(p => p.Id == id, ct);
            if (membership?.DisconnectedAt is null)
                continue;

            await RoomDepartureService.FinalizePlayerDepartureAsync(
                db, stateStore, hubContext.Clients, socialHubContext.Clients, presence, membership.Room, membership);
        }
    }

    /// <summary>
    /// 매칭 성사/방 참가 후 GameHub에 한 번도 연결하지 않은("유령") 멤버를 걸러낸다.
    /// 게임 시작 후 60초 넘게 지났는데 아직 JoinRoom을 한 번도 안 했고,
    /// 연결 끊김 유예(DisconnectedAt) 처리 중도 아닌 사람이 대상이다.
    /// </summary>
    private async Task ProcessGhostMembersAsync(CancellationToken ct)
    {
        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var threshold = DateTime.UtcNow - GracePeriod;
        var activeGames = await db.Games
            .Include(g => g.Room).ThenInclude(r => r.Players)
            .Where(g => g.Status == GameStatus.Playing && g.CreatedAt <= threshold)
            .ToListAsync(ct);

        foreach (var game in activeGames)
        {
            foreach (var player in game.Room.Players.Where(p => p.DisconnectedAt is null).ToList())
            {
                if (await stateStore.HasPlayerConnectedAsync(game.RoomId, player.UserId))
                    continue;

                await RoomDepartureService.FinalizePlayerDepartureAsync(
                    db, stateStore, hubContext.Clients, socialHubContext.Clients, presence, game.Room, player);
            }
        }
    }
}
