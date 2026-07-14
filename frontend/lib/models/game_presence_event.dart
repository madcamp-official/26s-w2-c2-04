// 게임 진행 중 참가자 접속 상태 변화(연결 끊김/재접속/방장 이양) 이벤트.
// GameHub 콜백이지만 GameHubEvent(freezed union)와 달리 코드 생성(.freezed.dart)에
// 얽히지 않도록 순수 Dart 클래스로 따로 둔다 — 이탈/탈주 안내는 상태 스키마를
// 늘리지 않고 알림(notice)만 띄우면 충분하기 때문이다.

sealed class GamePresenceEvent {
  const GamePresenceEvent();
}

/// 진행 중 게임에서 한 참가자의 연결이 끊겼다(유예시간 내 재접속을 기다리는 중).
class PlayerDisconnectedEvent extends GamePresenceEvent {
  final int userId;
  final int graceSeconds;
  const PlayerDisconnectedEvent(this.userId, this.graceSeconds);
}

/// 유예시간 안에 다시 접속했다.
class PlayerReconnectedEvent extends GamePresenceEvent {
  final int userId;
  const PlayerReconnectedEvent(this.userId);
}

/// 방장이 나가서 다른 참가자에게 방장이 이양됐다.
class HostChangedEvent extends GamePresenceEvent {
  final int newHostId;
  const HostChangedEvent(this.newHostId);
}

/// hubConnection.on(method, args)의 원시 인자를 GamePresenceEvent로 정규화한다.
/// 해당 없는 method는 null을 돌려준다(호출부에서 무시).
GamePresenceEvent? parseGamePresenceEvent(String method, List<Object?>? args) {
  final raw = (args != null && args.isNotEmpty) ? args[0] : null;
  final json = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

  switch (method) {
    case 'PlayerDisconnected':
      return PlayerDisconnectedEvent(
        (json['userId'] as num).toInt(),
        (json['graceSeconds'] as num?)?.toInt() ?? 0,
      );
    case 'PlayerReconnected':
      return PlayerReconnectedEvent((json['userId'] as num).toInt());
    case 'HostChanged':
      return HostChangedEvent((json['newHostId'] as num).toInt());
    default:
      return null;
  }
}
