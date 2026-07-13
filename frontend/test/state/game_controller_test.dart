import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:splendor_multiplayer/models/game_hub_event.dart';
import 'package:splendor_multiplayer/models/game_state.dart';
import 'package:splendor_multiplayer/services/play_service.dart';
import 'package:splendor_multiplayer/services/socket_service.dart';
import 'package:splendor_multiplayer/state/game_controller.dart';

class _FakeGameSocket implements GameSocket {
  final _controller = StreamController<GameHubEvent>.broadcast();
  final List<String> calls = [];

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
  }

  @override
  Future<void> leaveRoom(int roomId) async => calls.add('leaveRoom');

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
  late GameController controller;

  setUp(() {
    socket = _FakeGameSocket();
    controller = GameController(socket, PlayService());
  });

  test('connect는 소켓에 연결을 위임한다', () async {
    await controller.connect(roomId: 5566, accessToken: 'token');
    expect(socket.calls, contains('connect(5566)'));
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
    expect(controller.state, isA<GameDisconnected>());
  });
}
