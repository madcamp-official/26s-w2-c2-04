// GET/POST /friends/{userId}/messages 응답을 파싱하는 모델.
// backend/Backend/Dtos/FriendDtos.cs의 FriendMessageResponse를 그대로 반영합니다.
// SocialHub.FriendMessageReceived(실시간 푸시)는 같은 메시지를 저장한 뒤 보내는
// 것이지만 페이로드 모양이 달라(social_hub_event.dart 참고) 이 모델과는 별개입니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_message.freezed.dart';
part 'friend_message.g.dart';

@freezed
class FriendMessage with _$FriendMessage {
  const factory FriendMessage({
    required int messageId,
    required int senderId,
    required int receiverId,
    required String body,
    required DateTime createdAt,
  }) = _FriendMessage;

  factory FriendMessage.fromJson(Map<String, dynamic> json) =>
      _$FriendMessageFromJson(json);
}
