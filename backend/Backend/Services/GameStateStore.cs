using System.Text.Json;
using Backend.GameLogic;
using StackExchange.Redis;

namespace Backend.Services;

/// <summary>
/// 활성 게임 상태의 authoritative 저장소. 서버 인스턴스가 여러 대여도
/// 동일한 게임의 액션이 어느 인스턴스로 들어오든 같은 상태를 읽고 쓸 수 있도록 Redis에 둔다.
/// </summary>
public class GameStateStore(IConnectionMultiplexer redis)
{
    private static readonly LuaScript ReleaseLockScript = LuaScript.Prepare(
        "if redis.call('get', @key) == @token then return redis.call('del', @key) else return 0 end");

    private readonly IDatabase _db = redis.GetDatabase();

    private static string StateKey(int gameId) => $"game:{gameId}:state";
    private static string LockKey(int gameId) => $"game:{gameId}:lock";
    private static string ConnectedSetKey(int gameId) => $"game:{gameId}:connected";

    public async Task SaveAsync(int gameId, GameState state)
    {
        var json = JsonSerializer.Serialize(state);
        await _db.StringSetAsync(StateKey(gameId), json, TimeSpan.FromHours(6));
    }

    public async Task<GameState?> LoadAsync(int gameId)
    {
        var json = await _db.StringGetAsync(StateKey(gameId));
        return json.IsNullOrEmpty ? null : JsonSerializer.Deserialize<GameState>((string)json!);
    }

    public Task RemoveAsync(int gameId) =>
        Task.WhenAll(_db.KeyDeleteAsync(StateKey(gameId)), _db.KeyDeleteAsync(ConnectedSetKey(gameId)));

    /// <summary>
    /// 이 방(게임)에 실제로 Hub JoinRoom을 한 번이라도 호출한 유저를 기록한다.
    /// 매칭/참가 후 Hub에 한 번도 안 붙는 "유령 멤버"를 RoomDepartureWorker가 걸러내는 데 쓴다.
    /// </summary>
    public Task MarkPlayerConnectedAsync(int gameId, int userId) => _db.SetAddAsync(ConnectedSetKey(gameId), userId);

    public Task<bool> HasPlayerConnectedAsync(int gameId, int userId) => _db.SetContainsAsync(ConnectedSetKey(gameId), userId);

    /// <summary>
    /// 게임당 액션을 직렬화하기 위한 분산 락. using으로 감싸면 자동 해제된다.
    /// </summary>
    public async Task<IAsyncDisposable> AcquireLockAsync(int gameId, TimeSpan? timeout = null)
    {
        var token = Guid.NewGuid().ToString();
        var key = LockKey(gameId);
        var deadline = DateTime.UtcNow + (timeout ?? TimeSpan.FromSeconds(5));

        while (!await _db.StringSetAsync(key, token, TimeSpan.FromSeconds(10), When.NotExists))
        {
            if (DateTime.UtcNow > deadline)
                throw new TimeoutException("게임 상태 락을 획득하지 못했습니다.");
            await Task.Delay(30);
        }

        return new LockHandle(_db, key, token);
    }

    private sealed class LockHandle(IDatabase db, string key, string token) : IAsyncDisposable
    {
        public async ValueTask DisposeAsync() =>
            await db.ScriptEvaluateAsync(ReleaseLockScript, new { key = (RedisKey)key, token });
    }
}
