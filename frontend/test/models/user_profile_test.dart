import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/user_profile.dart';
import 'package:splendor_multiplayer/models/user_stats.dart';

void main() {
  test('GET /users/{userId} 응답을 파싱한다', () {
    final json = {
      'userId': 1024,
      'nickname': '스플랜더왕',
      'avatarUrl': 'https://cdn.splendor-online.com/avatars/u_1024.png',
      'createdAt': '2026-07-10T09:00:00Z',
      'recentGames': [
        {'gameId': 1024, 'playersNumber': 3, 'gameType': 'Unranked', 'place': 2},
      ],
      'rankings': {
        '2': {'rank': 210, 'mmr': 1710, 'gamesPlayedSeason': 9, 'avgPlace': 1.7},
        '3': {'rank': 357, 'mmr': 1820, 'gamesPlayedSeason': 38, 'avgPlace': 2.1},
      },
    };

    final profile = UserProfile.fromJson(json);

    expect(profile.userId, 1024);
    expect(profile.recentGames.single.place, 2);
    expect(profile.rankings['2']?.rank, 210);
    expect(profile.rankings['3']?.mmr, 1820);
  });

  test('GET /users/{userId}/stats 응답을 파싱한다', () {
    final stats = UserStats.fromJson({
      'userId': 1024,
      'gamesPlayed': 42,
      'wins': 27,
      'avgScore': 15.4,
      'avgTurns': 23.1,
    });

    expect(stats.gamesPlayed, 42);
    expect(stats.avgScore, 15.4);
  });
}
