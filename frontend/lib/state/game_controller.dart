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
import '../services/room_service.dart';
import 'lobby_controller.dart';

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
  // 대기실 "준비" 체크를 마친 유저 id 집합. 방장은 이 방 인원(본인 제외) 전원이
  // 여기 들어와야 시작할 수 있다. 백엔드에 전용 엔드포인트가 없어 GameHub의
  // 범용 이모트 채널(SendEmote/EmoteReceived)을 준비 신호 용도로 재사용한다.
  final Set<int> readyPlayerIds;
  const GameWaitingRoom(this.players, {this.readyPlayerIds = const {}});
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
  return GameController(
    SocketService(),
    ref.read(playServiceProvider),
    ref.read(roomServiceProvider),
  );
});

class GameController extends StateNotifier<GameControllerState> {
  final GameSocket _socket;
  final PlayService _playService;
  final RoomService _roomService;
  StreamSubscription<GameHubEvent>? _sub;
  int? _roomId;
  int _lastSequence = 0;
  // connect() 인자로 받은 방 참가자 로스터. 이미 게임이 진행 중인 방에
  // autoConnect(랭크 매칭)로 들어가면, connect() 도중 StateSync가 GameWaitingRoom
  // 전이보다 먼저 도착할 수 있다 — 그 경우 _currentRoomPlayers()가 아직 아무
  // 상태에도 반영되지 않은 이 값을 대신 써야, GameConnected.players가 빈 채로
  // 굳어 닉네임이 전부 "User {id}"로 보이는 일을 막을 수 있다.
  List<Player> _initialPlayers = const [];

  GameController(this._socket, this._playService, this._roomService)
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
    _initialPlayers = initialPlayers;

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
        // 서버 응답(RoomPlayerResponse.isReady)에서 이미 채워진 준비 상태를
        // 그대로 시드한다 — 재입장/뒤늦은 연결에서도 준비 현황이 맞춰진다.
        state = GameWaitingRoom(
          initialPlayers,
          readyPlayerIds:
              initialPlayers.where((p) => p.isReady).map((p) => p.id).toSet(),
        );
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
    return _initialPlayers;
  }

  void _onEvent(GameHubEvent event) {
    event.when(
      stateSync: (syncedState, patch, sequence) =>
          _applyStateSync(syncedState, patch, sequence),
      actionResult: (success, error, patch) {
        if (patch != null) _applyPatch(patch);
        if (!success && error != null) _setNotice('오류: $error');
      },
      turnChanged: (currentPlayerId, turnNumber, reason) =>
          _handleTurnChanged(currentPlayerId, turnNumber, reason),
      nobleAwarded: (playerId, nobleId) {
        // 실제 반영은 뒤따르는 StateSync 델타로 이뤄집니다.
      },
      nobleChoiceRequired: (playerId, candidateNobleIds) =>
          _updateConnected(
        (c) => c.copyWith(pendingNobleChoice: candidateNobleIds),
      ),
      playerJoined: (userId, nickname) => _addRoomPlayer(userId, nickname),
      playerLeft: (userId, nickname) => _removeRoomPlayer(userId, nickname),
      playerReadyChanged: (userId, ready) => _updateReady(userId, ready),
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
      // 이모트 채널은 준비 기능에서 더 이상 쓰지 않는다(전용 REST + PlayerReadyChanged로
      // 대체). 실제 이모트 UI가 생기면 여기서 처리하면 된다.
      emoteReceived: (playerId, emoteId, ts) {},
      errorOccurred: (code, message) => _setNotice('오류: $message'),
    );
  }

  void _updateReady(int playerId, bool ready) {
    final current = state;
    if (current is! GameWaitingRoom) return;
    final next = Set<int>.from(current.readyPlayerIds);
    if (ready) {
      next.add(playerId);
    } else {
      next.remove(playerId);
    }
    state = GameWaitingRoom(current.players, readyPlayerIds: next);
  }

  /// 대기실에서 "준비" 토글(README 4/8절). POST /rooms/{id}/ready만 호출하면,
  /// 서버가 방 그룹(GameHub) 전체에 PlayerReadyChanged를 브로드캐스트하고 호출한
  /// 본인의 연결도 그 그룹 멤버라 그대로 되돌려받으므로, 낙관적 로컬 업데이트
  /// 없이 _updateReady로 상태가 맞춰진다.
  Future<void> setReady({required bool ready}) async {
    final roomId = _roomId;
    if (roomId == null) return;
    await _roomService.setReady(roomId, ready);
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

  /// TurnChanged(reason: "timeout")는 서버가 제한시간 초과로 대신 턴을 넘긴
  /// 경우다. 노블 선택 대기 중이었다면 서버가 이미 포기 처리했으므로
  /// pendingNobleChoice UI도 같이 닫아야 하고("[8]"), 누구 턴이 시간초과됐는지
  /// 안내 메시지를 띄운다.
  void _handleTurnChanged(int currentPlayerId, int turnNumber, String? reason) {
    final current = state;
    final previousPlayerId =
        current is GameConnected ? current.gameState.currentPlayerId : null;

    _mutateGameState(
      (gs) => gs.copyWith(currentPlayerId: currentPlayerId, turnNumber: turnNumber),
    );

    if (reason == 'timeout') {
      final nickname = current is GameConnected && previousPlayerId != null
          ? _nicknameOf(current.players, previousPlayerId)
          : null;
      _updateConnected(
        (c) => c.copyWith(
          notice: '${nickname ?? "상대방"} 님이 시간 초과로 턴을 넘겼습니다.',
          clearPendingNobleChoice: true,
        ),
      );
    }
  }

  String? _nicknameOf(List<Player> players, int userId) {
    for (final p in players) {
      if (p.id == userId) return p.nickname;
    }
    return null;
  }

  void _addRoomPlayer(int userId, String nickname) {
    final current = state;
    if (current is GameWaitingRoom) {
      if (current.players.any((p) => p.id == userId)) return;
      state = GameWaitingRoom(
        [...current.players, Player(id: userId, nickname: nickname)],
        readyPlayerIds: current.readyPlayerIds,
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
        readyPlayerIds: current.readyPlayerIds.where((id) => id != userId).toSet(),
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
