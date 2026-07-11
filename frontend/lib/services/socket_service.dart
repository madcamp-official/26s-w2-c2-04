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

  Future<void> connect({required int roomId, required String accessToken});
  Future<void> leaveRoom(int roomId);
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

  // GameHub의 모든 Hub 메서드(TakeTokens 등)는 roomId를 첫 인자로 받으므로,
  // connect() 시점에 저장해두고 이후 모든 invoke에 실어 보냅니다.
  int? _roomId;

  @override
  Stream<GameHubEvent> get events => _eventController.stream;

  @override
  HubConnectionState? get connectionState => _hubConnection?.state;

  @override
  Future<void> connect({
    required int roomId,
    required String accessToken,
  }) async {
    _roomId = roomId;
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
  Future<void> leaveRoom(int roomId) async {
    await _hubConnection?.invoke('LeaveRoom', args: [roomId]);
  }

  Future<void> startGame(int roomId) async {
    await _hubConnection?.invoke('StartGame', args: [roomId]);
  }

  @override
  Future<void> takeTokens(List<String> gems) async {
    // 백엔드 GameHub.TakeTokens(int roomId, List<string> gems) 시그니처와 위치 인자를 맞춘다.
    await _hubConnection?.invoke('TakeTokens', args: [_roomId!, gems]);
  }

  @override
  Future<void> purchaseCard({
    required String cardId,
    required String source,
  }) async {
    // 백엔드 GameHub.PurchaseCard(int roomId, string cardId, string source)
    await _hubConnection
        ?.invoke('PurchaseCard', args: [_roomId!, cardId, source]);
  }

  @override
  Future<void> reserveCard({String? cardId, int? tier}) async {
    assert(
      (cardId == null) != (tier == null),
      'cardId와 tier 중 하나만 지정해야 합니다.',
    );
    // 백엔드 GameHub.ReserveCard(int roomId, ReserveCardRequest request)
    // (cardId/tier 중 하나가 null이라 List<Object> 위치 인자로 못 보내고 객체로 감싼다)
    await _hubConnection?.invoke('ReserveCard', args: [
      _roomId!,
      {'cardId': cardId, 'tier': tier},
    ]);
  }

  @override
  Future<void> discardTokens(List<String> gems) async {
    // 백엔드 GameHub.DiscardTokens(int roomId, List<string> gems)
    await _hubConnection?.invoke('DiscardTokens', args: [_roomId!, gems]);
  }

  @override
  Future<void> claimNoble(String nobleId) async {
    // 백엔드 GameHub.ClaimNoble(int roomId, string nobleId)
    await _hubConnection?.invoke('ClaimNoble', args: [_roomId!, nobleId]);
  }

  @override
  Future<void> sendChatMessage(String text) async {
    // 백엔드 GameHub.SendChatMessage(int roomId, string text)
    await _hubConnection?.invoke('SendChatMessage', args: [_roomId!, text]);
  }

  @override
  Future<void> sendEmote(String emoteId) async {
    // 백엔드 GameHub.SendEmote(int roomId, string emoteId)
    await _hubConnection?.invoke('SendEmote', args: [_roomId!, emoteId]);
  }

  @override
  Future<void> requestResync(int lastSequence) async {
    // 백엔드 GameHub.RequestResync(int roomId, int lastSequence)
    await _hubConnection
        ?.invoke('RequestResync', args: [_roomId!, lastSequence]);
  }

  @override
  Future<void> dispose() async {
    await _hubConnection?.stop();
    await _eventController.close();
  }
}
