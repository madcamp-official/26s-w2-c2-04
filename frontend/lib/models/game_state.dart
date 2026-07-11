// GET /games/{gameId}/state와 GET /replay/{gameId}의 currentState, 그리고
// GameHub StateSync(full)의 state 필드를 파싱하는 모델.
// 남은 카드들, 토큰들, 귀족들, 각 플레이어들이 가진/찜한 카드, 토큰, 귀족 등을 모두 담습니다.
//
// 백엔드 README에는 "10.1 스키마 참고"라고만 적혀 있고 실제 스키마 표는 아직
// 작성되지 않았습니다(README 152번째 줄). 아래 구조는 명시된 예시 필드
// (gameId, phase, currentPlayerId, sequence)와 StateSync patch 예시 경로
// (`/players/0/gems/diamond`, `/players/0/score`)에서 역산한 표준 스플랜더 규칙
// 기반 스키마이며, 실제 백엔드 응답과 필드명이 다르면 이 파일만 맞춰 수정하면 됩니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'card.dart';
import 'noble.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

enum GamePhase {
  @JsonValue('WAITING')
  waiting,
  @JsonValue('PLAYING')
  playing,
  @JsonValue('FINAL_ROUND')
  finalRound,
  @JsonValue('FINISHED')
  finished,
}

/// 보드 위 한 티어(1~3층)의 공개 카드와 남은 덱 수.
@freezed
class BoardTier with _$BoardTier {
  const factory BoardTier({
    required int tier,
    @Default([]) List<SplendorCard> visibleCards,
    @Default(0) int deckRemaining,
  }) = _BoardTier;

  factory BoardTier.fromJson(Map<String, dynamic> json) =>
      _$BoardTierFromJson(json);
}

/// 게임 내 한 플레이어의 상태(토큰, 보너스, 예약/구매 카드, 점수).
@freezed
class GamePlayerState with _$GamePlayerState {
  const factory GamePlayerState({
    required String userId,
    required String nickname,
    @Default(0) int score,
    @Default({}) Map<String, int> gems, // 보유 토큰 (색상 -> 개수, gold 포함)
    @Default({}) Map<String, int> bonuses, // 구매한 카드로 얻은 할인 (색상 -> 개수)
    @Default([]) List<SplendorCard> reservedCards,
    @Default([]) List<SplendorCard> purchasedCards,
  }) = _GamePlayerState;

  factory GamePlayerState.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerStateFromJson(json);
}

@freezed
class GameState with _$GameState {
  const GameState._();

  const factory GameState({
    required String gameId,
    required GamePhase phase,
    String? currentPlayerId,
    required int sequence, // StateSync 델타 적용 순서 검증 및 RequestResync에 사용
    @Default(0) int turnNumber,
    @Default([]) List<GamePlayerState> players,
    @Default([]) List<BoardTier> board,
    @Default({}) Map<String, int> tokens, // 보드에 남은 토큰 풀 (색상 -> 개수, gold 포함)
    @Default([]) List<Noble> nobles, // 보드에 남아있는(아직 획득되지 않은) 귀족
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  GamePlayerState? playerById(String userId) =>
      players.where((p) => p.userId == userId).firstOrNull;
}
