using Backend.Data;
using Backend.Dtos;
using Backend.Extensions;
using Backend.Hubs;
using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Endpoints;

public static class FriendEndpoints
{
    private const int SearchLimit = 20;

    public static void MapFriendEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/friends").RequireAuthorization();

        group.MapGet("/search", async (string? query, HttpContext http, AppDbContext db) =>
        {
            var userId = http.User.GetUserId();
            var searchTerm = query ?? string.Empty;
            var searchUserId = int.TryParse(searchTerm, out var parsedId) ? parsedId : (int?)null;
            var likePattern = $"%{LeaderboardEndpoints.EscapeLikePattern(searchTerm)}%";

            var matches = await db.Users
                .Where(u => u.Id != userId
                    && (EF.Functions.Like(u.Nickname, likePattern, "\\") || u.Id == searchUserId))
                .OrderBy(u => u.Nickname)
                .Take(SearchLimit)
                .Select(u => new FriendSearchItemResponse(u.Id, u.Nickname, u.AvatarUrl))
                .ToListAsync();

            return Results.Ok(new FriendSearchResponse(matches));
        })
            .WithName("SearchFriendCandidates");

        group.MapPost("/requests", async (SendFriendRequestRequest request, HttpContext http, AppDbContext db, IHubContext<SocialHub> hubContext) =>
        {
            var userId = http.User.GetUserId();

            if (request.TargetUserId == userId)
                return Results.BadRequest(new { code = "INVALID_PAYLOAD", message = "자기 자신에게 친구 요청을 보낼 수 없습니다." });

            var target = await db.Users.FirstOrDefaultAsync(u => u.Id == request.TargetUserId);
            if (target is null)
                return Results.NotFound(new { code = "USER_NOT_FOUND", message = "유저를 찾을 수 없습니다." });

            var existing = await db.Friendships.FirstOrDefaultAsync(f =>
                (f.RequesterId == userId && f.AddresseeId == target.Id)
                || (f.RequesterId == target.Id && f.AddresseeId == userId));

            if (existing is not null && existing.Status == FriendshipStatus.Accepted)
                return Results.Conflict(new { code = "ALREADY_FRIENDS", message = "이미 친구입니다." });

            if (existing is not null && existing.Status == FriendshipStatus.Pending && existing.RequesterId == userId)
                return Results.Conflict(new { code = "REQUEST_ALREADY_SENT", message = "이미 친구 요청을 보냈습니다." });

            if (existing is not null && existing.Status == FriendshipStatus.Pending && existing.AddresseeId == userId)
            {
                // 상대가 이미 나에게 요청을 보내둔 상태라면 새로 만들지 않고 그 요청을 바로 수락한다.
                existing.Status = FriendshipStatus.Accepted;
                existing.RespondedAt = DateTime.UtcNow;
                await db.SaveChangesAsync();

                var me = await db.Users.FirstAsync(u => u.Id == userId);
                await hubContext.Clients.User(existing.RequesterId.ToString())
                    .SendAsync("FriendRequestAccepted", new { requestId = existing.Id, byUserId = userId, byNickname = me.Nickname });

                return Results.Ok(new FriendResponse(target.Id, target.Nickname, target.AvatarUrl, "offline", existing.RespondedAt.Value));
            }

            var friendship = new Friendship { RequesterId = userId, AddresseeId = target.Id, Status = FriendshipStatus.Pending };
            db.Friendships.Add(friendship);
            await db.SaveChangesAsync();

            var requester = await db.Users.FirstAsync(u => u.Id == userId);
            await hubContext.Clients.User(target.Id.ToString())
                .SendAsync("FriendRequestReceived", new { requestId = friendship.Id, fromUserId = userId, fromNickname = requester.Nickname });

            return Results.Created($"/friends/requests/{friendship.Id}",
                new FriendRequestResponse(friendship.Id, target.Id, target.Nickname, target.AvatarUrl, friendship.CreatedAt));
        })
            .WithName("SendFriendRequest");

        group.MapGet("/requests", async (HttpContext http, AppDbContext db) =>
        {
            var userId = http.User.GetUserId();

            var incoming = await db.Friendships
                .Include(f => f.Requester)
                .Where(f => f.AddresseeId == userId && f.Status == FriendshipStatus.Pending)
                .Select(f => new FriendRequestResponse(f.Id, f.RequesterId, f.Requester.Nickname, f.Requester.AvatarUrl, f.CreatedAt))
                .ToListAsync();

            var outgoing = await db.Friendships
                .Include(f => f.Addressee)
                .Where(f => f.RequesterId == userId && f.Status == FriendshipStatus.Pending)
                .Select(f => new FriendRequestResponse(f.Id, f.AddresseeId, f.Addressee.Nickname, f.Addressee.AvatarUrl, f.CreatedAt))
                .ToListAsync();

            return Results.Ok(new FriendRequestListResponse(incoming, outgoing));
        })
            .WithName("ListFriendRequests");

