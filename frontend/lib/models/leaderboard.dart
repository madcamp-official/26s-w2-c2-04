// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';

part 'leaderboard.freezed.dart';
part 'leaderboard.g.dart';

/// 리더보드 한 줄(한 명의 랭킹 정보)을 나타내는 모델.
/// GET /leaderboard/{playerCount} 의 entries / myRank 항목과 매칭됩니다.
/// (서버 응답이 flat JSON이라 Player를 중첩시키지 않고 필드를 그대로 매핑합니다)
@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const LeaderboardEntry._();

  const factory LeaderboardEntry({
    required int rank,
    @JsonKey(name: 'userId') required String playerId,
    required String nickname,
    String? avatarUrl,
    required int mmr,
    required double avgPlace,
    required int gamesPlayedSeason,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  // 프로필/아바타 위젯 등 Player를 받는 공통 UI에서 재사용하기 위한 변환
  Player get player =>
      Player(id: playerId, nickname: nickname, avatarUrl: avatarUrl);
}
