import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:splendor_multiplayer/services/auth_service.dart';

void main() {
  group('AuthService.register', () {
    test('성공 시 AuthUser를 반환한다', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/auth/register');
        final body = jsonDecode(request.body);
        expect(body['email'], 'hong@example.com');

        return http.Response(
          jsonEncode({
            'userId': 1024,
            'nickname': 'splendor12345',
            'provider': 'email',
            'accessToken': 'token_abc',
            'refreshToken': 'refresh_abc',
            'expiresIn': 3600,
          }),
          201,
        );
      });

      final service = AuthService(client: mockClient);
      final user = await service.register(
        email: 'hong@example.com',
        password: 'P@ssw0rd123',
        nickname: 'splendor',
      );

      expect(user.userId, 1024);
      expect(user.nickname, 'splendor12345');
      expect(user.accessToken, 'token_abc');
    });

    test('실패 응답이면 AuthException을 던진다', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': '이미 가입된 이메일입니다.'}),
          409,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = AuthService(client: mockClient);

      expect(
        () => service.register(
          email: 'hong@example.com',
          password: 'pw',
          nickname: 'splendor',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthService.logIn', () {
    test('성공 시 AuthUser를 반환한다', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/auth/login');
        return http.Response(
          jsonEncode({
            'userId': 1024,
            'nickname': '스플랜더왕',
            'provider': 'email',
            'accessToken': 'token_abc',
            'refreshToken': 'refresh_abc',
            'expiresIn': 3600,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = AuthService(client: mockClient);
      final user = await service.logIn(
        email: 'hong@example.com',
        password: 'P@ssw0rd123',
      );

      expect(user.userId, 1024);
    });

    test('401 응답이면 AuthException을 던진다', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 401);
      });

      final service = AuthService(client: mockClient);

      expect(
        () => service.logIn(email: 'wrong@example.com', password: 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthService.refresh', () {
    test('성공 시 새 accessToken/expiresIn을 반환한다', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/auth/refresh');
        final body = jsonDecode(request.body);
        expect(body['refreshToken'], 'refresh_abc');

        return http.Response(
          jsonEncode({'accessToken': 'new_token', 'expiresIn': 3600}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final result = await AuthService(client: mockClient).refresh('refresh_abc');

      expect(result.accessToken, 'new_token');
      expect(result.expiresIn, 3600);
    });

    test('실패 응답이면 AuthException을 던진다', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 401);
      });

      expect(
        () => AuthService(client: mockClient).refresh('expired'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}