        group.MapPost("/requests/{requestId:int}/accept", async (int requestId, HttpContext http, AppDbContext db, IHubContext<SocialHub> hubContext) =>
        {
            var userId = http.User.GetUserId();

            var request = await db.Friendships.Include(f => f.Requester).FirstOrDefaultAsync(f => f.Id == requestId);
            if (request is null)
                return Results.NotFound(new { code = "REQUEST_NOT_FOUND", message = "친구 요청을 찾을 수 없습니다." });

            if (request.Status != FriendshipStatus.Pending)
                return Results.Conflict(new { code = "REQUEST_ALREADY_RESOLVED", message = "이미 처리된 요청입니다." });

            if (request.AddresseeId != userId)
                return Results.Json(
                    new { code = "NOT_REQUEST_RECIPIENT", message = "본인에게 온 요청만 수락할 수 있습니다." },
                    statusCode: StatusCodes.Status403Forbidden);

            request.Status = FriendshipStatus.Accepted;
            request.RespondedAt = DateTime.UtcNow;
            await db.SaveChangesAsync();

            var me = await db.Users.FirstAsync(u => u.Id == userId);
            await hubContext.Clients.User(request.RequesterId.ToString())
                .SendAsync("FriendRequestAccepted", new { requestId = request.Id, byUserId = userId, byNickname = me.Nickname });

            return Results.Ok(new FriendResponse(
                request.Requester.Id, request.Requester.Nickname, request.Requester.AvatarUrl, "offline", request.RespondedAt.Value));
        })
            .WithName("AcceptFriendRequest");

        group.MapDelete("/requests/{requestId:int}", async (int requestId, HttpContext http, AppDbContext db, IHubContext<SocialHub> hubContext) =>
        {
            var userId = http.User.GetUserId();

            var request = await db.Friendships.FirstOrDefaultAsync(f => f.Id == requestId);
            if (request is null)
                return Results.NoContent();

            if (request.Status != FriendshipStatus.Pending)
                return Results.Conflict(new { code = "REQUEST_ALREADY_RESOLVED", message = "이미 처리된 요청입니다." });

            if (request.RequesterId != userId && request.AddresseeId != userId)
                return Results.Json(
                    new { code = "NOT_REQUEST_PARTICIPANT", message = "본인과 관련된 요청만 삭제할 수 있습니다." },
                    statusCode: StatusCodes.Status403Forbidden);

            var otherUserId = request.RequesterId == userId ? request.AddresseeId : request.RequesterId;
            var eventName = request.RequesterId == userId ? "FriendRequestCancelled" : "FriendRequestDeclined";

            db.Friendships.Remove(request);
            await db.SaveChangesAsync();

            await hubContext.Clients.User(otherUserId.ToString())
                .SendAsync(eventName, new { requestId, byUserId = userId });

            return Results.NoContent();
        })
            .WithName("RemoveFriendRequest");

        group.MapGet("", async (HttpContext http, AppDbContext db, PresenceStore presence) =>
        {
            var userId = http.User.GetUserId();

            var friendships = await db.Friendships
                .Include(f => f.Requester)
                .Include(f => f.Addressee)
                .Where(f => f.Status == FriendshipStatus.Accepted && (f.RequesterId == userId || f.AddresseeId == userId))
                .ToListAsync();

            var others = friendships
                .Select(f => f.RequesterId == userId ? f.Addressee : f.Requester)
                .ToList();
            var statuses = await presence.GetStatusesAsync(others.Select(u => u.Id));

            var friends = friendships
                .Zip(others, (f, other) => new FriendResponse(
                    other.Id, other.Nickname, other.AvatarUrl, statuses.GetValueOrDefault(other.Id, "offline"), f.RespondedAt ?? f.CreatedAt))
                .OrderBy(f => f.Nickname)
                .ToList();

            return Results.Ok(new FriendListResponse(friends));
        })
            .WithName("ListFriends");

        group.MapDelete("/{userId:int}", async (int userId, HttpContext http, AppDbContext db, IHubContext<SocialHub> hubContext) =>
        {
            var callerId = http.User.GetUserId();

            var friendship = await db.Friendships.FirstOrDefaultAsync(f =>
                f.Status == FriendshipStatus.Accepted
                && ((f.RequesterId == callerId && f.AddresseeId == userId) || (f.RequesterId == userId && f.AddresseeId == callerId)));

            if (friendship is null)
                return Results.NotFound(new { code = "NOT_FRIENDS", message = "친구 관계가 아닙니다." });

            db.Friendships.Remove(friendship);
            await db.SaveChangesAsync();

            await hubContext.Clients.User(userId.ToString())
                .SendAsync("FriendRemoved", new { byUserId = callerId });

            return Results.NoContent();
        })
            .WithName("RemoveFriend");
    }

    internal static async Task<bool> IsFriendAsync(AppDbContext db, int userId, int otherUserId) =>
        await db.Friendships.AnyAsync(f =>
            f.Status == FriendshipStatus.Accepted
            && ((f.RequesterId == userId && f.AddresseeId == otherUserId) || (f.RequesterId == otherUserId && f.AddresseeId == userId)));

    internal static async Task<List<int>> GetFriendIdsAsync(AppDbContext db, int userId)
    {
        var friendships = await db.Friendships
            .Where(f => f.Status == FriendshipStatus.Accepted && (f.RequesterId == userId || f.AddresseeId == userId))
            .Select(f => new { f.RequesterId, f.AddresseeId })
            .ToListAsync();

        return friendships
            .Select(f => f.RequesterId == userId ? f.AddresseeId : f.RequesterId)
            .ToList();
    }
}
