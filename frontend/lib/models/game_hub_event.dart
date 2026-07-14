// GameHub(SignalR, /hubs/game)의 IGameClient 콜백(Server -> Client)을 표현하는
// 모델. socket_service.dart가 hubConnection.on(...)으로 받은 원시 인자를
// GameHubEvent.fromCallback으로 정규화해서 하나의 스트림으로 흘려보내면,
// game_controller.dart가 이를 구독해 상태를 갱신합니다.
// (game_event.dart는 방 목록/입장/준비 등 로비 단계의 초기 설계용 모델이라
// 실제 GameHub 프로토콜과는 별개로 남겨둡니다.)

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'game_state.dart';

part 'game_hub_event.freezed.dart';

@freezed
class FinalScore with _$FinalScore {
  const factory FinalScore({
    required int userId,
    required int score,
  }) = _FinalScore;
}

@freezed
class GameHubEvent with _$GameHubEvent {
  /// StateSync: full이면 state에 GameState 전체, delta면 patch(JSON Patch)만 옴
  const factory GameHubEvent.stateSync({
    GameState? state,
    List<Map<String, dynamic>>? patch,
    required int sequence,
  }) = GameHubStateSync;

  const factory GameHubEvent.actionResult({
    required bool success,
    String? error,
    List<Map<String, dynamic>>? patch,
  }) = GameHubActionResult;

  const factory GameHubEvent.turnChanged({
    required int currentPlayerId,
    required int turnNumber,
    // "action" | "timeout". RoomDepartureService가 보내는 TurnChanged(참가자 퇴장으로
    // 인한 강제 턴 넘김)에는 이 필드가 아예 없어 null일 수 있다.
    String? reason,
  }) = GameHubTurnChanged;

  const factory GameHubEvent.nobleAwarded({
    required int playerId,
    required String nobleId,
  }) = GameHubNobleAwarded;

  const factory GameHubEvent.nobleChoiceRequired({
    required int playerId,
    required List<String> candidateNobleIds,
  }) = GameHubNobleChoiceRequired;

  const factory GameHubEvent.playerJoined({
    required int userId,
    required String nickname,
  }) = GameHubPlayerJoined;

  const factory GameHubEvent.playerLeft({
    required int userId,
    required String nickname,
  }) = GameHubPlayerLeft;

  /// 대기실 "준비" 상태 변경(README 4/8절). 방장이 POST /rooms/{id}/ready로
  /// 갱신하면 서버가 방 그룹 전체(발신자 본인 포함)에 브로드캐스트한다.
  const factory GameHubEvent.playerReadyChanged({
    required int userId,
    required bool ready,
  }) = GameHubPlayerReadyChanged;

  const factory GameHubEvent.finalRoundTriggered({
    required int triggeredBy,
    int? lastTurnPlayerId,
  }) = GameHubFinalRoundTriggered;

  const factory GameHubEvent.gameOver({
    required int winnerId,
    required List<FinalScore> finalScores,
    String? tieBreakReason,
  }) = GameHubGameOver;

  const factory GameHubEvent.chatMessage({
    required int playerId,
    required String text,
    required DateTime ts,
  }) = GameHubChatMessage;

  const factory GameHubEvent.emoteReceived({
    required int playerId,
    required String emoteId,
    required DateTime ts,
  }) = GameHubEmoteReceived;

  const factory GameHubEvent.errorOccurred({
    required String code,
    required String message,
  }) = GameHubErrorOccurred;
}

/// hubConnection.on(methodName, args) 콜백에서 넘어오는 원시 인자를
/// GameHubEvent로 정규화합니다. args[0]은 대부분 README 8절 "응답" 컬럼의
/// JSON 객체 하나입니다.
GameHubEvent parseGameHubEvent(String method, List<Object?>? args) {
  final raw = (args != null && args.isNotEmpty) ? args[0] : null;
  final json = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

  List<Map<String, dynamic>>? patchOf(dynamic value) {
    if (value is! List) return null;
    return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  switch (method) {
    case 'StateSync':
      return GameHubEvent.stateSync(
        state: json['state'] is Map
            ? GameState.fromJson(Map<String, dynamic>.from(json['state']))
            : null,
        patch: patchOf(json['patch']),
        sequence: json['sequence'] as int,
      );
    case 'ActionResult':
      return GameHubEvent.actionResult(
        success: json['success'] as bool? ?? false,
        error: json['error'] as String?,
        patch: patchOf(json['patch']),
      );
    case 'TurnChanged':
      return GameHubEvent.turnChanged(
        currentPlayerId: (json['currentPlayerId'] as num).toInt(),
        turnNumber: json['turnNumber'] as int,
        reason: json['reason'] as String?,
      );
    case 'NobleAwarded':
      return GameHubEvent.nobleAwarded(
        playerId: (json['playerId'] as num).toInt(),
        nobleId: json['nobleId'] as String,
      );
    case 'NobleChoiceRequired':
      return GameHubEvent.nobleChoiceRequired(
        playerId: (json['playerId'] as num).toInt(),
        candidateNobleIds: (json['candidateNobleIds'] as List)
            .map((e) => e as String)
            .toList(),
      );
    case 'PlayerJoined':
      return GameHubEvent.playerJoined(
        userId: (json['userId'] as num).toInt(),
        nickname: json['nickname'] as String,
      );
    case 'PlayerLeft':
      return GameHubEvent.playerLeft(
        userId: (json['userId'] as num).toInt(),
        nickname: json['nickname'] as String,
      );
    case 'PlayerReadyChanged':
      return GameHubEvent.playerReadyChanged(
        userId: (json['userId'] as num).toInt(),
        ready: json['ready'] as bool,
      );
    case 'FinalRoundTriggered':
      return GameHubEvent.finalRoundTriggered(
        triggeredBy: (json['triggeredBy'] as num).toInt(),
        lastTurnPlayerId: (json['lastTurnPlayerId'] as num?)?.toInt(),
      );
    case 'GameOver':
      return GameHubEvent.gameOver(
        winnerId: (json['winnerId'] as num).toInt(),
        finalScores: (json['finalScores'] as List)
            .map((e) => FinalScore(
                  userId: ((e as Map)['userId'] as num).toInt(),
                  score: e['score'] as int,
                ))
            .toList(),
        tieBreakReason: json['tieBreakReason'] as String?,
      );
    case 'ChatMessage':
      return GameHubEvent.chatMessage(
        playerId: (json['playerId'] as num).toInt(),
        text: json['text'] as String,
        ts: DateTime.parse(json['ts'] as String),
      );
    case 'EmoteReceived':
      return GameHubEvent.emoteReceived(
        playerId: (json['playerId'] as num).toInt(),
        emoteId: json['emoteId'] as String,
        ts: DateTime.parse(json['ts'] as String),
      );
    case 'ErrorOccurred':
      return GameHubEvent.errorOccurred(
        code: json['code'] as String,
        message: json['message'] as String,
      );
    default:
      return GameHubEvent.errorOccurred(
        code: 'UNKNOWN_EVENT',
        message: '알 수 없는 GameHub 이벤트: $method',
      );
  }
}
