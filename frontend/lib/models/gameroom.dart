// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';

part 'gameroom.freezed.dart';
part 'gameroom.g.dart';

/// 룸(대기방) 상태를 나타내는 모델.
/// 로비 화면의 방 목록, 룸 화면의 현재 상태 표시에 사용됩니다.
/// GET/POST /rooms 응답과 필드가 매칭됩니다.
enum RoomStatus {
  @JsonValue('WAITING')
  waiting,
  @JsonValue('PLAYING')
  playing,
}

@freezed
class GameRoom with _$GameRoom {
  const GameRoom._();

  const factory GameRoom({
    required String roomId,
    required String hostId, // 방장 판별용, player.id와 비교해서 사용
    required List<Player> players,
    required DateTime createdAt,
    @Default(4) int maxPlayers, // 스플렌더는 2~4인
    @Default(RoomStatus.waiting) RoomStatus status,
    @Default(false) bool isPrivate,
  }) = _GameRoom;

  factory GameRoom.fromJson(Map<String, dynamic> json) =>
      _$GameRoomFromJson(json);

  bool isHostOf(Player player) => player.id == hostId;
}
