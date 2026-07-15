// 한 명의 플레이어를 나타내는 모델
// 로비, 룸, 게임 화면, 리더보드 등에서 공통으로 재사용됩니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    @JsonKey(name: 'userId') required int id, // 서버 응답 필드명은 userId
    required String nickname,
    String? avatarUrl, // 방/게임 목록 응답 등 일부 API는 avatarUrl을 내려주지 않음
    String? status, // online | offline | in_game | away, 친구 목록 등에서만 내려옴
    @Default(false) bool isReady, // 룸 대기 화면에서 "준비완료" 여부 (클라이언트 로컬 상태)
    @Default(false) bool isHost, // 방장 여부, room.hostId와 비교해 클라이언트에서 채움
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) =>
      _$PlayerFromJson(json);
}
