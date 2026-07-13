// GET /users/{userId}/stats 응답을 파싱하는 모델. user_profile.dart와 마찬가지로
// 백엔드 엔드포인트가 아직 없어 README 2절 스펙을 그대로 따릅니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats.freezed.dart';
part 'user_stats.g.dart';

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required int userId,
    required int gamesPlayed,
    required int wins,
    required double avgScore,
    required double avgTurns,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}
