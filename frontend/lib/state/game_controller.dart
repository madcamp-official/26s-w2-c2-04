// GameHub(SignalR) 연결 상태와 실시간 GameState를 관리합니다. play.dart 화면은
// 이 컨트롤러만 구독하며, 토큰 획득/카드 구매/예약 등 모든 턴 액션은 이 컨트롤러를
// 통해 socket_service.dart로 전달됩니다.
// GameSocket을 생성자로 주입받으므로 테스트에서는 FakeGameSocket으로 대체할 수 있습니다.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_patch/json_patch.dart';
import '../models/game_state.dart';
import '../models/game_hub_event.dart';
import '../models/player.dart';
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

/// 게임 시작 전, GameHub에는 연결됐지만 아직 StateSync를 받지 못한 대기실 상태.
/// PlayerJoined/PlayerLeft로 갱신되는 실시간 참가자 목록을 들고 있습니다.
class GameWaitingRoom extends GameControllerState {
  final List<Player> players;
  const GameWaitingRoom(this.players);
}

class GameConnected extends GameControllerState {
  final GameState gameState;
  // 방 참가자 로스터(닉네임 조회용). GameState에는 닉네임이 없어서 GameWaitingRoom
  // 단계에서 이어받아 PlayerJoined/PlayerLeft로 계속 갱신합니다.
  final List<Player> players;
  final List<GameHubChatMessage> chatLog;
  final List<String>? pendingNobleChoice; // NobleChoiceRequired 대기 중인 후보 귀족
  final GameHubGameOver? gameOver;
  final String? notice; // 입장/퇴장/최종 라운드 등 일회성 알림 표시용

  const GameConnected({
    required this.gameState,
    this.players = const [],
    this.chatLog = const [],
    this.pendingNobleChoice,
    this.gameOver,
    this.notice,
  });

  GameConnected copyWith({
    GameState? gameState,
    List<Player>? players,
    List<GameHubChatMessage>? chatLog,
    List<String>? pendingNobleChoice,
    bool clearPendingNobleChoice = false,
    GameHubGameOver? gameOver,
    String? notice,
  }) {
    return GameConnected(
      gameState: gameState ?? this.gameState,
      players: players ?? this.players,
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

// 의도적으로 autoDispose가 아닙니다: 이 컨트롤러가 들고 있는 GameHub 연결은
// "방을 나가기 전까지는 화면(PlayScreen)이 잠깐 사라져도(뒤로가기 -> 좌하단
// 배지로 최소화) 계속 살아있어야" 합니다. autoDispose였다면 배지로 최소화하는
// 순간(위젯의 마지막 watch가 사라지는 순간) 연결이 끊겨(SocketService.dispose())
// 서버가 OnDisconnectedAsync로 "아직 방에 있는데도" PlayerLeft를 브로드캐스트해
// 다른 참가자 화면이 어긋나고, 배지를 다시 눌러 복귀했을 때 재연결/재입장이
// 반복되며 최종적으로 "나가기"를 눌러도 그 갱신이 다른 사람에게 정확히
// 전달되지 않는 문제로 이어졌습니다. 연결은 leaveRoom()에서만 명시적으로 끊습니다.
final gameControllerProvider =
    StateNotifierProvider<GameController, GameControllerState>((ref) {
  return GameController(SocketService(), ref.read(playServiceProvider));
});

class GameController extends StateNotifier<GameControllerState> {
  final GameSocket _socket;
  final PlayService _playService;
  StreamSubscription<GameHubEvent>? _sub;
  int? _roomId;
  int _lastSequence = 0;

  GameController(this._socket, this._playService)
      : super(const GameDisconnected());

  Future<void> connect({
    required int roomId,
    required String accessToken,
    List<Player> initialPlayers = const [],
  }) async {
    // 이미 이 방에 연결(중)이면 그대로 둔다 — 방 화면이 배지로 최소화됐다가
    // 다시 열릴 때마다(initState가 매번 connect()를 호출) 매번 새 SignalR
    // 연결을 만들고 예전 걸 버리면, 아직 살아있는 이전 연결이 뒤늦게 끊기면서
    // 서버가 (실제로는 계속 접속 중인) 이 유저의 PlayerLeft를 잘못 브로드캐스트할
    // 수 있다. 다른 방으로 갈아타는 경우(_roomId가 다름)에만 재연결한다.
    if (_roomId == roomId &&
        (state is GameConnecting ||
            state is GameWaitingRoom ||
            state is GameConnected)) {
      return;
    }

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
      // 이미 진행 중인 게임이면 connect() 도중 StateSync가 도착해 GameConnected로
      // 넘어가 있을 수 있으므로, 여전히 GameConnecting일 때만 대기실로 전이한다.
      if (state is GameConnecting) {
        state = GameWaitingRoom(initialPlayers);
      }
    } catch (e) {
      state = GameError(e.toString());
    }
  }

  /// 관전/재접속 폴백: GameHub 연결 전에 REST 스냅샷으로 먼저 화면을 채웁니다.
  Future<void> loadSnapshot(int gameId) async {
    final snapshot = await _playService.getGameState(gameId);
    _lastSequence = snapshot.sequence;
    state = GameConnected(gameState: snapshot, players: _currentRoomPlayers());
  }

  List<Player> _currentRoomPlayers() {
    final current = state;
    if (current is GameWaitingRoom) return current.players;
    if (current is GameConnected) return current.players;
    return const [];
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
      playerJoined: (userId, nickname) => _addRoomPlayer(userId, nickname),
      playerLeft: (userId, nickname) => _removeRoomPlayer(userId, nickname),
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
      state = GameConnected(gameState: syncedState, players: _currentRoomPlayers());
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

  void _addRoomPlayer(int userId, String nickname) {
    final current = state;
    if (current is GameWaitingRoom) {
      if (current.players.any((p) => p.id == userId)) return;
      state = GameWaitingRoom(
        [...current.players, Player(id: userId, nickname: nickname)],
      );
    } else if (current is GameConnected) {
      if (current.players.any((p) => p.id == userId)) {
        _setNotice('$nickname 님이 입장했습니다.');
        return;
      }
      state = current.copyWith(
        players: [...current.players, Player(id: userId, nickname: nickname)],
        notice: '$nickname 님이 입장했습니다.',
      );
    }
  }

  void _removeRoomPlayer(int userId, String nickname) {
    final current = state;
    if (current is GameWaitingRoom) {
      state = GameWaitingRoom(
        current.players.where((p) => p.id != userId).toList(),
      );
    } else if (current is GameConnected) {
      state = current.copyWith(
        players: current.players.where((p) => p.id != userId).toList(),
        notice: '$nickname 님이 퇴장했습니다.',
      );
    }
  }

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
    try {
      if (roomId != null) {
        await _socket.leaveRoom(roomId);
      }
    } finally {
      // 하나라도 실패해도(네트워크 순단 등) 로컬 상태는 반드시 정리한다 — 그래야
      // 호출부(play.dart 나가기 버튼)의 activeRoomProvider 초기화/화면 pop이
      // 예외로 인해 막히지 않는다. 연결을 완전히 끊어야 이후 다른 방에 새로
      // connect()할 때 이 방에 "이미 연결돼 있다"는 가드에 걸리지 않는다.
      await _socket.disconnect();
      _roomId = null;
      state = const GameDisconnected();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _socket.dispose();
    super.dispose();
  }
}
