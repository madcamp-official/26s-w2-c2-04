using Backend.Data;
using Backend.GameLogic;
using Backend.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace Backend.Services;

/// <summary>
/// 진행 중인 게임의 턴 제한시간(피셔 룰, GameEngine.ResolveTimeout 참고)을 감시해서
/// 마감이 지난 게임을 찾아 자동으로 턴을 넘긴다. GameStateStore의 sorted set
/// (game:turn-deadlines) 덕에 매 틱 DB를 훑지 않고 만료된 게임만 골라낸다.
/// </summary>
public class TurnTimeoutWorker(
    IServiceScopeFactory scopeFactory,
    GameStateStore stateStore,
    IHubContext<GameHub> hubContext,
    ILogger<TurnTimeoutWorker> logger) : BackgroundService
{
    private static readonly TimeSpan TickInterval = TimeSpan.FromSeconds(1);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TickInterval);
        do
        {
            foreach (var gameId in await stateStore.GetExpiredTurnGameIdsAsync(DateTime.UtcNow))
            {
                try
                {
                    await ProcessTimeoutAsync(gameId);
                }
                catch (Exception ex)
                {
                    logger.LogError(ex, "턴 타임아웃 처리 중 오류: game {GameId}", gameId);
                }
            }
        } while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    private async Task ProcessTimeoutAsync(int gameId)
    {
        await using var _ = await stateStore.AcquireLockAsync(gameId);

        // 락을 잡는 사이 플레이어가 직접 행동했거나 게임이 끝났을 수 있으니 최신 상태로 다시 확인한다.
        var state = await stateStore.LoadAsync(gameId);
        if (state?.TurnDeadlineUtc is not { } deadline || deadline > DateTime.UtcNow)
            return;

        var timedOutPlayerId = state.CurrentPlayerId;
        var outcome = GameEngine.ResolveTimeout(state, timedOutPlayerId);
        await stateStore.SaveAsync(gameId, state);

        using var scope = scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await GameHub.BroadcastActionOutcomeAsync(
            gameId, timedOutPlayerId, "Timeout", new { reason = "timeout" },
            state, outcome, timedOutPlayerId, db, stateStore,
            hubContext.Clients.Group(GameHubMessages.GroupName(gameId)), callerClient: null);
    }
}
