// 보드 전체(귀족 줄, 티어 1~3 카드 줄 + 덱, 토큰 풀, 내 예약 카드 줄)의 레이아웃과
// 스프라이트 로딩/재구성을 담당합니다. 상태가 바뀔 때마다(StateSync) 자식
// 컴포넌트를 통째로 다시 그립니다 — 카드 몇 장 수준의 데이터라 diff 최적화보다
// 정확성이 우선입니다.

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../../models/card.dart';
import '../../models/game_state.dart';
import '../../models/gem.dart';
import '../../models/noble.dart';
import '../assets.dart';
import '../board_selection.dart';
import '../logic/game_rules.dart';
import 'card_component.dart';
import 'deck_back_component.dart';
import 'gem_component.dart';
import 'noble_component.dart';

class BoardComponent extends PositionComponent with HasGameReference<FlameGame> {
  final int myUserId;
  final Future<Sprite> Function(String path) loadSprite;
  final void Function(SplendorCard card, bool reserved) onCardTap;
  final void Function(String gem) onGemTap;
  final void Function(Noble noble) onNobleTap;

  BoardComponent({
    required this.myUserId,
    required this.loadSprite,
    required this.onCardTap,
    required this.onGemTap,
    required this.onNobleTap,
  });

  final List<CardComponent> _cardComponents = [];
  final List<GemTokenComponent> _gemComponents = [];
  final List<DeckBackComponent> _deckBackComponents = [];
  final List<NobleComponent> _nobleComponents = [];
  int _generation = 0;

  /// 티어별 "자리" 배정(카드 id, 자리 순서 고정). 백엔드는 카드가 팔리면
  /// 목록에서 빼고 새 카드를 맨 뒤에 추가하는 평평한 리스트라서, 매 StateSync의
  /// board[tier] 순서를 그대로 그리면 팔린 카드 뒤의 모든 카드가 한 칸씩
  /// 당겨진 것처럼 보인다. 이전 자리 배정을 기억해뒀다가, 그대로 남아있는
  /// 카드는 같은 자리를 유지하고 팔린 자리에만 새 카드를 채운다.
  final Map<int, List<String>> _tierSlotIds = {};

  List<SplendorCard> _stableTierOrder(int tier, List<SplendorCard> cards) {
    final byId = {for (final c in cards) c.id: c};
    final prevSlotIds = _tierSlotIds[tier] ?? const <String>[];

    final consumed = <String>{};
    final slots = <SplendorCard?>[];
    for (final id in prevSlotIds) {
      final card = byId[id];
      if (card != null) {
        slots.add(card);
        consumed.add(id);
      } else {
        slots.add(null);
      }
    }

    final newcomers = cards.where((c) => !consumed.contains(c.id)).toList();
    for (var i = 0; i < slots.length && newcomers.isNotEmpty; i++) {
      slots[i] ??= newcomers.removeAt(0);
    }
    slots.addAll(newcomers); // 슬롯 수보다 카드가 많아진 경우(초기 호출 등) 뒤에 덧붙인다.

    final ordered = slots.whereType<SplendorCard>().toList();
    _tierSlotIds[tier] = ordered.map((c) => c.id).toList();
    return ordered;
  }

