// docker compose up으로 띄운 실제 로컬 백엔드(http://localhost:5047)에 진짜
// 네트워크 요청을 보내는 연동 테스트입니다. 다른 테스트들과 달리 모킹이 전혀
// 없습니다 — 백엔드가 떠 있지 않으면 이 파일의 테스트는 실패합니다(의도된 동작).
//
// 평소 `flutter test`에 포함하고 싶지 않다면 태그로 빼고 돌리세요:
//   flutter test --exclude-tags=integration          # 이 파일만 빼고 실행
//   flutter test test/integration --tags=integration # 이 파일만 실행(백엔드 필요)
@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/models/auth_user.dart';
import 'package:splendor_multiplayer/services/api_client.dart';
import 'package:splendor_multiplayer/services/auth_service.dart';
import 'package:splendor_multiplayer/services/leaderboard_service.dart';
import 'package:splendor_multiplayer/services/room_service.dart';
import 'package:splendor_multiplayer/utils/token_storage.dart';

/// flutter_secure_storage(플랫폼 채널)를 타지 않는 인메모리 TokenStorage.
/// live_backend_test 안에서만 쓰는 최소 구현입니다.
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

void main() {
  final httpClient = http.Client();
  final authService = AuthService(client: httpClient);
  final tokenStorage = _InMemoryTokenStorage();
  final apiClient = ApiClient(
    client: httpClient,
    tokenStorage: tokenStorage,
    authService: authService,
  );
  final roomService = RoomService(client: apiClient);
  final leaderboardService = LeaderboardService(client: apiClient);

  final uniqueEmail = 'itest_${DateTime.now().millisecondsSinceEpoch}@example.com';

  test(
    '회원가입 -> 로그인 -> 방 생성/목록/삭제 -> 리더보드 조회까지 실제 도커 백엔드와 통신한다',
    () async {
      final registered = await authService.register(
        email: uniqueEmail,
        password: 'P@ssw0rd123',
        nickname: 'itester',
      );
      expect(registered.userId, greaterThan(0));
      expect(registered.nickname, 'itester');
      await tokenStorage.saveUser(registered);

      final loggedIn = await authService.logIn(
        email: uniqueEmail,
        password: 'P@ssw0rd123',
      );
      expect(loggedIn.userId, registered.userId);

      final room = await roomService.createRoom(maxPlayers: 2);
      expect(room.hostId, registered.userId);
      expect(room.maxPlayers, 2);
      expect(room.players.single.nickname, 'itester');

      final fetchedRoom = await roomService.getRoom(room.roomId);
      expect(fetchedRoom.roomId, room.roomId);

      final list = await roomService.listRooms(limit: 100);
      expect(list.rooms.any((r) => r.roomId == room.roomId), isTrue);

      await roomService.deleteRoom(room.roomId);

      final leaderboard = await leaderboardService.getLeaderboard(2);
      expect(leaderboard.playerCount, 2);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  test('인증 없이 /rooms를 호출하면 401을 받는다', () async {
    final res = await httpClient.get(Uri.parse('http://localhost:5047/rooms'));
    expect(res.statusCode, 401);
  });

  test('잘못된 비밀번호로 로그인하면 AuthException을 던진다', () async {
    expect(
      () => authService.logIn(email: uniqueEmail, password: 'wrong-password'),
      throwsA(isA<AuthException>()),
    );
  });
}
