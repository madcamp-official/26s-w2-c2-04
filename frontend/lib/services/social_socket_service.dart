// SocialHub(/hubs/social, SignalR)로 진행되는 친구 프레즌스/1:1 채팅을 담당하는
// 소켓 계층. README 9절에 정의된 SocialHub 프로토콜을 그대로 구현합니다.
// GameHub(socket_service.dart)와는 별개 연결이며, 로그인 직후부터 앱이 살아있는
// 동안(로비 포함) 상시 연결을 유지하도록 설계되어 있습니다.

import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/social_hub_event.dart';
import '../utils/constants.dart';

abstract class SocialSocket {
  Stream<SocialHubEvent> get events;

  Future<void> connect(String accessToken);
  Future<void> sendFriendMessage({required int toUserId, required String text});
  Future<void> setPresence(String status);
  Future<void> dispose();
}

class SocialSocketService implements SocialSocket {
  HubConnection? _hubConnection;
  final _eventController = StreamController<SocialHubEvent>.broadcast();

  @override
  Stream<SocialHubEvent> get events => _eventController.stream;

  @override
  Future<void> connect(String accessToken) async {
    final connection = HubConnectionBuilder()
        .withUrl(
          '${ApiConfig.baseUrl}/hubs/social',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
          ),
        )
        .withAutomaticReconnect()
        .build();
    _hubConnection = connection;

    for (final method in const [
      'FriendRequestReceived',
      'FriendRequestAccepted',
      'FriendStatusChanged',
      'FriendMessageReceived',
    ]) {
      connection.on(method, (args) {
        final event = parseSocialHubEvent(method, args);
        if (event != null) _eventController.add(event);
      });
    }

    await connection.start();
  }

  @override
  Future<void> sendFriendMessage({required int toUserId, required String text}) async {
    await _hubConnection?.invoke('SendFriendMessage', args: [
      {'toUserId': toUserId, 'text': text},
    ]);
  }

  @override
  Future<void> setPresence(String status) async {
    await _hubConnection?.invoke('SetPresence', args: [
      {'status': status},
    ]);
  }

  @override
  Future<void> dispose() async {
    await _hubConnection?.stop();
    await _eventController.close();
  }
}