  /// 최신 상태로 보드를 다시 그립니다. 비동기(스프라이트 로딩)라서, 그리는 도중
  /// 더 최신 호출이 들어오면(연속 StateSync) 오래된 호출은 스스로 포기합니다.
  Future<void> updateBoard(GameState state, {required List<String> nobleChoiceIds}) async {
    final myGeneration = ++_generation;
    final size = game.size;

    final me = state.playerById(myUserId);

    final tierRows = <int, List<SplendorCard>>{};
    final deckRemainingByTier = <int, int>{};
    for (final tier in state.boardTiers) {
      tierRows[tier.tier] = tier.visibleCards;
      deckRemainingByTier[tier.tier] = tier.deckRemaining;
    }

    // 카드 폭을 기준으로 간격/귀족/토큰 크기를 모두 비례 산출한 뒤, 실제로 쓰이는
    // 콘텐츠 전체의 가로/세로 크기(contentWidth/contentHeight)를 구해서 "보드
    // 크기 - 콘텐츠 크기"의 남는 공간을 좌우/상하에 똑같이 나눠 마진으로 씁니다.
    // (예전에는 leftMargin=size.x*0.04, topMargin=size.y*0.06처럼 고정 비율이라
    // 실제 콘텐츠가 보드의 절반 정도만 채우고 오른쪽/아래쪽에 쓰이지 않는 공간이
    // 훨씬 크게 남았습니다.)
    // 카드 폭 비율(예전 0.105의 1.5배)을 키운 만큼, 카드 사이 간격 비율은
    // 0.14 -> 0.05로 줄여서 전체 콘텐츠 폭(contentWidth)이 보드 폭을
    // 넘지 않도록 맞췄다(간격은 "기물"이 아니므로 줄여도 1.5배 요구사항과
    // 무관하다).
    final cardW = size.x * 0.1575;
    final cardH = cardW * 1.4;
    final gap = cardW * 0.05;
    final sectionGap = gap * 2; // 티어 카드 줄과 예약 카드 칸 사이 구획 간격
    final nobleSize = Vector2.all(cardW * 0.75);
    final tokenIconSize = cardW * 0.55;
    final tokenLabelHeight = tokenIconSize * 0.4; // 아이콘 밑에 개수를 표시할 공간
    final tokenSize = Vector2(tokenIconSize, tokenIconSize + tokenLabelHeight);

    // 가로: [덱 뒷면] + 공개 카드 4장(티어 줄) + 구획 간격 + 예약 카드 1칸.
    final contentWidth = 5 * cardW + 4 * gap + sectionGap + cardW;
    // 세로: 귀족 줄 + 티어 3줄 + 토큰 줄, 줄 사이 4번의 간격.
    final contentHeight = nobleSize.y + 3 * cardH + tokenSize.y + 4 * gap;

    final double leftMargin =
        ((size.x - contentWidth) / 2).clamp(0.0, size.x).toDouble();
    final double topMargin =
        ((size.y - contentHeight) / 2).clamp(0.0, size.y).toDouble();

    final nobleY = topMargin;
    final tierRowY = {
      3: topMargin + nobleSize.y + gap,
      2: topMargin + nobleSize.y + gap + (cardH + gap),
      1: topMargin + nobleSize.y + gap + 2 * (cardH + gap),
    };

    final newCards = <CardComponent>[];
    final newDeckBacks = <DeckBackComponent>[];

    for (final tier in [3, 2, 1]) {
      final cards = _stableTierOrder(tier, tierRows[tier] ?? const <SplendorCard>[]);
      final y = tierRowY[tier]!;

      final backSprite = await loadSprite(GameAssets.cardBack(tier));
      if (myGeneration != _generation) return;
      newDeckBacks.add(DeckBackComponent(
        sprite: backSprite,
        remaining: deckRemainingByTier[tier] ?? 0,
        position: Vector2(leftMargin, y),
        size: Vector2(cardW, cardH),
      ));

      for (var i = 0; i < cards.length; i++) {
        final card = cards[i];
        final imagePath = GameAssets.cardFace(card.id) ?? GameAssets.cardBack(card.tier);
        final sprite = await loadSprite(imagePath);
        if (myGeneration != _generation) return;

        final affordable = me == null || canAffordCard(card, me);
        newCards.add(CardComponent(
          card: card,
          reserved: false,
          affordable: affordable,
          sprite: sprite,
          onTap: onCardTap,
          position: Vector2(leftMargin + (cardW + gap) * (i + 1), y),
          size: Vector2(cardW, cardH),
          remainingCost: _remainingCostFor(card, me),
        ));
      }
    }

    // 내 예약 카드 줄(있으면 화면 오른쪽에 세로로 표시)
    if (me != null) {
      final reservedX = leftMargin + 5 * cardW + 4 * gap + sectionGap;
      for (var i = 0; i < me.reservedCards.length; i++) {
        final card = me.reservedCards[i];
        final imagePath = GameAssets.cardFace(card.id) ?? GameAssets.cardBack(card.tier);
        final sprite = await loadSprite(imagePath);
        if (myGeneration != _generation) return;

        newCards.add(CardComponent(
          card: card,
          reserved: true,
          affordable: canAffordCard(card, me),
          sprite: sprite,
          onTap: onCardTap,
          position: Vector2(reservedX, tierRowY[3]! + (cardH + gap) * i),
          size: Vector2(cardW, cardH),
          remainingCost: _remainingCostFor(card, me),
        ));
      }
    }

    // 귀족 줄
    final newNobles = <NobleComponent>[];
    for (var i = 0; i < state.boardNobles.length; i++) {
      final noble = state.boardNobles[i];
      final sprite = await loadSprite(GameAssets.nobleImage(noble.id));
      if (myGeneration != _generation) return;
      newNobles.add(NobleComponent(
        noble: noble,
        sprite: sprite,
        position: Vector2(leftMargin + (nobleSize.x + gap) * i, nobleY),
        size: nobleSize,
        selectable: nobleChoiceIds.contains(noble.id),
        remainingRequirement: _remainingRequirementFor(noble, me),
        onTap: onNobleTap,
      ));
    }

    // 토큰 풀(보드에 남은 보석 은행). 골드는 TakeTokens로 선택할 수 없는
    // 와일드카드(예약 시에만 자동 지급)라서 탭으로 선택되지 않게 하고, 다른
    // 5색과 헷갈리지 않도록 구획 간격만큼 떨어뜨려 그린다.
    final tokenY = tierRowY[1]! + cardH + gap;
    final newGems = <GemTokenComponent>[];
    for (var i = 0; i < Gem.values.length; i++) {
      final gem = Gem.values[i];
      final isGold = gem == Gem.gold;
      final count = state.tokenBank[gem.wireValue] ?? 0;
      final sprite = await loadSprite(GameAssets.tokenImage(gem.wireValue));
      if (myGeneration != _generation) return;
      final x = isGold
          ? leftMargin + 5 * (tokenSize.x + gap) + sectionGap
          : leftMargin + (tokenSize.x + gap) * i;
      newGems.add(GemTokenComponent(
        gem: gem.wireValue,
        count: count,
        sprite: sprite,
        onTap: onGemTap,
        selectable: !isGold,
        position: Vector2(x, tokenY),
        size: tokenSize,
      ));
    }

    if (myGeneration != _generation) return;

    for (final c in _cardComponents) {
      c.removeFromParent();
    }
    for (final g in _gemComponents) {
      g.removeFromParent();
    }
    for (final d in _deckBackComponents) {
      d.removeFromParent();
    }
    for (final n in _nobleComponents) {
      n.removeFromParent();
    }

    _cardComponents
      ..clear()
      ..addAll(newCards);
    _gemComponents
      ..clear()
      ..addAll(newGems);
    _deckBackComponents
      ..clear()
      ..addAll(newDeckBacks);
    _nobleComponents
      ..clear()
      ..addAll(newNobles);

    addAll(newDeckBacks);
    addAll(newCards);
    addAll(newGems);
    addAll(newNobles);
  }

