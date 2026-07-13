// SplendorGame 캔버스에서 사용자가 지금 고른 카드/토큰을 나타내는 값 객체.
// play.dart의 액션 바(구매/예약/토큰 획득 버튼)가 이 값을 구독해서 그립니다.

import '../models/card.dart';

class BoardSelection {
  final SplendorCard? card;
  final bool cardIsReserved;
  final Set<String> gems; // Gem.wireValue 기준(PascalCase)

  const BoardSelection({
    this.card,
    this.cardIsReserved = false,
    this.gems = const {},
  });

  bool get isEmpty => card == null && gems.isEmpty;

  BoardSelection copyWith({
    SplendorCard? card,
    bool clearCard = false,
    bool? cardIsReserved,
    Set<String>? gems,
  }) {
    return BoardSelection(
      card: clearCard ? null : (card ?? this.card),
      cardIsReserved: cardIsReserved ?? this.cardIsReserved,
      gems: gems ?? this.gems,
    );
  }

  static const empty = BoardSelection();
}
