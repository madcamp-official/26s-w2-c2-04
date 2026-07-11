// leaderboard.dart의 LeaderboardEntry 여러 개를 담고, 페이지네이션 정보와
// 사용자 자신의 rank(myRank) 정보도 담기 위한 모델.
// GET /leaderboard/{playerCount} 와 GET /leaderboard/{playerCount}/search
// 두 응답 모두 이 모델로 파싱합니다. search 응답에는 page/limit/myRank가 없고
// 대신 query가 있으므로 해당 필드들은 nullable로 둡니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'leaderboard.dart';

part 'leaderboard_list_response.freezed.dart';
part 'leaderboard_list_response.g.dart';

@freezed
class LeaderboardListResponse with _$LeaderboardListResponse {
  const factory LeaderboardListResponse({
    required int playerCount,
    int? page, // /search 응답에는 없음
    int? limit, // /search 응답에는 없음
    @Default(0) int total,
    @Default([]) List<LeaderboardEntry> entries,
    LeaderboardEntry? myRank, // /search 응답에는 없음
    String? query, // /search 요청일 때만 채워짐
  }) = _LeaderboardListResponse;

  factory LeaderboardListResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardListResponseFromJson(json);
}