  /// 전체를 다시 그리지 않고 선택 하이라이트만 갱신합니다(탭 직후 즉각 반응용).
  void applySelectionHighlight(BoardSelection selection) {
    for (final c in _cardComponents) {
      c.setSelected(selection.card != null && selection.card!.id == c.card.id);
    }
    for (final g in _gemComponents) {
      g.setSelected(selection.gems[g.gem] ?? 0);
    }
  }
}

/// 카드 인쇄 원가에서 [me]의 보너스(구매한 카드 할인)를 뺀, 실제로 더 내야
/// 하는 색상별 개수(logic/game_rules.dart의 goldNeededFor와 같은 규칙). [me]가
/// 없으면(관전 등 "나"를 특정할 수 없는 경우) null을 돌려줘 CardComponent가
/// 오버레이 없이 원본 원가만 보여주게 합니다.
Map<String, int>? _remainingCostFor(SplendorCard card, GamePlayerState? me) {
  if (me == null) return null;
  return {
    for (final entry in card.cost.entries)
      entry.key:
          (entry.value - (me.bonuses[entry.key] ?? 0)).clamp(0, entry.value),
  };
}

/// 귀족 요구조건에서 [me]의 보너스를 뺀, 아직 더 모아야 하는 색상별 개수.
/// 카드 비용과 달리 귀족은 할인 개념이 없어 보너스 개수를 그대로 요구조건과
/// 비교합니다(backend GameEngine의 귀족 자동 획득 판정과 동일한 규칙).
Map<String, int>? _remainingRequirementFor(Noble noble, GamePlayerState? me) {
  if (me == null) return null;
  return {
    for (final entry in noble.requirement.entries)
      entry.key:
          (entry.value - (me.bonuses[entry.key] ?? 0)).clamp(0, entry.value),
  };
}
