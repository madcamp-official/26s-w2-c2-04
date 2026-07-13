using StackExchange.Redis;

namespace Backend.Services;

/// <summary>
/// GameHub 연결 수 기반 온라인 상태 저장소. 유저 하나가 여러 탭/디바이스로 접속해도
/// 마지막 연결이 끊길 때까지 온라인으로 유지되도록 연결 수를 센다.
/// </summary>
public class PresenceStore(IConnectionMultiplexer redis)
{
    private const string OnlineHashKey = "presence:online";

    private readonly IDatabase _db = redis.GetDatabase();

    /// <returns>이번 연결로 방금 온라인이 되었으면 true(연결 수가 0에서 1로 전환).</returns>
    public async Task<bool> ConnectAsync(int userId) =>
        await _db.HashIncrementAsync(OnlineHashKey, userId, 1) == 1;

    /// <returns>이번 해제로 방금 오프라인이 되었으면 true(연결 수가 0 이하로 전환).</returns>
    public async Task<bool> DisconnectAsync(int userId)
    {
        var count = await _db.HashIncrementAsync(OnlineHashKey, userId, -1);
        if (count > 0)
            return false;

        await _db.HashDeleteAsync(OnlineHashKey, userId);
        return true;
    }

    public async Task<HashSet<int>> GetOnlineAsync(IEnumerable<int> userIds)
    {
        var ids = userIds.Distinct().ToArray();
        if (ids.Length == 0)
            return [];

        var fields = ids.Select(id => (RedisValue)id).ToArray();
        var values = await _db.HashGetAsync(OnlineHashKey, fields);

        var online = new HashSet<int>();
        for (var i = 0; i < ids.Length; i++)
        {
            if (!values[i].IsNullOrEmpty && (long)values[i] > 0)
                online.Add(ids[i]);
        }
        return online;
    }
}
