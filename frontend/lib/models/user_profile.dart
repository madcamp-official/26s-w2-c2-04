// GET /profile/me, GET /profile/{userId} 응답을 파싱하는 모델.
// backend/Backend/Dtos/ProfileDtos.cs의 ProfileResponse/RankingSummaryResponse/
// RecentMatchResponse를 그대로 반영합니다(전적/스탯이 프로필 응답 하나에 모두
// 들어있고, 별도의 /users/{id}/stats 같은 엔드포인트는 없습니다).

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// 인원수(2/3/4)별 랭킹전 MMR·순위 요약.
@freezed
class RankingSummary with _$RankingSummary {
  const factory RankingSummary({
    required int playerCount,
    required int rank,
    required int mmr,
    required int gamesPlayed,
    required double avgPlace,
  }) = _RankingSummary;

  factory RankingSummary.fromJson(Map<String, dynamic> json) =>
      _$RankingSummaryFromJson(json);
}

@freezed
class RecentMatch with _$RecentMatch {
  const factory RecentMatch({
    required int gameId,
    required int playerCount,
    required int place,
    required int score,
    required bool isRanked,
    required DateTime playedAt,
  }) = _RecentMatch;

  factory RecentMatch.fromJson(Map<String, dynamic> json) =>
      _$RecentMatchFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int userId,
    required String nickname,
    String? avatarUrl,
    @Default(0) int totalGamesPlayed,
    @Default(0) double overallAvgPlace,
    @Default([]) List<RankingSummary> rankings,
    @Default([]) List<RecentMatch> recentMatches,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
