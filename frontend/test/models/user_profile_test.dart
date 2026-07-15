import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/user_profile.dart';

void main() {
  test('GET /profile/{userId} 응답(ProfileResponse)을 파싱한다', () {
    final json = {
      'userId': 1024,
      'nickname': '스플랜더왕',
      'avatarUrl': '/profile/1024/avatar',
      'totalGamesPlayed': 47,
      'overallAvgPlace': 1.9,
      'rankings': [
        {'playerCount': 2, 'rank': 210, 'mmr': 1710, 'gamesPlayed': 9, 'avgPlace': 1.7},
        {'playerCount': 3, 'rank': 357, 'mmr': 1820, 'gamesPlayed': 38, 'avgPlace': 2.1},
      ],
      'recentMatches': [
        {
          'gameId': 1024,
          'playerCount': 3,
          'place': 2,
          'score': 15,
          'isRanked': false,
          'playedAt': '2026-07-10T09:00:00Z',
        },
      ],
    };

    final profile = UserProfile.fromJson(json);

    expect(profile.userId, 1024);
    expect(profile.totalGamesPlayed, 47);
    expect(profile.rankings.firstWhere((r) => r.playerCount == 2).rank, 210);
    expect(profile.rankings.firstWhere((r) => r.playerCount == 3).mmr, 1820);
    expect(profile.recentMatches.single.place, 2);
    expect(profile.recentMatches.single.isRanked, isFalse);
  });
}
