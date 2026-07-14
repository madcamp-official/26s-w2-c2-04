namespace Backend.Dtos;

public record CreateRoomRequest(int? MaxPlayers, bool? IsPrivate, string? Password);

public record JoinRoomRequest(string? Password);

public record ReadyRequest(bool Ready);

public record RoomPlayerResponse(int UserId, string Nickname, bool IsHost, bool IsReady);

public record RoomResponse(
    int RoomId,
    int HostId,
    string Status,
    int MaxPlayers,
    bool IsPrivate,
    List<RoomPlayerResponse> Players,
    DateTime CreatedAt);

public record RoomListItemResponse(
    int RoomId,
    int HostId,
    int MaxPlayers,
    bool IsPrivate,
    List<RoomPlayerResponse> Players,
    DateTime CreatedAt);

public record RoomListResponse(List<RoomListItemResponse> Rooms, int Total, int Page);

public record StartGameResponse(int GameId, string Phase);
