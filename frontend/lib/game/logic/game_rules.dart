// 클라이언트 쪽에서 미리 검증해서 UI를 막아주는 순수 규칙 함수들.
// backend/Backend/Game/GameEngine.cs의 TakeTokens/PurchaseCard 검증을 그대로
// 옮긴 것이라, 최종 판정은 항상 서버(GameHub ActionResult/ErrorOccurred)가
// 내리고 여기는 "버튼을 눌러도 되는지" 정도의 보조 판단에만 씁니다.

import '../../models/card.dart';
import '../../models/game_state.dart';

/// TakeTokens 규칙: 서로 다른 3색 각 1개, 또는 동일 색 2개(은행에 4개 이상 있을 때만).
/// gems는 Gem.wireValue(PascalCase, 예 "Diamond") 기준입니다.
bool isValidTokenSelection(List<String> gems, Map<String, int> tokenBank) {
  if (gems.contains('Gold')) return false;

  final counts = <String, int>{};
  for (final gem in gems) {
    counts[gem] = (counts[gem] ?? 0) + 1;
  }

  final isThreeDistinct = counts.length == 3 && counts.values.every((v) => v == 1);
  final isTwoSame = counts.length == 1 && counts.values.single == 2;
  if (!isThreeDistinct && !isTwoSame) return false;

  if (isTwoSame && (tokenBank[counts.keys.single] ?? 0) < 4) return false;

  for (final entry in counts.entries) {
    if ((tokenBank[entry.key] ?? 0) < entry.value) return false;
  }
  return true;
}

/// 카드를 사는 데 부족해서 골드로 대신 내야 하는 개수.
/// (비용 - 보너스)를 우선 보유 토큰으로 내고, 남으면 골드가 필요합니다.
int goldNeededFor(SplendorCard card, GamePlayerState player) {
  var goldNeeded = 0;
  card.cost.forEach((color, amount) {
    final afterBonus = amount - (player.bonuses[color] ?? 0);
    if (afterBonus <= 0) return;
    final fromColor = (player.tokens[color] ?? 0).clamp(0, afterBonus);
    goldNeeded += afterBonus - fromColor;
  });
  return goldNeeded;
}

/// 카드를 지금 살 수 있는지(보유 토큰 + 보너스 + 골드로 충당 가능한지).
bool canAffordCard(SplendorCard card, GamePlayerState player) {
  final gold = player.tokens['Gold'] ?? 0;
  return goldNeededFor(card, player) <= gold;
}

/// 예약 가능한지(예약 카드 3장 초과 금지).
bool canReserveMore(GamePlayerState player) => player.reservedCards.length < 3;
