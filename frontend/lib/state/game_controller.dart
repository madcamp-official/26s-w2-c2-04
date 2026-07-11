// GameHub(SignalR) 연결 상태와 실시간 GameState를 관리합니다. play.dart 화면은
// 이 컨트롤러만 구독하며, 토큰 획득/카드 구매/예약 등 모든 턴 액션은 이 컨트롤러를
// 통해 socket_service.dart로 전달됩니다.
// GameSocket을 생성자로 주입받으므로 테스트에서는 FakeGameSocket으로 대체할 수 있습니다.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_patch/json_patch.dart';
import '../models/game_state.dart';
import '../models/game_hub_event.dart';
import '../services/socket_service.dart';
import '../services/play_service.dart';

sealed class GameControllerState {
  const GameControllerState();
}

class GameDisconnected extends GameControllerState {
  const GameDisconnected();
}

class GameConnecting extends GameControllerState {
  const GameConnecting();
}

class GameConnected extends GameControllerState {
  final GameState gameState;
  final List<GameHubChatMessage> chatLog;
  final List<String>? pendingNobleChoice; // NobleChoiceRequired 대기 중인 후보 귀족
  final GameHubGameOver? gameOver;
  final String? notice; // 입장/퇴장/최종 라운드 등 일회성 알림 표시용

  const GameConnected({
    required this.gameState,
    this.chatLog = const [],
    this.pendingNobleChoice,
    this.gameOver,
    this.notice,
  });

  GameConnected copyWith({
    GameState? gameState,
    List<GameHubChatMessage>? chatLog,
    List<String>? pendingNobleChoice,
    bool clearPendingNobleChoice = false,
    GameHubGameOver? gameOver,
    String? notice,
  }) {
    return GameConnected(
      gameState: gameState ?? this.gameState,
      chatLog: chatLog ?? this.chatLog,
      pendingNobleChoice: clearPendingNobleChoice
          ? null
          : (pendingNobleChoice ?? this.pendingNobleChoice),
      gameOver: gameOver ?? this.gameOver,
      notice: notice ?? this.notice,
    );
  }
}

class GameError extends GameControllerState {
  final String message;
  const GameError(this.message);
}

final playServiceProvider = Provider((ref) => PlayService());

final gameControllerProvider =
    StateNotifierProvider.autoDispose<GameController, GameControllerState>(
        (ref) {
  return GameController(SocketService(), ref.read(playServiceProvider));
});

class GameController extends StateNotifier<GameControllerState> {
  final GameSocket _socket;
  final PlayService _playService;
  StreamSubscription<GameHubEvent>? _sub;
  String? _roomId;
  int _lastSequence = 0;

  GameController(this._socket, this._playService)
      : super(const GameDisconnected());

  Future<void> connect({
    required String roomId,
    required String accessToken,
  }) async {
    state = const GameConnecting();
    _roomId = roomId;

    await _sub?.cancel();
    _sub = _socket.events.listen(_onEvent);

    final socket = _socket;
    if (socket is SocketService) {
      socket.onReconnected(() => socket.requestResync(_lastSequence));
    }

    try {
      await _socket.connect(roomId: roomId, accessToken: accessToken);
    } catch (e) {
      state = GameError(e.toString());
    }
  }

  /// 관전/재접속 폴백: GameHub 연결 전에 REST 스냅샷으로 먼저 화면을 채웁니다.
  Future<void> loadSnapshot(String gameId) async {
    final snapshot = await _playService.getGameState(gameId);
    _lastSequence = snapshot.sequence;
    state = GameConnected(gameState: snapshot);
  }

  void _onEvent(GameHubEvent event) {
    event.when(
      stateSync: (syncedState, patch, sequence) =>
          _applyStateSync(syncedState, patch, sequence),
      actionResult: (success, error, patch) {
        if (patch != null) _applyPatch(patch);
        if (!success && error != null) _setNotice('오류: $error');
      },
      turnChanged: (currentPlayerId, turnNumber) => _mutateGameState(
        (gs) => gs.copyWith(
          currentPlayerId: currentPlayerId,
          turnNumber: turnNumber,
        ),
      ),
      nobleAwarded: (playerId, nobleId) {
        // 실제 반영은 뒤따르는 StateSync 델타로 이뤄집니다.
      },
      nobleChoiceRequired: (playerId, candidateNobleIds) =>
          _updateConnected(
        (c) => c.copyWith(pendingNobleChoice: candidateNobleIds),
      ),
      playerJoined: (userId, nickname) => _setNotice('$nickname 님이 입장했습니다.'),
      playerLeft: (userId, nickname) => _setNotice('$nickname 님이 퇴장했습니다.'),
      finalRoundTriggered: (triggeredBy, lastTurnPlayerId) =>
          _setNotice('마지막 라운드가 시작되었습니다.'),
      gameOver: (winnerId, finalScores, tieBreakReason) => _updateConnected(
        (c) => c.copyWith(gameOver: event as GameHubGameOver),
      ),
      chatMessage: (playerId, text, ts) => _updateConnected(
        (c) => c.copyWith(
          chatLog: [...c.chatLog, event as GameHubChatMessage],
        ),
      ),
      emoteReceived: (playerId, emoteId, ts) {},
      errorOccurred: (code, message) => _setNotice('오류: $message'),
    );
  }

  void _applyStateSync(
    GameState? syncedState,
    List<Map<String, dynamic>>? patch,
    int sequence,
  ) {
    if (syncedState != null) {
      _lastSequence = sequence;
      state = GameConnected(gameState: syncedState);
      return;
    }
    if (patch != null) {
      _applyPatch(patch, sequence);
    }
  }

  void _applyPatch(List<Map<String, dynamic>> patch, [int? sequence]) {
    final current = state;
    if (current is! GameConnected) return;
    final rawState = current.gameState.toJson();
    final patched =
        JsonPatch.apply(rawState, patch, strict: false) as Map<String, dynamic>;
    if (sequence != null) _lastSequence = sequence;
    state = current.copyWith(gameState: GameState.fromJson(patched));
  }

  void _mutateGameState(GameState Function(GameState) update) {
    final current = state;
    if (current is! GameConnected) return;
    state = current.copyWith(gameState: update(current.gameState));
  }

  void _updateConnected(GameConnected Function(GameConnected) update) {
    final current = state;
    if (current is! GameConnected) return;
    state = update(current);
  }

  void _setNotice(String notice) => _updateConnected(
        (c) => c.copyWith(notice: notice),
      );

  Future<void> takeTokens(List<String> gems) => _socket.takeTokens(gems);

  Future<void> purchaseCard({required String cardId, required String source}) =>
      _socket.purchaseCard(cardId: cardId, source: source);

  Future<void> reserveCard({String? cardId, int? tier}) =>
      _socket.reserveCard(cardId: cardId, tier: tier);

  Future<void> discardTokens(List<String> gems) =>
      _socket.discardTokens(gems);

  Future<void> claimNoble(String nobleId) async {
    await _socket.claimNoble(nobleId);
    _updateConnected((c) => c.copyWith(clearPendingNobleChoice: true));
  }

  Future<void> sendChatMessage(String text) => _socket.sendChatMessage(text);

  Future<void> sendEmote(String emoteId) => _socket.sendEmote(emoteId);

  Future<void> leaveRoom() async {
    final roomId = _roomId;
    if (roomId != null) {
      await _socket.leaveRoom(roomId);
    }
    state = const GameDisconnected();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _socket.dispose();
    super.dispose();
  }
}
