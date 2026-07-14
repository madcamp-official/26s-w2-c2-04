// SocialHub(/hubs/social, SignalR)로 진행되는 친구 프레즌스/1:1 채팅을 담당하는
// 소켓 계층. README 9절에 정의된 SocialHub 프로토콜을 그대로 구현합니다.
// GameHub(socket_service.dart)와는 별개 연결이며, 로그인 직후부터 앱이 살아있는
// 동안(로비 포함) 상시 연결을 유지하도록 설계되어 있습니다.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/social_hub_event.dart';
import '../utils/constants.dart';

/// 앱 전역에서 공유하는 단일 SocialSocket 인스턴스. 로그인 상태 진입/이탈은
/// AuthController가, 이벤트 구독은 각 화면(FriendController 등)이 이 하나의
/// 인스턴스를 통해 처리합니다 — 화면마다 별도로 연결을 만들면 SocialHub가
/// "로그인 중"으로 보는 연결이 화면 진입 여부에 종속돼 동시접속 차단 판정이
/// 무효화됩니다.
final socialSocketProvider = Provider<SocialSocket>((ref) => SocialSocketService());

abstract class SocialSocket {
  Stream<SocialHubEvent> get events;

  Future<void> connect(String accessToken);
  Future<void> sendFriendMessage({required int toUserId, required String text});
  Future<void> setPresence(String status);

  /// 연결만 끊고 [events] 스트림은 재사용할 수 있도록 살려둡니다. 재로그인 시
  /// [connect]를 다시 불러 이어서 쓸 수 있습니다. 앱 종료 시에만 [dispose]를
  /// 씁니다.
  Future<void> disconnect();
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
  Future<void> disconnect() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }

  @override
  Future<void> dispose() async {
    await _hubConnection?.stop();
    await _eventController.close();
  }
}
