// ApiClient의 핵심 책임(Authorization 헤더 자동 첨부, 401 -> /auth/refresh ->
// 재시도)을 검증합니다. TokenStorage는 flutter_secure_storage(플랫폼 채널)를
// 감싸고 있어서, 순수 단위 테스트에서는 인메모리 구현으로 대체합니다.

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:splendor_multiplayer/models/auth_user.dart';
import 'package:splendor_multiplayer/services/api_client.dart';
import 'package:splendor_multiplayer/services/auth_service.dart';
import 'package:splendor_multiplayer/utils/token_storage.dart';

class _FakeTokenStorage implements TokenStorage {
  AuthUser? user;
  _FakeTokenStorage(this.user);

  @override
  Future<void> saveUser(AuthUser user) async => this.user = user;

  @override
  Future<AuthUser?> readUser() async => user;

  @override
  Future<String?> readAccessToken() async => user?.accessToken;

  @override
  Future<String?> readRefreshToken() async => user?.refreshToken;

  @override
  Future<void> updateAccessToken(String accessToken) async {
    final current = user;
    if (current != null) user = current.copyWith(accessToken: accessToken);
  }

  @override
  Future<void> clear() async => user = null;
}

AuthUser _testUser({required String accessToken}) => AuthUser(
      userId: 1024,
      nickname: '스플랜더왕',
      provider: 'email',
      accessToken: accessToken,
      refreshToken: 'refresh_abc',
      expiresIn: 3600,
    );

void main() {
  test('요청에 저장된 accessToken을 Authorization 헤더로 붙인다', () async {
    final mockClient = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer old_access');
      return http.Response(jsonEncode({'ok': true}), 200);
    });

    final apiClient = ApiClient(
      client: mockClient,
      tokenStorage: _FakeTokenStorage(_testUser(accessToken: 'old_access')),
      authService: AuthService(client: mockClient),
    );

    final res = await apiClient.get('/rooms');
    expect(res.statusCode, 200);
  });

  test('401을 받으면 /auth/refresh로 재발급받아 한 번 재시도한다', () async {
    var apiCallCount = 0;

    final mockClient = MockClient((request) async {
      if (request.url.path == '/auth/refresh') {
        return http.Response(
          jsonEncode({'accessToken': 'new_access', 'expiresIn': 3600}),
          200,
        );
      }

      apiCallCount++;
      if (apiCallCount == 1) {
        expect(request.headers['Authorization'], 'Bearer old_access');
        return http.Response('', 401);
      }
      expect(request.headers['Authorization'], 'Bearer new_access');
      return http.Response(jsonEncode({'ok': true}), 200);
    });

    final tokenStorage = _FakeTokenStorage(_testUser(accessToken: 'old_access'));
    final apiClient = ApiClient(
      client: mockClient,
      tokenStorage: tokenStorage,
      authService: AuthService(client: mockClient),
    );

    final res = await apiClient.get('/rooms');

    expect(res.statusCode, 200);
    expect(apiCallCount, 2);
    expect(tokenStorage.user?.accessToken, 'new_access');
  });

  test('refresh까지 실패하면 최초의 401 응답을 그대로 돌려준다', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/auth/refresh') {
        return http.Response('', 401);
      }
      return http.Response('', 401);
    });

    final apiClient = ApiClient(
      client: mockClient,
      tokenStorage: _FakeTokenStorage(_testUser(accessToken: 'expired')),
      authService: AuthService(client: mockClient),
    );

    final res = await apiClient.get('/rooms');
    expect(res.statusCode, 401);
  });

  group('ApiClient.ensureOk', () {
    test('2xx면 아무 예외도 던지지 않는다', () {
      expect(() => ApiClient.ensureOk(http.Response('', 204)), returnsNormally);
    });

    test('4xx면 서버 메시지를 담은 ApiException을 던진다', () {
      final res = http.Response(
        jsonEncode({'message': '방을 찾을 수 없습니다.'}),
        404,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
      expect(
        () => ApiClient.ensureOk(res),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', '방을 찾을 수 없습니다.'),
        ),
      );
    });
  });
}
