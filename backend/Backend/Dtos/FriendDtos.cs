namespace Backend.Dtos;

public record SendFriendRequestRequest(int TargetUserId);

public record FriendRequestResponse(
    int RequestId,
    int UserId,
    string Nickname,
    string? AvatarUrl,
    DateTime CreatedAt);

public record FriendRequestListResponse(
    List<FriendRequestResponse> Incoming,
    List<FriendRequestResponse> Outgoing);

public record FriendResponse(
    int UserId,
    string Nickname,
    string? AvatarUrl,
    bool Online,
    DateTime FriendsSince);

public record FriendListResponse(List<FriendResponse> Friends);

public record FriendSearchItemResponse(
    int UserId,
    string Nickname,
    string? AvatarUrl);

public record FriendSearchResponse(List<FriendSearchItemResponse> Users);

public record SendFriendMessageRequest(string Body);

public record FriendMessageResponse(
    int MessageId,
    int SenderId,
    int ReceiverId,
    string Body,
    DateTime CreatedAt);

public record FriendMessageListResponse(List<FriendMessageResponse> Messages, bool HasMore);

public record RoomInviteRequest(int TargetUserId);
