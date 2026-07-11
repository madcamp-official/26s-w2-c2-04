// GET /games/{gameId}/state와 GET /replay/{gameId}의 currentState, 그리고
// GameHub StateSync(full)의 state 필드를 파싱하는 모델.
// 남은 카드들, 토큰들, 귀족들, 각 플레이어들이 가진/찜한 카드, 토큰, 귀족 등을 모두 담습니다.
//
// 실제 GameHub StateSync(full) payload를 로컬 백엔드(backend/Backend/Game/GameState.cs,
// GameHub.cs의 GameHubMessages.BuildFullSync)에 직접 연결해서 확인한 필드 구조를
// 그대로 반영했습니다. players/board/decks는 배열이 아니라 문자열 키(Map)이고,
// 백엔드 PlayerState에는 nickname이 없어서(방 참가자 목록에서 별도로 조회해야 함)
// 이 모델에는 포함하지 않았습니다.

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'card.dart';
import 'noble.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

enum GamePhase {
  @JsonValue('Playing')
  playing,
  @JsonValue('FinalRound')
  finalRound,
  @JsonValue('Finished')
  finished,
}

/// 보드 위 한 티어(1~3층)의 공개 카드와 남은 덱 수.
/// 백엔드 응답을 그대로 반영한 값이 아니라, GameState.board/decks(둘 다 티어별 Map)에서
/// UI가 쓰기 편하도록 파생시킨 값입니다(GameState.boardTiers 참고).
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
/// 백엔드 PlayerState에는 nickname이 없으므로, 화면에 표시할 닉네임은
/// 방(Room) 참가자 목록에서 userId로 조회해야 합니다.
@freezed
class GamePlayerState with _$GamePlayerState {
  const factory GamePlayerState({
    required int userId,
    @Default({}) Map<String, int> tokens, // 보유 토큰 (색상 -> 개수, Gold 포함)
    @Default({}) Map<String, int> bonuses, // 구매한 카드로 얻은 할인 (색상 -> 개수)
    @Default([]) List<SplendorCard> reservedCards,
    @Default([]) List<SplendorCard> purchasedCards,
    @Default([]) List<String> nobles, // 획득한 귀족 id 목록
    @Default(0) int points,
    @Default(0) int totalTokens,
  }) = _GamePlayerState;

  factory GamePlayerState.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerStateFromJson(json);
}

@freezed
class GameState with _$GameState {
  const GameState._();

  const factory GameState({
    required int gameId,
    @Default([]) List<int> playerOrder,
    @Default({}) Map<String, GamePlayerState> players, // key: userId(문자열)
    @Default({}) Map<String, int> tokenBank, // 보드에 남은 토큰 풀 (색상 -> 개수, Gold 포함)
    @Default({}) Map<String, List<SplendorCard>> board, // key: tier("1"|"2"|"3")
    @Default({}) Map<String, List<SplendorCard>> decks, // key: tier, 남은 카드 전체
    @Default([]) List<Noble> boardNobles, // 보드에 남아있는(아직 획득되지 않은) 귀족
    @Default(0) int currentPlayerIndex,
    @Default(1) int turnNumber,
    required GamePhase phase,
    int? lastTurnPlayerId,
    required int sequence, // StateSync 델타 적용 순서 검증 및 RequestResync에 사용
    int? currentPlayerId,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  GamePlayerState? playerById(int userId) => players['$userId'];

  /// playerOrder 순서대로 정렬된 플레이어 목록 (UI 표시용)
  List<GamePlayerState> get playersInOrder => playerOrder
      .map((id) => players['$id'])
      .whereType<GamePlayerState>()
      .toList();

  /// board(공개 카드)/decks(남은 덱)를 티어별로 묶어 UI가 쓰기 편한 형태로 변환합니다.
  List<BoardTier> get boardTiers => [1, 2, 3]
      .map((tier) => BoardTier(
            tier: tier,
            visibleCards: board['$tier'] ?? const [],
            deckRemaining: (decks['$tier'] ?? const []).length,
          ))
      .toList();
}
