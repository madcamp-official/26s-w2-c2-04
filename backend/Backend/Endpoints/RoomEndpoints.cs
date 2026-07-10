using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class RoomEndpoints
{
    public static void MapRoomEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/rooms").RequireAuthorization();

        group.MapPost("", async (CreateRoomRequest request, HttpContext http, AppDbContext db) =>
        {
            var userId = http.User.GetUserId();

            var ruleset = ParseRuleset(request.Ruleset);
            if (ruleset is null)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "ruleset은 official 또는 casual이어야 합니다." });

            var maxPlayers = request.MaxPlayers ?? 4;
            if (maxPlayers is < 2 or > 4)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "maxPlayers는 2~4 사이여야 합니다." });

            var isPrivate = request.IsPrivate ?? false;
            if (isPrivate && string.IsNullOrWhiteSpace(request.Password))
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "비공개 방은 password가 필요합니다." });

            if (await IsInActiveRoomAsync(db, userId))
                return Results.Conflict(new { code = "ALREADY_IN_ROOM", message = "이미 참가 중인 방이 있습니다." });

            var room = new Room
            {
                HostId = userId,
                MaxPlayers = maxPlayers,
                IsPrivate = isPrivate,
                Password = isPrivate ? request.Password : null,
                Ruleset = ruleset.Value,
            };
            room.Players.Add(new RoomPlayer { UserId = userId });

            db.Rooms.Add(room);
            await db.SaveChangesAsync();

            var response = await LoadRoomResponseAsync(db, room.Id);
            return Results.Created($"/rooms/{room.Id}", response);
        })
            .WithName("CreateRoom");

        group.MapGet("", async (string? status, int? page, int? limit, AppDbContext db) =>
        {
            RoomStatus? statusFilter = null;
            if (!string.IsNullOrWhiteSpace(status))
            {
                statusFilter = ParseStatus(status);
                if (statusFilter is null)
                    return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "status는 WAITING 또는 PLAYING이어야 합니다." });
            }

            var pageNum = page is > 0 ? page.Value : 1;
            var pageSize = limit is > 0 ? Math.Min(limit.Value, 100) : 20;

            var query = db.Rooms.Include(r => r.Players).ThenInclude(p => p.User).AsQueryable();
            if (statusFilter is not null)
                query = query.Where(r => r.Status == statusFilter);

            var total = await query.CountAsync();
            var rooms = await query
                .OrderByDescending(r => r.CreatedAt)
                .Skip((pageNum - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Results.Ok(new RoomListResponse(rooms.Select(MapRoom).ToList(), total, pageNum));
        })
            .WithName("ListRooms");

        group.MapGet("/{roomId:int}", async (int roomId, AppDbContext db) =>
        {
            var room = await db.Rooms
                .Include(r => r.Players).ThenInclude(p => p.User)
                .FirstOrDefaultAsync(r => r.Id == roomId);

            return room is null
                ? Results.NotFound(new { code = "ROOM_NOT_FOUND", message = "방을 찾을 수 없습니다." })
                : Results.Ok(MapRoom(room));
        })
            .WithName("GetRoom");

        group.MapPost("/{roomId:int}/join", async (int roomId, JoinRoomRequest request, HttpContext http, AppDbContext db) =>
        {
            var userId = http.User.GetUserId();

            var room = await db.Rooms
                .Include(r => r.Players).ThenInclude(p => p.User)
                .FirstOrDefaultAsync(r => r.Id == roomId);

            if (room is null)
                return Results.NotFound(new { code = "ROOM_NOT_FOUND", message = "방을 찾을 수 없습니다." });

            if (room.Players.Any(p => p.UserId == userId))
                return Results.Ok(MapRoom(room));

            if (await IsInActiveRoomAsync(db, userId))
                return Results.Conflict(new { code = "ALREADY_IN_ROOM", message = "이미 참가 중인 다른 방이 있습니다." });

            if (room.Status != RoomStatus.Waiting)
                return Results.Conflict(new { code = "ROOM_ALREADY_STARTED", message = "이미 게임이 시작된 방입니다." });

            if (room.Players.Count >= room.MaxPlayers)
                return Results.Conflict(new { code = "ROOM_FULL", message = "방 인원이 가득 찼습니다." });

            if (room.IsPrivate && room.Password != request.Password)
                return Results.Json(
                    new { code = "ROOM_INVALID_PASSWORD", message = "비밀번호가 올바르지 않습니다." },
                    statusCode: StatusCodes.Status403Forbidden);

            room.Players.Add(new RoomPlayer { RoomId = room.Id, UserId = userId });
            await db.SaveChangesAsync();

            var response = await LoadRoomResponseAsync(db, room.Id);
            return Results.Ok(response);
        })
            .WithName("JoinRoom");

        group.MapPost("/{roomId:int}/leave", async (int roomId, HttpContext http, AppDbContext db) =>
        {
            var userId = http.User.GetUserId();

            var room = await db.Rooms.Include(r => r.Players).FirstOrDefaultAsync(r => r.Id == roomId);
            if (room is null)
                return Results.NoContent();

            var player = room.Players.FirstOrDefault(p => p.UserId == userId);
            if (player is null)
                return Results.NoContent();

            db.RoomPlayers.Remove(player);
            room.Players.Remove(player);

            if (room.Players.Count == 0)
            {
                db.Rooms.Remove(room);
            }
            else if (room.HostId == userId)
            {
                room.HostId = room.Players.OrderBy(p => p.JoinedAt).First().UserId;
            }

            await db.SaveChangesAsync();
            return Results.NoContent();
        })
            .WithName("LeaveRoom");

        group.MapDelete("/{roomId:int}", async (int roomId, HttpContext http, AppDbContext db) =>
        {
            var userId = http.User.GetUserId();

            var room = await db.Rooms.FirstOrDefaultAsync(r => r.Id == roomId);
            if (room is null)
                return Results.NotFound(new { code = "ROOM_NOT_FOUND", message = "방을 찾을 수 없습니다." });

            if (room.HostId != userId)
                return Results.Json(
                    new { code = "ROOM_NOT_HOST", message = "방장만 삭제할 수 있습니다." },
                    statusCode: StatusCodes.Status403Forbidden);

            if (room.Status != RoomStatus.Waiting)
                return Results.Conflict(new { code = "ROOM_ALREADY_STARTED", message = "게임이 시작된 방은 삭제할 수 없습니다." });

            db.Rooms.Remove(room);
            await db.SaveChangesAsync();
            return Results.NoContent();
        })
            .WithName("DeleteRoom");
    }

    private static async Task<bool> IsInActiveRoomAsync(AppDbContext db, int userId) =>
        await db.RoomPlayers
            .Include(rp => rp.Room)
            .AnyAsync(rp => rp.UserId == userId && rp.Room.Status == RoomStatus.Waiting);

    private static async Task<RoomResponse> LoadRoomResponseAsync(AppDbContext db, int roomId)
    {
        var room = await db.Rooms
            .Include(r => r.Players).ThenInclude(p => p.User)
            .FirstAsync(r => r.Id == roomId);
        return MapRoom(room);
    }

    private static RoomResponse MapRoom(Room room) => new(
        room.Id,
        room.HostId,
        room.Status == RoomStatus.Waiting ? "WAITING" : "PLAYING",
        room.MaxPlayers,
        room.IsPrivate,
        room.Ruleset == RoomRuleset.Official ? "official" : "casual",
        room.Players
            .OrderBy(p => p.JoinedAt)
            .Select(p => new RoomPlayerResponse(p.UserId, p.User.Email, p.UserId == room.HostId))
            .ToList(),
        room.CreatedAt);

    private static RoomRuleset? ParseRuleset(string? value) => value?.ToLowerInvariant() switch
    {
        null => RoomRuleset.Official,
        "official" => RoomRuleset.Official,
        "casual" => RoomRuleset.Casual,
        _ => null,
    };

    private static RoomStatus? ParseStatus(string value) => value.ToUpperInvariant() switch
    {
        "WAITING" => RoomStatus.Waiting,
        "PLAYING" => RoomStatus.Playing,
        _ => null,
    };
}
