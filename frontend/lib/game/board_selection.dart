// SplendorGame 캔버스에서 사용자가 지금 고른 카드/토큰을 나타내는 값 객체.
// play.dart의 액션 바(구매/예약/토큰 획득 버튼)가 이 값을 구독해서 그립니다.

import '../models/card.dart';

class BoardSelection {
  final SplendorCard? card;
  final bool cardIsReserved;
  // Gem.wireValue(PascalCase) -> 선택한 개수(1 또는 2). 동일 색 2개 선택(은행에
  // 4개 이상 있을 때만 유효, game/logic/game_rules.dart의 isValidTokenSelection
  // 참고)을 표현하려면 Set으로는 중복을 담을 수 없어 Map으로 개수를 셉니다.
  final Map<String, int> gems;

  const BoardSelection({
    this.card,
    this.cardIsReserved = false,
    this.gems = const {},
  });

  bool get isEmpty => card == null && gems.isEmpty;

  /// TakeTokens 서버 호출 페이로드(List<String>, 색상별로 개수만큼 반복) 형태로
  /// 변환합니다. 서버(GameHub.ParseGems)가 리스트 안의 중복 개수를 세어 판정합니다.
  List<String> get gemsAsList => [
        for (final entry in gems.entries)
          for (var i = 0; i < entry.value; i++) entry.key,
      ];

  BoardSelection copyWith({
    SplendorCard? card,
    bool clearCard = false,
    bool? cardIsReserved,
    Map<String, int>? gems,
  }) {
    return BoardSelection(
      card: clearCard ? null : (card ?? this.card),
      cardIsReserved: cardIsReserved ?? this.cardIsReserved,
      gems: gems ?? this.gems,
    );
  }

  static const empty = BoardSelection();
}
