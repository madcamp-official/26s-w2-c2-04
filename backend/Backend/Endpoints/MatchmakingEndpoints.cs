using Backend.Data;
using Backend.Extensions;
using Backend.Hubs;
using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.SignalR;
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
            GameStateStore stateStore,
            IHubContext<GameHub> hubContext) =>
        {
            if (playerCount is < 2 or > 4)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "playerCount는 2~4여야 합니다." });

            var userId = http.User.GetUserId();

            if (await RoomEndpoints.IsInActiveRoomAsync(db, userId))
                return Results.Conflict(new { code = "ALREADY_IN_ROOM", message = "이미 참가 중인 방이 있습니다." });

            var room = await db.Rooms
                .Include(r => r.Players)
                .Where(r => r.Status == RoomStatus.Waiting
                    && r.Ruleset == RoomRuleset.Official
                    && r.MaxPlayers == playerCount
                    && r.Players.Count < playerCount)
                .OrderBy(r => r.CreatedAt)
                .FirstOrDefaultAsync();

            if (room is null)
            {
                room = new Room
                {
                    HostId = userId,
                    MaxPlayers = playerCount,
                    IsPrivate = false,
                    Ruleset = RoomRuleset.Official,
                };
                db.Rooms.Add(room);
            }

            RoomEndpoints.AddPlayerToRoom(room, userId);
            await db.SaveChangesAsync();

            if (room.Players.Count >= playerCount)
                await RoomEndpoints.StartRoomAsync(db, stateStore, hubContext, room);

            var response = await RoomEndpoints.LoadRoomResponseAsync(db, room.Id);
            return Results.Ok(response);
        })
            .WithName("MatchmakingRanked");
    }
}
