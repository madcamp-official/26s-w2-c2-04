import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/leaderboard_list_response.dart';

void main() {
  test('GET /leaderboard/{playerCount} 응답을 파싱한다 (myRank 포함)', () {
    final json = {
      'playerCount': 3,
      'page': 1,
      'limit': 100,
      'total': 5820,
      'entries': [
        {
          'rank': 1,
          'userId': 2048,
          'nickname': '스플랜더고수',
          'avatarUrl': 'https://cdn.splendor-online.com/avatars/u_2048.png',
          'mmr': 2450,
          'avgPlace': 1.4,
          'gamesPlayedSeason': 124,
        }
      ],
      'myRank': {
        'rank': 357,
        'userId': 1024,
        'nickname': '스플랜더왕',
        'avatarUrl': 'https://cdn.splendor-online.com/avatars/u_1024.png',
        'mmr': 1820,
        'avgPlace': 2.1,
        'gamesPlayedSeason': 38,
      },
    };

    final res = LeaderboardListResponse.fromJson(json);

    expect(res.playerCount, 3);
    expect(res.total, 5820);
    expect(res.entries.single.nickname, '스플랜더고수');
    expect(res.myRank?.rank, 357);
    expect(res.query, isNull);
  });

  test('GET /leaderboard/{playerCount}/search 응답을 파싱한다 (page/limit/myRank 없음)', () {
    final json = {
      'playerCount': 3,
      'query': '스플랜더',
      'total': 2,
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
    };

    final res = LeaderboardListResponse.fromJson(json);

    expect(res.query, '스플랜더');
    expect(res.page, isNull);
    expect(res.limit, isNull);
    expect(res.myRank, isNull);
    expect(res.entries.single.playerId, 2048);
  });
}
