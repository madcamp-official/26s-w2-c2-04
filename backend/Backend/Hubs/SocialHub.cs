using Backend.Data;
using Backend.Endpoints;
using Backend.Extensions;
using Backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Backend.Hubs;

/// <summary>
/// 친구 요청/프레즌스/1:1 메시지 전용 Hub(README 9절). 특정 방(Room)에 종속되지 않고
/// 로그인 직후부터 앱이 살아있는 동안 상시 연결을 유지하는 것을 전제로 한다.
/// 게임 진행(방 입장/액션)은 GameHub가 별도로 담당한다.
/// </summary>
[Authorize]
public class SocialHub(AppDbContext db, PresenceStore presence) : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User!.GetUserId();

        // ConnectSocialAsync는 카운트가 0->1로 바뀔 때만 true를 반환한다. false면 이미
        // 다른 연결(다른 기기/브라우저/탭)이 붙어있다는 뜻 — 방금 늘어난 카운트를 되돌리고
        // 이 연결은 거부한다. REST /auth/login의 ALREADY_LOGGED_IN 체크만으로는 부족하다:
        // 캐시된 accessToken으로 재로그인 없이 재연결하는 경로(AuthController.restoreSession,
        // 예: 탭을 닫았다 다시 여는 경우)는 /login을 거치지 않아 그 체크를 우회하므로,
        // 실제 "동시접속 차단"은 연결 시점(Hub)에서 강제해야 한다.
        // OnConnectedAsync에서 예외를 던지면 SignalR이 연결을 아예 성립시키지 않고
        // 거부하며, 이 경우 OnDisconnectedAsync는 호출되지 않는다(연결이 성립한 적이
        // 없으므로) — 그래서 DisconnectSocialAsync를 직접 호출해 카운트를 되돌려야 한다.
        // Context.Abort()를 쓰면 OnDisconnectedAsync가 뒤따라 호출돼 정상 연결의 카운트까지
        // 잘못 깎일 수 있어 피한다.
        if (!await presence.ConnectSocialAsync(userId))
        {
            await presence.DisconnectSocialAsync(userId);
            throw new HubException("ALREADY_LOGGED_IN");
        }

        await BroadcastStatusAsync(db, presence, Clients, userId);
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.User!.GetUserId();
        if (await presence.DisconnectSocialAsync(userId))
            await BroadcastStatusAsync(db, presence, Clients, userId);

        await base.OnDisconnectedAsync(exception);
    }

    public async Task SetPresence(string status)
    {
        if (status is not ("online" or "away"))
            throw new HubException("INVALID_PAYLOAD");

        var userId = Context.User!.GetUserId();
        await presence.SetPreferenceAsync(userId, status);
        await BroadcastStatusAsync(db, presence, Clients, userId);
    }

    public async Task SendFriendMessage(int toUserId, string text)
    {
        var userId = Context.User!.GetUserId();
        var (error, _) = await FriendMessageEndpoints.SendMessageAsync(db, Clients, userId, toUserId, text);
        if (error != FriendMessageEndpoints.SendMessageError.None)
            throw new HubException(error == FriendMessageEndpoints.SendMessageError.NotFriends ? "NOT_FRIENDS" : "INVALID_PAYLOAD");
    }

    /// <summary>
    /// 친구들에게 최신 프레즌스 상태를 브로드캐스트한다. GameHub.JoinRoom/방 이탈 확정 시점처럼
    /// SocialHub 밖에서도 같은 로직이 필요해서 재사용 가능하도록 static으로 둔다.
    /// </summary>
    internal static async Task BroadcastStatusAsync(
        AppDbContext db, PresenceStore presence, IHubClients<IClientProxy> hubClients, int userId)
    {
        var friendIds = await FriendEndpoints.GetFriendIdsAsync(db, userId);
        if (friendIds.Count == 0)
            return;

        var status = await presence.GetStatusAsync(userId);
        await hubClients.Users(friendIds.Select(id => id.ToString()).ToList())
            .SendAsync("FriendStatusChanged", new { friendUserId = userId, status });
    }
}
