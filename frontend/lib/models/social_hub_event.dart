// SocialHub(/hubs/social, SignalR)의 ISocialClient 콜백(Server -> Client)을
// 표현하는 모델. game_hub_event.dart와 같은 패턴입니다. social_socket_service.dart가
// hubConnection.on(...)으로 받은 원시 인자를 SocialHubEvent.fromCallback으로
// 정규화해서 하나의 스트림으로 흘려보내면, friend_controller.dart가 구독합니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'friend.dart';

part 'social_hub_event.freezed.dart';

@freezed
class SocialHubEvent with _$SocialHubEvent {
  const factory SocialHubEvent.friendRequestReceived({
    required int requestId,
    required int fromUserId,
    required String fromNickname,
  }) = SocialHubFriendRequestReceived;

  const factory SocialHubEvent.friendRequestAccepted({
    required int friendUserId,
    required String friendNickname,
  }) = SocialHubFriendRequestAccepted;

  const factory SocialHubEvent.friendStatusChanged({
    required int friendUserId,
    required FriendStatus status,
  }) = SocialHubFriendStatusChanged;

  const factory SocialHubEvent.friendMessageReceived({
    required int fromUserId,
    required String text,
    required DateTime ts,
  }) = SocialHubFriendMessageReceived;
}

FriendStatus _parseFriendStatus(String value) => switch (value) {
      'online' => FriendStatus.online,
      'in_game' => FriendStatus.inGame,
      'away' => FriendStatus.away,
      _ => FriendStatus.offline,
    };

/// hubConnection.on(methodName, args) 콜백에서 넘어오는 원시 인자를
/// SocialHubEvent로 정규화합니다. args[0]은 README 9.2절 "응답" 컬럼의
/// JSON 객체 하나입니다.
SocialHubEvent? parseSocialHubEvent(String method, List<Object?>? args) {
  final raw = (args != null && args.isNotEmpty) ? args[0] : null;
  final json = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

  switch (method) {
    case 'FriendRequestReceived':
      return SocialHubEvent.friendRequestReceived(
        requestId: (json['requestId'] as num).toInt(),
        fromUserId: (json['fromUserId'] as num).toInt(),
        fromNickname: json['fromNickname'] as String,
      );
    case 'FriendRequestAccepted':
      return SocialHubEvent.friendRequestAccepted(
        friendUserId: (json['friendUserId'] as num).toInt(),
        friendNickname: json['friendNickname'] as String,
      );
    case 'FriendStatusChanged':
      return SocialHubEvent.friendStatusChanged(
        friendUserId: (json['friendUserId'] as num).toInt(),
        status: _parseFriendStatus(json['status'] as String),
      );
    case 'FriendMessageReceived':
      return SocialHubEvent.friendMessageReceived(
        fromUserId: (json['fromUserId'] as num).toInt(),
        text: json['text'] as String,
        ts: DateTime.parse(json['ts'] as String),
      );
    default:
      return null;
  }
}
