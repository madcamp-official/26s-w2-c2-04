import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:splendor_multiplayer/models/game_hub_event.dart';
import 'package:splendor_multiplayer/models/game_state.dart';
import 'package:splendor_multiplayer/models/gameroom.dart';
import 'package:splendor_multiplayer/models/player.dart';
import 'package:splendor_multiplayer/services/play_service.dart';
import 'package:splendor_multiplayer/services/room_service.dart';
import 'package:splendor_multiplayer/services/socket_service.dart';
import 'package:splendor_multiplayer/state/game_controller.dart';

class _FakeGameSocket implements GameSocket {
  final _controller = StreamController<GameHubEvent>.broadcast();
  final List<String> calls = [];

  /// 이미 진행 중인 방에 연결할 때, 서버가 StateSync를 connect() 응답보다 먼저
  /// 보내는 상황(랭크 매칭 autoConnect)을 재현하기 위한 훅.
  void Function()? duringConnect;

  @override
  Stream<GameHubEvent> get events => _controller.stream;

  @override
  HubConnectionState? get connectionState => HubConnectionState.Connected;

  @override
  Future<void> connect({
    required int roomId,
    required String accessToken,
  }) async {
    calls.add('connect($roomId)');
    duringConnect?.call();
  }

  @override
  Future<void> leaveRoom(int roomId) async => calls.add('leaveRoom');

  @override
  Future<void> disconnect() async => calls.add('disconnect');

  @override
  Future<void> takeTokens(List<String> gems) async => calls.add('takeTokens');

  @override
  Future<void> purchaseCard({
    required String cardId,
    required String source,
  }) async =>
      calls.add('purchaseCard');

  @override
  Future<void> reserveCard({String? cardId, int? tier}) async =>
      calls.add('reserveCard');

  @override
  Future<void> discardTokens(List<String> gems) async =>
      calls.add('discardTokens');

  @override
  Future<void> claimNoble(String nobleId) async => calls.add('claimNoble');

  @override
  Future<void> sendChatMessage(String text) async =>
      calls.add('sendChatMessage');

  @override
  Future<void> sendEmote(String emoteId) async => calls.add('sendEmote');

  @override
  Future<void> requestResync(int lastSequence) async =>
      calls.add('requestResync');

  @override
  Future<void> dispose() async => _controller.close();

  void emit(GameHubEvent event) => _controller.add(event);
}

class _FakeRoomService implements RoomService {
  final List<String> calls = [];

  GameRoom _room(int id) => GameRoom(
        roomId: id,
        hostId: 9000,
        players: const [],
        createdAt: DateTime.utc(2026, 7, 10),
      );

