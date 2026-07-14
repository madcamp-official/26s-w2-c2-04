// POST/GET /friends/requests 응답을 파싱하는 모델. README 3절 스펙을 따릅니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_request.freezed.dart';
part 'friend_request.g.dart';

enum FriendRequestStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
}

@freezed
class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required int requestId,
    required int fromUserId,
    int? toUserId, // 보낸 요청(outgoing) 조회 시에만 채워짐
    String? fromNickname,
    @Default(FriendRequestStatus.pending) FriendRequestStatus status,
    required DateTime createdAt,
  }) = _FriendRequest;

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);
}
