import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/leaderboard_service.dart';
import '../helpers/fake_api_client.dart';

void main() {
  group('LeaderboardService.getLeaderboard', () {
    test('GET /leaderboard/{playerCount} 를 page 쿼리와 함께 호출한다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(method, 'GET');
        expect(path, '/leaderboard/3');
        expect(query, {'page': '1'});
        return http.Response(
          jsonEncode({
            'playerCount': 3,
            'page': 1,
            'limit': 100,
            'total': 1,
            'entries': [
              {
                'rank': 1,
                'userId': 2048,
                'nickname': '스플랜더고수',
                'mmr': 2450,
                'avgPlace': 1.4,
                'gamesPlayedSeason': 124,
              }
            ],
            'myRank': {
              'rank': 357,
              'userId': 1024,
              'nickname': '스플랜더왕',
              'mmr': 1820,
              'avgPlace': 2.1,
              'gamesPlayedSeason': 38,
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final res = await LeaderboardService(client: fake).getLeaderboard(3);

      expect(res.entries.single.nickname, '스플랜더고수');
      expect(res.myRank?.playerId, 1024);
    });
  });

  group('LeaderboardService.search', () {
    test('GET /leaderboard/{playerCount}/search 를 query와 함께 호출한다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(path, '/leaderboard/2/search');
        expect(query, {'query': '스플랜더'});
        return http.Response(
          jsonEncode({
            'playerCount': 2,
            'query': '스플랜더',
            'total': 1,
            'entries': [
              {
                'rank': 5,
                'userId': 3000,
                'nickname': '스플랜더신',
                'mmr': 2100,
                'avgPlace': 1.9,
                'gamesPlayedSeason': 20,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final res = await LeaderboardService(client: fake).search(2, '스플랜더');

      expect(res.entries.single.nickname, '스플랜더신');
      expect(res.myRank, isNull);
    });
  });
}
