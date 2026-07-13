using System.Text.Json;
using Backend.GameLogic;
using StackExchange.Redis;

namespace Backend.Services;

/// <summary>
/// 랭킹전 매치메이킹 대기열의 Redis 저장소. 인원수별로 별도 큐를 두어 서버 인스턴스가
/// 여러 대여도 동일한 대기열을 공유하고, 매칭 결과는 유저별 단기 키에 남겨 상태 조회/재접속에 대비한다.
/// </summary>
public class MatchmakingQueueStore(IConnectionMultiplexer redis)
{
    private static readonly int[] PlayerCounts = [2, 3, 4];
    private static readonly TimeSpan MatchResultTtl = TimeSpan.FromMinutes(2);
    private static readonly TimeSpan LockTtl = TimeSpan.FromSeconds(10);

    private static readonly LuaScript GetAndDeleteScript = LuaScript.Prepare(
        "local v = redis.call('get', @key) if v then redis.call('del', @key) end return v");

    private readonly IDatabase _db = redis.GetDatabase();

    private static string QueueKey(int playerCount) => $"matchmaking:queue:{playerCount}";
    private static string LockKey(int playerCount) => $"matchmaking:lock:{playerCount}";
    private static string MatchResultKey(int userId) => $"matchmaking:matched:{userId}";

    public async Task<int?> FindQueuedPlayerCountAsync(int userId)
    {
        foreach (var playerCount in PlayerCounts)
        {
            if (await _db.HashExistsAsync(QueueKey(playerCount), userId))
                return playerCount;
        }
        return null;
    }

    public async Task EnqueueAsync(int playerCount, int userId, int mmr)
    {
        var entry = new QueueEntry(userId, mmr, DateTimeOffset.UtcNow.ToUnixTimeMilliseconds());
        await _db.HashSetAsync(QueueKey(playerCount), userId, JsonSerializer.Serialize(entry));
    }

    public async Task<bool> DequeueAsync(int playerCount, int userId) =>
        await _db.HashDeleteAsync(QueueKey(playerCount), userId);

    public async Task RemoveManyAsync(int playerCount, IEnumerable<int> userIds)
    {
        var fields = userIds.Select(id => (RedisValue)id).ToArray();
        if (fields.Length > 0)
            await _db.HashDeleteAsync(QueueKey(playerCount), fields);
    }

    public async Task<QueueEntry?> GetEntryAsync(int playerCount, int userId)
    {
        var value = await _db.HashGetAsync(QueueKey(playerCount), userId);
        return value.IsNullOrEmpty ? null : JsonSerializer.Deserialize<QueueEntry>((string)value!);
    }

    public async Task<List<QueueEntry>> GetAllAsync(int playerCount)
    {
        var entries = await _db.HashGetAllAsync(QueueKey(playerCount));
        return entries
            .Select(e => JsonSerializer.Deserialize<QueueEntry>((string)e.Value!)!)
            .ToList();
    }

    public async Task SetMatchResultAsync(int userId, int roomId) =>
        await _db.StringSetAsync(MatchResultKey(userId), roomId, MatchResultTtl);

    public async Task<int?> ConsumeMatchResultAsync(int userId)
    {
        var result = await _db.ScriptEvaluateAsync(GetAndDeleteScript, new { key = (RedisKey)MatchResultKey(userId) });
        return result.IsNull ? null : (int)result;
    }

    /// <summary>
    /// 인원수별 매칭 라운드를 한 인스턴스만 처리하도록 하는 짧은 분산 락. 획득 실패 시 null.
    /// </summary>
    public async Task<IAsyncDisposable?> TryAcquireLockAsync(int playerCount)
    {
        var token = Guid.NewGuid().ToString();
        var key = LockKey(playerCount);
        return await _db.LockTakeAsync(key, token, LockTtl)
            ? new LockHandle(_db, key, token)
            : null;
    }

    private sealed class LockHandle(IDatabase db, string key, string token) : IAsyncDisposable
    {
        public async ValueTask DisposeAsync() => await db.LockReleaseAsync(key, token);
    }
}
