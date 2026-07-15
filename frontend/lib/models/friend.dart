// GET /friends 응답의 friend 항목, SocialHub FriendStatusChanged 등에서 쓰는 모델.
// 친구/유저 API는 아직 백엔드에 없어(backend/Backend/Endpoints에 Friend 관련 엔드포인트
// 없음) README 3절/9절 스펙을 그대로 따릅니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend.freezed.dart';
part 'friend.g.dart';

enum FriendStatus {
  @JsonValue('online')
  online,
  @JsonValue('offline')
  offline,
  @JsonValue('in_game')
  inGame,
  @JsonValue('away')
  away,
}

@freezed
class Friend with _$Friend {
  const factory Friend({
    required int userId,
    required String nickname,
    String? avatarUrl,
    @Default(FriendStatus.offline) FriendStatus status,
  }) = _Friend;

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
}
