import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/user_service.dart';
import '../helpers/fake_api_client.dart';

void main() {
  test('getProfile은 GET /users/{userId}를 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'GET');
      expect(path, '/users/1024');
      return http.Response(
        jsonEncode({
          'userId': 1024,
          'nickname': '스플랜더왕',
          'createdAt': '2026-07-10T09:00:00Z',
          'recentGames': [],
          'rankings': {},
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final profile = await UserService(client: fake).getProfile(1024);
    expect(profile.nickname, '스플랜더왕');
  });

  test('updateMe는 PATCH /users/me에 nickname/avatarUrl만 보낸다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'PATCH');
      expect(path, '/users/me');
      expect(body, {'nickname': '새로운닉네임'});
      return http.Response(
        jsonEncode({
          'userId': 1024,
          'nickname': '새로운닉네임',
          'createdAt': '2026-07-10T09:00:00Z',
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final profile = await UserService(client: fake).updateMe(nickname: '새로운닉네임');
    expect(profile.nickname, '새로운닉네임');
  });

  test('search는 GET /users/search를 nickname 쿼리와 함께 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(path, '/users/search');
      expect(query, {'nickname': '스플랜더'});
      return http.Response(
        jsonEncode({
          'users': [
            {'userId': 2048, 'nickname': '스플랜더고수'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final results = await UserService(client: fake).search('스플랜더');
    expect(results.single.nickname, '스플랜더고수');
  });
}
