// docker compose로 띄운 실제 로컬 백엔드(http://localhost:5047)의 GameHub와
// 진짜 SignalR 연결을 맺어 게임 진행 흐름(토큰 획득/카드 예약/채팅/이모트)이
// socket_service.dart의 시그니처와 실제로 맞는지 검증하는 연동 테스트입니다.
// 모킹이 전혀 없습니다 — 백엔드가 떠 있지 않으면 실패합니다(의도된 동작).
//
//   flutter test test/integration --tags=integration --run-skipped
@Tags(['integration'])
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/models/auth_user.dart';
import 'package:splendor_multiplayer/models/game_hub_event.dart';
import 'package:splendor_multiplayer/services/api_client.dart';
import 'package:splendor_multiplayer/services/auth_service.dart';
import 'package:splendor_multiplayer/services/room_service.dart';
import 'package:splendor_multiplayer/services/socket_service.dart';
import 'package:splendor_multiplayer/utils/token_storage.dart';

class _InMemoryTokenStorage implements TokenStorage {
  AuthUser? _user;

  @override
  Future<void> saveUser(AuthUser user) async => _user = user;

  @override
  Future<AuthUser?> readUser() async => _user;

  @override
  Future<String?> readAccessToken() async => _user?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _user?.refreshToken;

  @override
  Future<void> updateAccessToken(String accessToken) async {
    final current = _user;
    if (current != null) _user = current.copyWith(accessToken: accessToken);
  }

  @override
  Future<void> clear() async => _user = null;
}

/// broadcast 스트림에 새 리스너를 붙이면 그 이전에 지나간 이벤트를 놓치므로,
/// connect() 이전부터 계속 수집해온 리스트를 폴링해서 원하는 이벤트를 찾는다.
Future<T> _waitForEvent<T extends GameHubEvent>(
  List<GameHubEvent> events,
  int startIndex,
  bool Function(T) test, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    for (var i = startIndex; i < events.length; i++) {
      final event = events[i];
      if (event is T && test(event)) return event;
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }
  throw TimeoutException(
    '${T.toString()} not observed within $timeout (saw ${events.length - startIndex} events)',
  );
}

Future<AuthUser> _registerAndLogin(String email) async {
  final httpClient = http.Client();
  final authService = AuthService(client: httpClient);
  return authService.register(
    email: email,
    password: 'P@ssw0rd123',
    nickname: email.split('@').first,
  );
}

void main() {
  test(
    '두 플레이어가 GameHub에 접속해 토큰 획득/카드 예약/채팅/이모트를 주고받는다',
    () async {
      final suffix = DateTime.now().millisecondsSinceEpoch;
      final hostUser = await _registerAndLogin('gh_host_$suffix@example.com');
      final guestUser =
          await _registerAndLogin('gh_guest_$suffix@example.com');

      final hostTokenStorage = _InMemoryTokenStorage()
        ..saveUser(hostUser);
      final hostClient = ApiClient(
        client: http.Client(),
        tokenStorage: hostTokenStorage,
        authService: AuthService(client: http.Client()),
      );
      final hostRoomService = RoomService(client: hostClient);

      final room = await hostRoomService.createRoom(maxPlayers: 2);

      final guestTokenStorage = _InMemoryTokenStorage()
        ..saveUser(guestUser);
      final guestClient = ApiClient(
        client: http.Client(),
        tokenStorage: guestTokenStorage,
        authService: AuthService(client: http.Client()),
      );
      final guestRoomService = RoomService(client: guestClient);
      await guestRoomService.joinRoom(room.roomId);

      final started = await hostRoomService.startGame(room.roomId);
      expect(started.phase, isNotEmpty);

      final hostSocket = SocketService();
      final guestSocket = SocketService();
      addTearDown(() async {
        await hostSocket.dispose();
        await guestSocket.dispose();
      });

      final hostEvents = <GameHubEvent>[];
      final guestEvents = <GameHubEvent>[];
      hostSocket.events.listen(hostEvents.add);
      guestSocket.events.listen(guestEvents.add);

      await hostSocket.connect(
        roomId: room.roomId,
        accessToken: hostUser.accessToken,
      );
      await guestSocket.connect(
        roomId: room.roomId,
        accessToken: guestUser.accessToken,
      );

      // JoinRoom 직후 Clients.Caller로 온 초기 StateSync(full)를 기다린다.
      final initialSync = await _waitForEvent<GameHubStateSync>(
        hostEvents,
        0,
        (e) => e.state != null,
      );
      final initialState = initialSync.state!;
      expect(initialState.currentPlayerId, isNotNull);

      final currentPlayerId = initialState.currentPlayerId!;
      final actingSocket =
          currentPlayerId == hostUser.userId ? hostSocket : guestSocket;
      final observerEvents =
          currentPlayerId == hostUser.userId ? guestEvents : hostEvents;

      final beforeTokenCount = observerEvents.length;

      // 2인전 초기 토큰은 색당 4개이므로 서로 다른 3색을 집는 것이 항상 유효하다.
      await actingSocket.takeTokens(['Diamond', 'Sapphire', 'Emerald']);

      final tokensSync = await _waitForEvent<GameHubStateSync>(
        observerEvents,
        beforeTokenCount,
        (e) => e.state != null,
      );
      final afterTokens = tokensSync.state!;
      expect(afterTokens.tokenBank['Diamond'], 3);
      expect(afterTokens.tokenBank['Sapphire'], 3);
      expect(afterTokens.tokenBank['Emerald'], 3);
      expect(afterTokens.currentPlayerId, isNot(currentPlayerId));

      // 방금 턴이 넘어간 플레이어가 블라인드 드로우로 카드를 예약한다
      // (ReserveCardRequest 래핑 시그니처가 실제로 맞는지 검증).
      final secondPlayerId = afterTokens.currentPlayerId!;
      final secondSocket =
          secondPlayerId == hostUser.userId ? hostSocket : guestSocket;
      await secondSocket.reserveCard(tier: 1);

      // 채팅/이모트는 발신자를 제외한 그룹원에게만 브로드캐스트된다.
      final beforeChatCount = guestEvents.length;
      await hostSocket.sendChatMessage('hello from host');
      final chatReceived = await _waitForEvent<GameHubChatMessage>(
        guestEvents,
        beforeChatCount,
        (e) => e.playerId == hostUser.userId,
      );
      expect(chatReceived.text, 'hello from host');

      final beforeEmoteCount = hostEvents.length;
      await guestSocket.sendEmote('wave');
      final emoteReceived = await _waitForEvent<GameHubEmoteReceived>(
        hostEvents,
        beforeEmoteCount,
        (e) => e.playerId == guestUser.userId,
      );
      expect(emoteReceived.emoteId, 'wave');
    },
    timeout: const Timeout(Duration(seconds: 40)),
  );
}
