using Backend.Data;
using Backend.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Hubs;

[Authorize]
public class RoomHub(AppDbContext db) : Hub
{
    public async Task JoinRoom(int roomId)
    {
        var userId = Context.User!.GetUserId();
        var isMember = await db.RoomPlayers.AnyAsync(p => p.RoomId == roomId && p.UserId == userId);
        if (!isMember)
            throw new HubException("이 방의 멤버가 아닙니다.");

        await Groups.AddToGroupAsync(Context.ConnectionId, GroupName(roomId));
    }

    public async Task LeaveRoom(int roomId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, GroupName(roomId));
    }

    public async Task BroadcastMessage(int roomId, string message)
    {
        var userId = Context.User!.GetUserId();
        var player = await db.RoomPlayers
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.RoomId == roomId && p.UserId == userId);
        if (player is null)
            throw new HubException("이 방의 멤버가 아닙니다.");

        await Clients.Group(GroupName(roomId)).SendAsync("ReceiveMessage", new
        {
            roomId,
            userId,
            email = player.User.Email,
            message,
            sentAt = DateTime.UtcNow,
        });
    }

    private static string GroupName(int roomId) => $"room-{roomId}";
}
