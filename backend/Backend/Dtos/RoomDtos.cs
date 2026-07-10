namespace Backend.Dtos;

public record CreateRoomRequest(int? MaxPlayers, bool? IsPrivate, string? Password, string? Ruleset);

public record JoinRoomRequest(string? Password);

public record RoomPlayerResponse(int UserId, string Email, bool IsHost);

public record RoomResponse(
    int RoomId,
    int HostId,
    string Status,
    int MaxPlayers,
    bool IsPrivate,
    string Ruleset,
    List<RoomPlayerResponse> Players,
    DateTime CreatedAt);

public record RoomListResponse(List<RoomResponse> Rooms, int Total, int Page);
