// GET /users/{userId} 응답을 파싱하는 모델.
// 이 API는 아직 백엔드에 구현되어 있지 않습니다(backend/Backend/Endpoints에는
// Auth/Room/Matchmaking/Leaderboard만 존재). README 2절(유저 API) 스펙을 그대로
// 따라 프런트 쪽을 먼저 완성해두고, 백엔드가 나오면 여기 필드만 맞추면 됩니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// 인원수(2/3/4)별 랭킹전 MMR·순위 요약. rankings 맵의 값으로 쓰입니다.
@freezed
class RankingSummary with _$RankingSummary {
  const factory RankingSummary({
    required int rank,
    required int mmr,
    required int gamesPlayedSeason,
    required double avgPlace,
  }) = _RankingSummary;

  factory RankingSummary.fromJson(Map<String, dynamic> json) =>
      _$RankingSummaryFromJson(json);
}

@freezed
class RecentGame with _$RecentGame {
  const factory RecentGame({
    required int gameId,
    required int playersNumber,
    required String gameType, // "Ranked" | "Unranked"
    required int place,
  }) = _RecentGame;

  factory RecentGame.fromJson(Map<String, dynamic> json) =>
      _$RecentGameFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int userId,
    required String nickname,
    String? avatarUrl,
    required DateTime createdAt,
    @Default([]) List<RecentGame> recentGames,
    // key: 인원수 문자열("2"|"3"|"4")
    @Default({}) Map<String, RankingSummary> rankings,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
