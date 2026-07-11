using Backend.GameLogic;

namespace Backend.Hubs;

/// <summary>
/// GameHub와 REST(RoomEndpoints)가 같은 그룹 이름·메시지 형식을 쓰기 위한 공용 헬퍼.
/// REST 쪽에서도 게임 시작 시점에 이 그룹으로 직접 브로드캐스트한다.
/// </summary>
public static class GameHubMessages
{
    public static string GroupName(int roomId) => $"room-{roomId}";

    public static object BuildFullSync(GameState state) => new
    {
        type = "full",
        state,
        sequence = state.Sequence,
    };
}
