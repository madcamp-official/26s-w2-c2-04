using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.GameLogic;
using Backend.Models;
using Backend.Services;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class MatchmakingEndpoints
{
    public static void MapMatchmakingEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/matchmaking").RequireAuthorization();

        group.MapPost("/{playerCount:int}/ranked", async (
            int playerCount,
            HttpContext http,
            AppDbContext db,
            MatchmakingQueueStore queueStore) =>
        {
            if (playerCount is < 2 or > 4)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "playerCount는 2~4여야 합니다." });

            var userId = http.User.GetUserId();

            if (await RoomEndpoints.IsInActiveRoomAsync(db, userId))
                return Results.Conflict(new { code = "ALREADY_IN_ROOM", message = "이미 참가 중인 방이 있습니다." });

            var queuedPlayerCount = await queueStore.FindQueuedPlayerCountAsync(userId);
            if (queuedPlayerCount is not null && queuedPlayerCount != playerCount)
                return Results.Conflict(new { code = "ALREADY_QUEUED", message = $"이미 {queuedPlayerCount}인 랭킹전 대기열에 있습니다." });

            var ranking = await db.PlayerRankings
                .FirstOrDefaultAsync(pr => pr.PlayerCount == playerCount && pr.UserId == userId);
            if (ranking is null)
            {
                ranking = new PlayerRanking { UserId = userId, PlayerCount = playerCount };
                db.PlayerRankings.Add(ranking);
                await db.SaveChangesAsync();
            }

            var entry = await queueStore.GetEntryAsync(playerCount, userId);
            if (entry is null)
            {
                await queueStore.EnqueueAsync(playerCount, userId, ranking.Mmr);
                entry = await queueStore.GetEntryAsync(playerCount, userId);
            }

            return Results.Ok(ToQueuedResponse(playerCount, entry!));
        })
            .WithName("MatchmakingRanked");

        group.MapDelete("/{playerCount:int}/ranked", async (
            int playerCount,
            HttpContext http,
            MatchmakingQueueStore queueStore) =>
        {
            var userId = http.User.GetUserId();
            await queueStore.DequeueAsync(playerCount, userId);
            return Results.NoContent();
        })
            .WithName("CancelMatchmaking");

        group.MapGet("/{playerCount:int}/status", async (
            int playerCount,
            HttpContext http,
            MatchmakingQueueStore queueStore) =>
        {
            var userId = http.User.GetUserId();

            var matchedRoomId = await queueStore.ConsumeMatchResultAsync(userId);
            if (matchedRoomId is not null)
                return Results.Ok(new MatchmakingStatusResponse("MATCHED", playerCount, null, null, matchedRoomId));

            var entry = await queueStore.GetEntryAsync(playerCount, userId);
            return Results.Ok(entry is null
                ? new MatchmakingStatusResponse("NOT_QUEUED", playerCount, null, null, null)
                : ToQueuedResponse(playerCount, entry));
        })
            .WithName("MatchmakingStatus");
    }

    private static MatchmakingStatusResponse ToQueuedResponse(int playerCount, QueueEntry entry)
    {
        var waitedSeconds = Math.Max(0, (DateTimeOffset.UtcNow - DateTimeOffset.FromUnixTimeMilliseconds(entry.JoinedAtUnixMs)).TotalSeconds);
        var range = MatchmakingGrouper.CalculateRange(waitedSeconds);
        return new MatchmakingStatusResponse("QUEUED", playerCount, entry.Mmr, range, null);
    }
}
