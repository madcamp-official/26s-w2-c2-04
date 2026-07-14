// GET/POST /friends/requests, POST /friends/requests/{id}/accept 응답을 파싱하는
// 모델. backend/Backend/Dtos/FriendDtos.cs의 FriendRequestResponse를 그대로
// 반영합니다 — incoming/outgoing 양쪽에 같은 모양을 쓰고 상대방 id/닉네임을
// userId/nickname 하나로 표현합니다(방향은 어느 목록에서 왔는지로 구분).
// /friends/requests는 항상 PENDING 상태만 돌려주므로 status 필드는 없습니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_request.freezed.dart';
part 'friend_request.g.dart';

@freezed
class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required int requestId,
    required int userId, // 상대방 id. incoming이면 보낸 사람, outgoing이면 받는 사람.
    required String nickname,
    String? avatarUrl,
    required DateTime createdAt,
  }) = _FriendRequest;

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);
}
