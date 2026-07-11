// GameHub(/hubs/game, SignalR)로 진행되는 실시간 이벤트(턴 진행, 카드 구매,
// 토큰 획득 등)를 담당하는 소켓 계층. README 7절(Client -> Server invoke)과
// 8절(Server -> Client 콜백)에 정의된 GameHub 프로토콜을 그대로 구현합니다.
//
// 방 생성/목록/참가 같은 방 생명주기(로비 단계)는 REST(room_service.dart)로
// 처리하고, `/rooms/{roomId}/start` 이후의 실제 게임 진행만 이 클래스가 맡습니다.

import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/game_hub_event.dart';
import '../utils/constants.dart';

/// 방장이 아니어도 방 시작 이전에 예약해둔 콜백을 붙일 수 있도록,
/// game_controller.dart가 이 인터페이스만 바라보게 하여 테스트에서는
/// FakeGameSocket으로 손쉽게 대체할 수 있습니다.
abstract class GameSocket {
  Stream<GameHubEvent> get events;
  HubConnectionState? get connectionState;

  Future<void> connect({required String roomId, required String accessToken});
  Future<void> leaveRoom(String roomId);
  Future<void> takeTokens(List<String> gems);
  Future<void> purchaseCard({required String cardId, required String source});
  Future<void> reserveCard({String? cardId, int? tier});
  Future<void> discardTokens(List<String> gems);
  Future<void> claimNoble(String nobleId);
  Future<void> sendChatMessage(String text);
  Future<void> sendEmote(String emoteId);
  Future<void> requestResync(int lastSequence);
  Future<void> dispose();
}

class SocketService implements GameSocket {
  HubConnection? _hubConnection;
  final _eventController = StreamController<GameHubEvent>.broadcast();

  @override
  Stream<GameHubEvent> get events => _eventController.stream;

  @override
  HubConnectionState? get connectionState => _hubConnection?.state;

  @override
  Future<void> connect({
    required String roomId,
    required String accessToken,
  }) async {
    final connection = HubConnectionBuilder()
        .withUrl(
          '${ApiConfig.baseUrl}/hubs/game',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
          ),
        )
        .withAutomaticReconnect()
        .build();
    _hubConnection = connection;

    for (final method in const [
      'StateSync',
      'ActionResult',
      'TurnChanged',
      'NobleAwarded',
      'NobleChoiceRequired',
      'PlayerJoined',
      'PlayerLeft',
      'FinalRoundTriggered',
      'GameOver',
      'ChatMessage',
      'EmoteReceived',
      'ErrorOccurred',
    ]) {
      connection.on(method, (args) {
        _eventController.add(parseGameHubEvent(method, args));
      });
    }

    await connection.start();
    await connection.invoke('JoinRoom', args: [roomId]);
  }

  /// 재연결 성공 시 실행할 콜백(주로 RequestResync 호출)을 등록합니다.
  void onReconnected(void Function() callback) {
    _hubConnection?.onreconnected(({connectionId}) => callback());
  }

  void onClosed(void Function(Exception? error) callback) {
    _hubConnection?.onclose(({error}) => callback(error));
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    await _hubConnection?.invoke('LeaveRoom', args: [roomId]);
  }

  Future<void> startGame(String roomId) async {
    await _hubConnection?.invoke('StartGame', args: [roomId]);
  }

  @override
  Future<void> takeTokens(List<String> gems) async {
    await _hubConnection?.invoke('TakeTokens', args: [
      {'gems': gems},
    ]);
  }

  @override
  Future<void> purchaseCard({
    required String cardId,
    required String source,
  }) async {
    await _hubConnection?.invoke('PurchaseCard', args: [
      {'cardId': cardId, 'source': source},
    ]);
  }

  @override
  Future<void> reserveCard({String? cardId, int? tier}) async {
    assert(
      (cardId == null) != (tier == null),
      'cardId와 tier 중 하나만 지정해야 합니다.',
    );
    await _hubConnection?.invoke('ReserveCard', args: [
      if (cardId != null) {'cardId': cardId} else {'tier': tier},
    ]);
  }

  @override
  Future<void> discardTokens(List<String> gems) async {
    await _hubConnection?.invoke('DiscardTokens', args: [
      {'gems': gems},
    ]);
  }

  @override
  Future<void> claimNoble(String nobleId) async {
    await _hubConnection?.invoke('ClaimNoble', args: [nobleId]);
  }

  @override
  Future<void> sendChatMessage(String text) async {
    await _hubConnection?.invoke('SendChatMessage', args: [
      {'text': text},
    ]);
  }

  @override
  Future<void> sendEmote(String emoteId) async {
    await _hubConnection?.invoke('SendEmote', args: [
      {'emoteId': emoteId},
    ]);
  }

  @override
  Future<void> requestResync(int lastSequence) async {
    await _hubConnection?.invoke('RequestResync', args: [lastSequence]);
  }

  @override
  Future<void> dispose() async {
    await _hubConnection?.stop();
    await _eventController.close();
  }
}
