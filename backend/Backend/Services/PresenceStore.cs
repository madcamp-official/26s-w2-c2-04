using StackExchange.Redis;

namespace Backend.Services;

/// <summary>
/// 유저 프레즌스 저장소. 두 개의 독립적인 연결 카운터를 둔다:
/// - Social(=SocialHub) 연결 수: 로그인~앱 종료까지 상시 연결되는 진짜 온라인/오프라인 판정 기준.
/// - Game(=GameHub) 연결 수: 게임 화면에서만 연결되며, 방 이탈 유예 로직(RoomDepartureService)이
///   "이 유저의 마지막 GameHub 연결이 끊겼는가"를 판단하는 용도로만 쓰인다. 온라인 여부와는 무관.
/// 이 외에 유저가 명시적으로 설정한 online/away 선호(preference)와, 현재 게임 중인지(in_game)를 저장해
/// 최종 상태(online/away/in_game/offline)를 계산한다.
/// </summary>
public class PresenceStore(IConnectionMultiplexer redis)
{
    private const string SocialOnlineHashKey = "presence:online";
    private const string GameOnlineHashKey = "presence:game-online";
    private const string PreferenceHashKey = "presence:preference";
    private const string InGameSetKey = "presence:ingame";

    private readonly IDatabase _db = redis.GetDatabase();

    /// <returns>이번 연결로 방금 온라인이 되었으면 true(연결 수가 0에서 1로 전환).</returns>
    public async Task<bool> ConnectSocialAsync(int userId) =>
        await _db.HashIncrementAsync(SocialOnlineHashKey, userId, 1) == 1;

    /// <returns>이번 해제로 방금 오프라인이 되었으면 true(연결 수가 0 이하로 전환).</returns>
    public async Task<bool> DisconnectSocialAsync(int userId) => await DecrementAsync(SocialOnlineHashKey, userId);

    /// <returns>이번 연결이 이 유저의 첫 GameHub 연결이면 true.</returns>
    public async Task<bool> ConnectGameAsync(int userId) =>
        await _db.HashIncrementAsync(GameOnlineHashKey, userId, 1) == 1;

    /// <returns>이번 해제가 이 유저의 마지막 GameHub 연결이었으면 true.</returns>
    public async Task<bool> DisconnectGameAsync(int userId) => await DecrementAsync(GameOnlineHashKey, userId);

    private async Task<bool> DecrementAsync(string hashKey, int userId)
    {
        var count = await _db.HashIncrementAsync(hashKey, userId, -1);
        if (count > 0)
            return false;

        await _db.HashDeleteAsync(hashKey, userId);
        return true;
    }

    public async Task<HashSet<int>> GetOnlineAsync(IEnumerable<int> userIds)
    {
        var ids = userIds.Distinct().ToArray();
        if (ids.Length == 0)
            return [];

        var fields = ids.Select(id => (RedisValue)id).ToArray();
        var values = await _db.HashGetAsync(SocialOnlineHashKey, fields);

        var online = new HashSet<int>();
        for (var i = 0; i < ids.Length; i++)
        {
            if (!values[i].IsNullOrEmpty && (long)values[i] > 0)
                online.Add(ids[i]);
        }
        return online;
    }

    /// <summary>온라인 상태에서 SetPresence로 고른 선호값("online" 또는 "away")을 저장한다.</summary>
    public Task SetPreferenceAsync(int userId, string status) =>
        _db.HashSetAsync(PreferenceHashKey, userId, status);

    /// <summary>GameHub.JoinRoom/방 이탈 확정 시점에 게임 참여 여부를 갱신한다.</summary>
    public Task SetInGameAsync(int userId, bool inGame) => inGame
        ? _db.SetAddAsync(InGameSetKey, userId)
        : _db.SetRemoveAsync(InGameSetKey, userId);

    /// <summary>최종 프레즌스 상태: offline(연결 없음) &gt; in_game &gt; 선호값(기본 online).</summary>
    public async Task<string> GetStatusAsync(int userId)
    {
        var statuses = await GetStatusesAsync([userId]);
        return statuses.GetValueOrDefault(userId, "offline");
    }

    public async Task<Dictionary<int, string>> GetStatusesAsync(IEnumerable<int> userIds)
    {
        var ids = userIds.Distinct().ToArray();
        if (ids.Length == 0)
            return [];

        var fields = ids.Select(id => (RedisValue)id).ToArray();
        var onlineCounts = await _db.HashGetAsync(SocialOnlineHashKey, fields);
        var preferences = await _db.HashGetAsync(PreferenceHashKey, fields);
        var inGameFlags = await _db.SetContainsAsync(InGameSetKey, fields.Select(f => (RedisValue)f).ToArray());

        var result = new Dictionary<int, string>();
        for (var i = 0; i < ids.Length; i++)
        {
            var isOnline = !onlineCounts[i].IsNullOrEmpty && (long)onlineCounts[i] > 0;
            result[ids[i]] = !isOnline
                ? "offline"
                : inGameFlags[i]
                    ? "in_game"
                    : preferences[i].IsNullOrEmpty ? "online" : (string)preferences[i]!;
        }
        return result;
    }
}
