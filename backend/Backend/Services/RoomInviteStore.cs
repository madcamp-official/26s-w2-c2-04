using StackExchange.Redis;

namespace Backend.Services;

/// <summary>
/// 비공개 방 초대 시 비밀번호 없이 입장을 허용하기 위한 단기 토큰. 초대 발급 시 SET,
/// 입장 시 GETDEL로 소비한다(1회용, TTL 만료 시 자동 소멸).
/// </summary>
public class RoomInviteStore(IConnectionMultiplexer redis)
{
    private static readonly TimeSpan InviteTtl = TimeSpan.FromMinutes(10);

    private readonly IDatabase _db = redis.GetDatabase();

    private static string Key(int roomId, int userId) => $"room:{roomId}:invite:{userId}";

    public Task GrantAsync(int roomId, int userId) =>
        _db.StringSetAsync(Key(roomId, userId), 1, InviteTtl);

    public Task<bool> ConsumeAsync(int roomId, int userId) =>
        _db.KeyDeleteAsync(Key(roomId, userId));
}
