using System.Text.Json;
using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.GameLogic;
using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class RoomEndpoints
{
    public static void MapRoomEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/rooms").RequireAuthorization();

        group.MapPost("", async (CreateRoomRequest request, HttpContext http, AppDbContext db, IPasswordHasher<Room> hasher) =>
        {
            var userId = http.User.GetUserId();

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
                Ruleset = RoomRuleset.Casual,
            };
            if (isPrivate)
                room.PasswordHash = hasher.HashPassword(room, request.Password!);

            room.Players.Add(new RoomPlayer { UserId = userId });

            db.Rooms.Add(room);
            await db.SaveChangesAsync();

            var response = await LoadRoomResponseAsync(db, room.Id);
            return Results.Created($"/rooms/{room.Id}", response);
        })
            .WithName("CreateRoom");

        group.MapGet("", async (int? page, int? limit, AppDbContext db) =>
        {
            var pageNum = page is > 0 ? page.Value : 1;
            var pageSize = limit is > 0 ? Math.Min(limit.Value, 100) : 20;

            var query = db.Rooms
                .Include(r => r.Players).ThenInclude(p => p.User)
                .Where(r => r.Status == RoomStatus.Waiting);

            var total = await query.CountAsync();
            var rooms = await query
                .OrderByDescending(r => r.CreatedAt)
                .Skip((pageNum - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Results.Ok(new RoomListResponse(rooms.Select(MapRoomListItem).ToList(), total, pageNum));
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

        group.MapPost("/{roomId:int}/join", async (int roomId, JoinRoomRequest request, HttpContext http, AppDbContext db, IPasswordHasher<Room> hasher) =>
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

            if (room.IsPrivate)
            {
                var verifyResult = room.PasswordHash is not null && !string.IsNullOrEmpty(request.Password)
                    ? hasher.VerifyHashedPassword(room, room.PasswordHash, request.Password)
                    : PasswordVerificationResult.Failed;
                if (verifyResult == PasswordVerificationResult.Failed)
                    return Results.Json(
                        new { code = "ROOM_INVALID_PASSWORD", message = "비밀번호가 올바르지 않습니다." },
                        statusCode: StatusCodes.Status403Forbidden);
            }

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

            LeaveRoom(db, room, player);

            await db.SaveChangesAsync();
            return Results.NoContent();
        })
            .WithName("LeaveRoom");

        group.MapPost("/{roomId:int}/start", async (int roomId, HttpContext http, AppDbContext db, GameStateStore stateStore) =>
        {
            var userId = http.User.GetUserId();

            var room = await db.Rooms.Include(r => r.Players).FirstOrDefaultAsync(r => r.Id == roomId);
            if (room is null)
                return Results.NotFound(new { code = "ROOM_NOT_FOUND", message = "방을 찾을 수 없습니다." });

            if (room.HostId != userId)
                return Results.Json(
                    new { code = "ROOM_NOT_HOST", message = "방장만 게임을 시작할 수 있습니다." },
                    statusCode: StatusCodes.Status403Forbidden);

            if (room.Status != RoomStatus.Waiting)
                return Results.Conflict(new { code = "ROOM_ALREADY_STARTED", message = "이미 게임이 시작된 방입니다." });

            if (room.Players.Count < 2)
                return Results.Conflict(new { code = "NOT_ENOUGH_PLAYERS", message = "최소 2명이 필요합니다." });

            var playerIds = room.Players.OrderBy(p => p.JoinedAt).Select(p => p.UserId).ToList();
            var state = GameEngine.Initialize(playerIds);

            var game = new Game
            {
                RoomId = room.Id,
                CurrentPlayerId = state.CurrentPlayerId,
                TurnNumber = state.TurnNumber,
                Sequence = state.Sequence,
                StateJson = JsonSerializer.Serialize(state),
            };
            room.Status = RoomStatus.Playing;

            db.Games.Add(game);
            await db.SaveChangesAsync();
            await stateStore.SaveAsync(room.Id, state);

            return Results.Ok(new StartGameResponse(game.Id, "PLAYING"));
        })
            .WithName("StartGame");

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

    /// <summary>
    /// 로그아웃 등 인증 로직에서 재사용. 게임이 이미 시작된(PLAYING) 방은 건드리지 않는다.
    /// </summary>
    public static async Task LeaveAllWaitingRoomsAsync(AppDbContext db, int userId)
    {
        var memberships = await db.RoomPlayers
            .Include(rp => rp.Room).ThenInclude(r => r.Players)
            .Where(rp => rp.UserId == userId && rp.Room.Status == RoomStatus.Waiting)
            .ToListAsync();

        foreach (var membership in memberships)
            LeaveRoom(db, membership.Room, membership);
    }

    private static void LeaveRoom(AppDbContext db, Room room, RoomPlayer player)
    {
        db.RoomPlayers.Remove(player);
        room.Players.Remove(player);

        if (room.Players.Count == 0)
        {
            db.Rooms.Remove(room);
        }
        else if (room.HostId == player.UserId)
        {
            room.HostId = room.Players.OrderBy(p => p.JoinedAt).First().UserId;
        }
    }

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
        MapPlayers(room),
        room.CreatedAt);

    private static RoomListItemResponse MapRoomListItem(Room room) => new(
        room.Id,
        room.HostId,
        room.MaxPlayers,
        room.IsPrivate,
        MapPlayers(room),
        room.CreatedAt);

    private static List<RoomPlayerResponse> MapPlayers(Room room) =>
        room.Players
            .OrderBy(p => p.JoinedAt)
            .Select(p => new RoomPlayerResponse(p.UserId, p.User.Nickname, p.UserId == room.HostId))
            .ToList();
}
