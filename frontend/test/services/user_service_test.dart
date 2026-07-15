import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/user_service.dart';
import '../helpers/fake_api_client.dart';

void main() {
  test('getMyProfile은 GET /profile/me를 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'GET');
      expect(path, '/profile/me');
      return http.Response(
        jsonEncode({
          'userId': 1024,
          'nickname': '스플랜더왕',
          'totalGamesPlayed': 0,
          'overallAvgPlace': 0,
          'rankings': [],
          'recentMatches': [],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final profile = await UserService(client: fake).getMyProfile();
    expect(profile.nickname, '스플랜더왕');
  });

  test('getProfile은 GET /profile/{userId}를 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'GET');
      expect(path, '/profile/2048');
      return http.Response(
        jsonEncode({
          'userId': 2048,
          'nickname': '도시의상인',
          'totalGamesPlayed': 5,
          'overallAvgPlace': 2.4,
          'rankings': [],
          'recentMatches': [],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final profile = await UserService(client: fake).getProfile(2048);
    expect(profile.nickname, '도시의상인');
    expect(profile.totalGamesPlayed, 5);
  });
}
