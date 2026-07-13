using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.Hubs;
using Backend.Models;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class FriendMessageEndpoints
{
    private const int DefaultLimit = 30;
    private const int MaxLimit = 100;
    private const int MaxBodyLength = 1000;

    public static void MapFriendMessageEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/friends").RequireAuthorization();

        group.MapGet("/{userId:int}/messages", async (int userId, int? beforeId, int? limit, HttpContext http, AppDbContext db) =>
        {
            var callerId = http.User.GetUserId();

            if (!await FriendEndpoints.IsFriendAsync(db, callerId, userId))
                return Results.Json(
                    new { code = "NOT_FRIENDS", message = "친구 관계가 아닙니다." },
                    statusCode: StatusCodes.Status403Forbidden);

            var pageSize = limit is > 0 ? Math.Min(limit.Value, MaxLimit) : DefaultLimit;

            var query = db.FriendMessages
                .Where(m => (m.SenderId == callerId && m.ReceiverId == userId) || (m.SenderId == userId && m.ReceiverId == callerId));

            if (beforeId is > 0)
                query = query.Where(m => m.Id < beforeId);

            var page = await query
                .OrderByDescending(m => m.Id)
                .Take(pageSize + 1)
                .ToListAsync();

            var hasMore = page.Count > pageSize;
            var messages = page
                .Take(pageSize)
                .OrderBy(m => m.Id)
                .Select(m => new FriendMessageResponse(m.Id, m.SenderId, m.ReceiverId, m.Body, m.CreatedAt))
                .ToList();

            return Results.Ok(new FriendMessageListResponse(messages, hasMore));
        })
            .WithName("GetFriendMessages");

        group.MapPost("/{userId:int}/messages", async (int userId, SendFriendMessageRequest request, HttpContext http, AppDbContext db, IHubContext<GameHub> hubContext) =>
        {
            var callerId = http.User.GetUserId();

            if (!await FriendEndpoints.IsFriendAsync(db, callerId, userId))
                return Results.Json(
                    new { code = "NOT_FRIENDS", message = "친구 관계가 아닙니다." },
                    statusCode: StatusCodes.Status403Forbidden);

            var body = request.Body?.Trim() ?? string.Empty;
            if (body.Length == 0 || body.Length > MaxBodyLength)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = $"메시지는 1~{MaxBodyLength}자여야 합니다." });

            var message = new FriendMessage { SenderId = callerId, ReceiverId = userId, Body = body };
            db.FriendMessages.Add(message);
            await db.SaveChangesAsync();

            var response = new FriendMessageResponse(message.Id, message.SenderId, message.ReceiverId, message.Body, message.CreatedAt);

            await hubContext.Clients.User(userId.ToString()).SendAsync("FriendMessage", response);

            return Results.Created($"/friends/{userId}/messages", response);
        })
            .WithName("SendFriendMessage");
    }
}
