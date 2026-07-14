import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/card.dart';
import 'package:splendor_multiplayer/models/game_state.dart';
import 'package:splendor_multiplayer/game/logic/game_rules.dart';

void main() {
  group('isValidTokenSelection', () {
    final bank = {'Diamond': 4, 'Sapphire': 4, 'Emerald': 4, 'Ruby': 1, 'Onyx': 0, 'Gold': 5};

    test('서로 다른 3색 1개씩은 유효하다', () {
      expect(isValidTokenSelection(['Diamond', 'Sapphire', 'Emerald'], bank), isTrue);
    });

    test('동일 색 2개는 은행에 4개 이상 있어야 유효하다', () {
      expect(isValidTokenSelection(['Diamond', 'Diamond'], bank), isTrue);
      expect(isValidTokenSelection(['Ruby', 'Ruby'], bank), isFalse);
    });

    test('골드는 TakeTokens로 선택할 수 없다', () {
      expect(isValidTokenSelection(['Gold', 'Diamond', 'Sapphire'], bank), isFalse);
    });

    test('은행에 재고가 부족한 색은 선택할 수 없다', () {
      expect(isValidTokenSelection(['Diamond', 'Sapphire', 'Onyx'], bank), isFalse);
    });

    test('2색 또는 4색 선택은 유효하지 않다', () {
      expect(isValidTokenSelection(['Diamond', 'Sapphire'], bank), isFalse);
      expect(
        isValidTokenSelection(['Diamond', 'Sapphire', 'Emerald', 'Ruby'], bank),
        isFalse,
      );
    });
  });

  group('canAffordCard / goldNeededFor', () {
    const card = SplendorCard(
      id: 'T1-Diamond-1',
      tier: 1,
      points: 0,
      bonus: 'Diamond',
      cost: {'Sapphire': 3, 'Emerald': 2},
    );

    test('보너스 + 보유 토큰으로 충분하면 골드가 필요 없다', () {
      const player = GamePlayerState(
        userId: 1,
        tokens: {'Sapphire': 3, 'Emerald': 2},
        bonuses: {},
      );
      expect(goldNeededFor(card, player), 0);
      expect(canAffordCard(card, player), isTrue);
    });

    test('보너스만큼 비용이 줄어든다', () {
      const player = GamePlayerState(
        userId: 1,
        tokens: {'Sapphire': 1},
        bonuses: {'Sapphire': 3, 'Emerald': 2},
      );
      expect(goldNeededFor(card, player), 0);
    });

    test('토큰이 부족하면 그만큼 골드가 필요하다', () {
      const player = GamePlayerState(
        userId: 1,
        tokens: {'Sapphire': 1, 'Emerald': 1, 'Gold': 3},
      );
      expect(goldNeededFor(card, player), 3);
      expect(canAffordCard(card, player), isTrue);
    });

    test('골드까지 부족하면 살 수 없다', () {
      const player = GamePlayerState(
        userId: 1,
        tokens: {'Sapphire': 1, 'Emerald': 1, 'Gold': 1},
      );
      expect(canAffordCard(card, player), isFalse);
    });
  });

  group('canReserveMore', () {
    test('예약 카드가 3장 미만이면 더 예약할 수 있다', () {
      const player = GamePlayerState(userId: 1, reservedCards: []);
      expect(canReserveMore(player), isTrue);
    });

    test('예약 카드가 3장이면 더 예약할 수 없다', () {
      const player = GamePlayerState(
        userId: 1,
        reservedCards: [
          SplendorCard(id: 'a', tier: 1, bonus: 'Diamond'),
          SplendorCard(id: 'b', tier: 1, bonus: 'Diamond'),
          SplendorCard(id: 'c', tier: 1, bonus: 'Diamond'),
        ],
      );
      expect(canReserveMore(player), isFalse);
    });
  });
}