  @override
  Future<GameRoom> setReady(int roomId, bool ready) async {
    calls.add('setReady($roomId,$ready)');
    return _room(roomId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not stubbed');
}

GameState _fullState({int sequence = 1}) => GameState(
      gameId: 9911,
      phase: GamePhase.playing,
      currentPlayerId: 1024,
      sequence: sequence,
      playerOrder: const [1024],
      players: const {
        '1024': GamePlayerState(
          userId: 1024,
          points: 0,
          tokens: {'diamond': 1},
        ),
      },
    );

void main() {
  late _FakeGameSocket socket;
  late _FakeRoomService roomService;
  late GameController controller;

  setUp(() {
    socket = _FakeGameSocket();
    roomService = _FakeRoomService();
    controller = GameController(socket, PlayService(), roomService);
  });

  test('connect는 소켓에 연결을 위임한다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    expect(socket.calls, contains('connect(5566)'));
  });

  test('connect 시 initialPlayers의 isReady로 readyPlayerIds를 시드한다', () async {
    await controller.connect(
      roomId: 5566,
      accessToken: 'token',
      initialPlayers: const [
        Player(id: 1, nickname: '방장'),
        Player(id: 2, nickname: '준비완료', isReady: true),
      ],
    );

    final state = controller.state as GameWaitingRoom;
    expect(state.readyPlayerIds, {2});
  });

  test('setReady는 POST /rooms/{id}/ready(RoomService)로 위임한다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');

    await controller.setReady(ready: true);

    expect(roomService.calls, contains('setReady(5566,true)'));
  });

  test('PlayerReadyChanged 이벤트가 오면 readyPlayerIds가 갱신된다', () async {
    await controller.connect(
      roomId: 5566,
      accessToken: 'token',
      initialPlayers: const [
        Player(id: 1, nickname: '방장'),
        Player(id: 2, nickname: '멤버'),
      ],
    );

    socket.emit(const GameHubEvent.playerReadyChanged(userId: 2, ready: true));
    await Future<void>.delayed(Duration.zero);
    expect((controller.state as GameWaitingRoom).readyPlayerIds, {2});

    socket.emit(const GameHubEvent.playerReadyChanged(userId: 2, ready: false));
    await Future<void>.delayed(Duration.zero);
    expect((controller.state as GameWaitingRoom).readyPlayerIds, isEmpty);
  });

  test(
      'autoConnect 중 StateSync가 GameWaitingRoom 전이보다 먼저 도착해도 '
      'initialPlayers로 닉네임을 채운다(랭크 매칭 "User {id}" 회귀 방지)', () async {
    socket.duringConnect = () {
      socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    };

    await controller.connect(
      roomId: 5566,
      accessToken: 'token',
      initialPlayers: const [Player(id: 1024, nickname: '스플랜더왕')],
    );
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as GameConnected;
    expect(state.players.single.nickname, '스플랜더왕');
  });

  test('StateSync(full)를 받으면 GameConnected로 전환된다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');

    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as GameConnected;
    expect(state.gameState.gameId, 9911);
  });

  test('StateSync(delta)의 JSON Patch를 기존 상태에 적용한다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    socket.emit(const GameHubEvent.stateSync(
      patch: [
        {'op': 'replace', 'path': '/players/1024/tokens/diamond', 'value': 3},
        {'op': 'replace', 'path': '/players/1024/points', 'value': 5},
      ],
      sequence: 2,
    ));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as GameConnected;
    expect(state.gameState.players['1024']?.tokens['diamond'], 3);
    expect(state.gameState.players['1024']?.points, 5);
  });

  test('TurnChanged로 currentPlayerId/turnNumber가 갱신된다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    socket.emit(const GameHubEvent.turnChanged(
      currentPlayerId: 2048,
      turnNumber: 4,
    ));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as GameConnected;
    expect(state.gameState.currentPlayerId, 2048);
    expect(state.gameState.turnNumber, 4);
  });

  test('NobleChoiceRequired -> claimNoble 흐름에서 대기 상태가 해제된다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    socket.emit(const GameHubEvent.nobleChoiceRequired(
      playerId: 1024,
      candidateNobleIds: ['n_04', 'n_07'],
    ));
    await Future<void>.delayed(Duration.zero);
    expect((controller.state as GameConnected).pendingNobleChoice,
        ['n_04', 'n_07']);

    await controller.claimNoble('n_04');
    expect(socket.calls, contains('claimNoble'));
    expect((controller.state as GameConnected).pendingNobleChoice, isNull);
  });

  test('ChatMessage는 chatLog에 누적된다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    socket.emit(GameHubEvent.chatMessage(
      playerId: 2048,
      text: '안녕하세요!',
      ts: DateTime.utc(2026, 7, 10, 9, 21),
    ));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as GameConnected;
    expect(state.chatLog.single.text, '안녕하세요!');
  });

  test('GameOver 이벤트가 상태에 반영된다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    socket.emit(const GameHubEvent.gameOver(
      winnerId: 1024,
      finalScores: [
        FinalScore(userId: 1024, score: 16),
        FinalScore(userId: 2048, score: 13),
      ],
    ));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as GameConnected;
    expect(state.gameOver?.winnerId, 1024);
    expect(state.gameOver?.finalScores, hasLength(2));
  });

  test('leaveRoom은 소켓에 위임하고 Disconnected로 되돌아간다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    await controller.leaveRoom();

    expect(socket.calls, contains('leaveRoom'));
    // 방을 나갈 때 연결도 명시적으로 끊어(disconnect) 재사용 가능한 상태로
    // 되돌려야, 이후 다른 방에 다시 connect()해도 "이미 연결됨" 가드에
    // 걸리지 않는다.
    expect(socket.calls, contains('disconnect'));
    expect(controller.state, isA<GameDisconnected>());
  });

  test(
      'connect()가 같은 방으로 다시 호출되면(예: 최소화 배지 복귀) 소켓에 재연결하지 않는다',
      () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);
    expect(socket.calls.where((c) => c == 'connect(5566)'), hasLength(1));

    // PlayScreen이 배지로 최소화됐다가 복귀하며 initState()가 다시 connect()를
    // 부르는 상황을 재현한다. 예전(autoDispose)에는 여기서 위젯이 재생성한
    // 새 GameController+SocketService가 다시 연결을 맺어야 했지만, 이제는
    // 같은 컨트롤러가 살아있으므로 이 두 번째 connect() 호출은 아무 것도
    // 하지 않고 기존 연결/상태를 그대로 유지해야 한다.
    await controller.connect(
      roomId: 5566,
      accessToken: 'token',
      initialPlayers: const [],
    );

    expect(socket.calls.where((c) => c == 'connect(5566)'), hasLength(1));
    expect(controller.state, isA<GameConnected>());
  });

  test('connect()가 다른 방으로 호출되면 정상적으로 재연결한다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    socket.emit(GameHubEvent.stateSync(state: _fullState(), sequence: 1));
    await Future<void>.delayed(Duration.zero);

    await controller.connect(roomId: 7788, accessToken: 'token');

    expect(socket.calls, contains('connect(7788)'));
  });
}
