import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';
import 'gameroom.dart';

part 'game_event.freezed.dart';
part 'game_event.g.dart';

/// 서버 <-> 클라이언트 간 웹소켓으로 주고받는 이벤트.
/// 오늘 MVP 범위: 방 목록/입장/퇴장/준비 상태까지만 다룹니다.
/// (카드 구매, 턴 진행 등 실제 게임 이벤트는 Flame 보드 작업 시 추가)
@freezed
class GameEvent with _$GameEvent {
  /// 서버가 로비 화면에 현재 방 목록을 내려줄 때
  const factory GameEvent.roomListUpdated({
    required List<GameRoom> rooms,
  }) = RoomListUpdated;

  /// 특정 룸의 상태(플레이어 입장/퇴장/준비)가 바뀌었을 때
  const factory GameEvent.roomUpdated({
    required GameRoom room,
  }) = RoomUpdated;

  /// 클라이언트가 방에 참가를 요청할 때
  const factory GameEvent.joinRoom({
    required String roomId,
    required Player player,
  }) = JoinRoom;

  /// 클라이언트가 준비완료 토글을 요청할 때
  const factory GameEvent.toggleReady({
    required String roomId,
    required String playerId,
  }) = ToggleReady;

  /// 연결 오류/끊김 등을 클라이언트에 알릴 때
  const factory GameEvent.error({
    required String message,
  }) = GameEventError;

  factory GameEvent.fromJson(Map<String, dynamic> json) =>
      _$GameEventFromJson(json);
}
