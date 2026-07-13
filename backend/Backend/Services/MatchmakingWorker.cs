using Backend.Data;
using Backend.Endpoints;
using Backend.GameLogic;
using Backend.Hubs;
using Backend.Models;
using Microsoft.AspNetCore.SignalR;

namespace Backend.Services;

/// <summary>
/// 랭킹전 대기열을 주기적으로 훑어 MMR이 비슷한 유저끼리 묶고, 정원이 차면 방을 만들어 바로 게임을 시작한다.
/// </summary>
public class MatchmakingWorker(
    IServiceScopeFactory scopeFactory,
    MatchmakingQueueStore queueStore,
    GameStateStore stateStore,
    IHubContext<GameHub> hubContext,
    ILogger<MatchmakingWorker> logger) : BackgroundService
{
    private static readonly int[] PlayerCounts = [2, 3, 4];
    private static readonly TimeSpan TickInterval = TimeSpan.FromSeconds(2);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TickInterval);
        do
        {
            foreach (var playerCount in PlayerCounts)
            {
                try
                {
                    await ProcessQueueAsync(playerCount, stoppingToken);
                }
                catch (Exception ex)
                {
                    logger.LogError(ex, "매치메이킹 큐 처리 중 오류 (playerCount={PlayerCount})", playerCount);
                }
            }
        } while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    private async Task ProcessQueueAsync(int playerCount, CancellationToken ct)
    {
        var entries = await queueStore.GetAllAsync(playerCount);
        if (entries.Count < playerCount)
            return;

        await using var matchLock = await queueStore.TryAcquireLockAsync(playerCount);
        if (matchLock is null)
            return;

        // 락을 잡는 사이 다른 인스턴스가 이미 처리했을 수 있으니 최신 상태로 다시 읽는다.
        entries = await queueStore.GetAllAsync(playerCount);
        var groups = MatchmakingGrouper.FindGroups(entries, playerCount, DateTime.UtcNow);
        if (groups.Count == 0)
            return;

        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        foreach (var group in groups)
        {
            var userIds = group.Select(e => e.UserId).ToList();

            var room = new Room
            {
                HostId = userIds[0],
                MaxPlayers = playerCount,
                IsPrivate = false,
                Ruleset = RoomRuleset.Official,
            };
            db.Rooms.Add(room);
            foreach (var userId in userIds)
                RoomEndpoints.AddPlayerToRoom(room, userId);
            await db.SaveChangesAsync(ct);

            await RoomEndpoints.StartRoomAsync(db, stateStore, hubContext, room);
            await queueStore.RemoveManyAsync(playerCount, userIds);

            foreach (var userId in userIds)
            {
                await queueStore.SetMatchResultAsync(userId, room.Id);
                await hubContext.Clients.User(userId.ToString()).SendAsync("MatchFound", new { roomId = room.Id, playerCount });
            }

            logger.LogInformation(
                "매치메이킹 성사: playerCount={PlayerCount}, roomId={RoomId}, userIds={UserIds}",
                playerCount, room.Id, string.Join(",", userIds));
        }
    }
}
