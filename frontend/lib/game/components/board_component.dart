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
  final List<SpriteComponent> _deckBackComponents = [];
  final List<NobleComponent> _nobleComponents = [];
  int _generation = 0;

  /// 최신 상태로 보드를 다시 그립니다. 비동기(스프라이트 로딩)라서, 그리는 도중
  /// 더 최신 호출이 들어오면(연속 StateSync) 오래된 호출은 스스로 포기합니다.
  Future<void> updateBoard(GameState state, {required List<String> nobleChoiceIds}) async {
    final myGeneration = ++_generation;
    final size = game.size;

    final me = state.playerById(myUserId);

    final tierRows = <int, List<SplendorCard>>{};
    for (final tier in state.boardTiers) {
      tierRows[tier.tier] = tier.visibleCards;
    }

    final cardW = size.x * 0.085;
    final cardH = cardW * 1.4;
    final gap = size.x * 0.012;
    final leftMargin = size.x * 0.04;
    final tierRowY = {
      3: size.y * 0.06,
      2: size.y * 0.06 + (cardH + gap),
      1: size.y * 0.06 + 2 * (cardH + gap),
    };

    final newCards = <CardComponent>[];
    final newDeckBacks = <SpriteComponent>[];

    for (final tier in [3, 2, 1]) {
      final cards = tierRows[tier] ?? const <SplendorCard>[];
      final y = tierRowY[tier]!;

      final backSprite = await loadSprite(GameAssets.cardBack(tier));
      if (myGeneration != _generation) return;
      newDeckBacks.add(SpriteComponent(
        sprite: backSprite,
        position: Vector2(leftMargin, y),
        size: Vector2(cardW, cardH),
        anchor: Anchor.topLeft,
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
        ));
      }
    }

    // 내 예약 카드 줄(있으면 화면 오른쪽에 세로로 표시)
    if (me != null) {
      final reservedX = leftMargin + (cardW + gap) * 5 + gap * 3;
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
        ));
      }
    }

    // 귀족 줄
    final nobleSize = Vector2.all(cardW * 0.75);
    final nobleY = size.y * 0.01;
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
        onTap: onNobleTap,
      ));
    }

    // 토큰 풀(보드에 남은 보석 은행)
    final tokenSize = Vector2.all(cardW * 0.55);
    final tokenY = tierRowY[1]! + cardH + gap * 3;
    final newGems = <GemTokenComponent>[];
    for (var i = 0; i < Gem.values.length; i++) {
      final gem = Gem.values[i];
      final count = state.tokenBank[gem.wireValue] ?? 0;
      final sprite = await loadSprite(GameAssets.tokenImage(gem.wireValue));
      if (myGeneration != _generation) return;
      newGems.add(GemTokenComponent(
        gem: gem.wireValue,
        count: count,
        sprite: sprite,
        onTap: onGemTap,
        position: Vector2(leftMargin + (tokenSize.x + gap) * i, tokenY),
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
      g.setSelected(selection.gems.contains(g.gem));
    }
  }
}
