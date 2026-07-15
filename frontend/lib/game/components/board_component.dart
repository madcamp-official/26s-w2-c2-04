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

class BoardComponent extends PositionComponent
    with HasGameReference<FlameGame> {
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

  /// 콘텐츠 가로:세로 비율(정사각형이 아닌 가로로 넓은 직사각형). 아래 updateBoard()가
  /// cardW를 1 단위로 두고 산출하는 레이아웃 상수(가로 = 귀족 열 0.75 + gap 0.05 +
  /// 카드 5열 5.2 + gap 0.05 + 토큰 열 0.45, 세로 = 카드 3행 4.2 + gap 0.1)에서
  /// 그대로 유도된 값이라, 두 상수 세트는 반드시 같이 바뀌어야 한다(어긋나면
  /// updateBoard가 화면에 꽉 차지 않고 leftMargin/topMargin으로 레터박스된다).
  /// play.dart의 _TableLayout이 Flame GameWidget에 배정하는 박스의 가로:세로
  /// 비율도 이 값을 그대로 참조해 여백 없이 맞춘다.
  static const double contentWidthUnits = 6.5;
  static const double contentHeightUnits = 4.3;
  static const double contentAspect = contentWidthUnits / contentHeightUnits;

  /// 주어진 박스([boxWidth] x [boxHeight]) 안에 이 보드를 그릴 때 실제로 쓰일
  /// 미구매 카드 한 장의 크기(가로, 세로). updateBoard()의 cardW/cardH 산출
  /// 공식과 반드시 같은 값을 내야 하므로, updateBoard()도 이 메서드를 그대로
  /// 쓴다. play.dart가 좌석 오버레이의 구매/예약 카드 위젯 크기를 게임보드의
  /// 미구매 카드 크기에 비례해 고정할 때(0.5배) 이 메서드로 같은 cardW/cardH를
  /// 얻는다.
  static Vector2 cardSizeFor(double boxWidth, double boxHeight) {
    final cardW = (boxWidth / contentWidthUnits < boxHeight / contentHeightUnits)
        ? boxWidth / contentWidthUnits
        : boxHeight / contentHeightUnits;
    return Vector2(cardW, cardW * 1.4);
  }

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
  Future<void> updateBoard(GameState state,
      {required List<String> nobleChoiceIds}) async {
    final myGeneration = ++_generation;
    final size = game.size;

    final me = state.playerById(myUserId);

    final tierRows = <int, List<SplendorCard>>{};
    final deckRemainingByTier = <int, int>{};
    for (final tier in state.boardTiers) {
      tierRows[tier.tier] = tier.visibleCards;
      deckRemainingByTier[tier.tier] = tier.deckRemaining;
    }

    // 카드 폭을 기준으로 간격/귀족/토큰 크기를 모두 비례 산출합니다. 보드는
    // 정사각형이 아니라 가로로 넓은 직사각형이라, cardW는 가로 예산과 세로 예산
    // 양쪽에서 각각 산출한 값 중 더 작은 쪽을 씁니다(contentAspect와 어긋난
    // 박스가 들어와도 어느 한쪽이 넘치지 않도록).
    final cardSize = cardSizeFor(size.x, size.y);
    final cardW = cardSize.x;
    final cardH = cardSize.y;
    final gap = cardW * 0.05;
    // 귀족은 미구매 카드 열 "왼쪽"에 세로로, 토큰 뱅크는 "오른쪽"에 세로로 놓는다
    // (예전에는 귀족이 맨 위 가로줄, 토큰이 맨 아래 가로줄이었다 — 보드를
    // 정사각형에서 가로로 넓은 직사각형으로 바꾸면서 세로 공간을 절약하기 위해
    // 옮겼다). 토큰 아이콘은 6개(5색+골드)를 세로로 쌓아야 해서 예전(0.55)보다
    // 작게(0.45) 잡아야 카드 3행 높이 안에 들어온다.
    final nobleSize = Vector2.all(cardW * 0.75);
    final tokenIconSize = cardW * 0.45;
    final tokenLabelHeight = tokenIconSize * 0.4; // 아이콘 밑에 개수를 표시할 공간
    final tokenSize = Vector2(tokenIconSize, tokenIconSize + tokenLabelHeight);

    // 가로: 귀족 열 + [덱 뒷면] + 공개 카드 4장(티어 줄) + 토큰 열. 예약 카드는
    // 더 이상 보드 안에 그리지 않고, 각 플레이어의 게임보드 오버레이
    // (_PlayerCardsRow)에서 보여준다.
    final cardsBlockWidth = 5 * cardW + 4 * gap;
    final contentWidth =
        nobleSize.x + gap + cardsBlockWidth + gap + tokenSize.x;
    // 세로: 티어 3줄 + 그 사이 2번의 간격만큼(귀족/토큰은 이제 별도 열이라 세로
    // 예산에 끼지 않는다 — 대신 이 세로 폭 안에 각각 가운데 정렬로 들어간다).
    final contentHeight = 3 * cardH + 2 * gap;

    final double leftMargin =
        ((size.x - contentWidth) / 2).clamp(0.0, size.x).toDouble();
    final double topMargin =
        ((size.y - contentHeight) / 2).clamp(0.0, size.y).toDouble();

    final cardsX0 = leftMargin + nobleSize.x + gap;
    final tokenColX = cardsX0 + cardsBlockWidth + gap;
    final tierRowY = {
      3: topMargin,
      2: topMargin + (cardH + gap),
      1: topMargin + 2 * (cardH + gap),
    };

    final newCards = <CardComponent>[];
    final newDeckBacks = <DeckBackComponent>[];

    for (final tier in [3, 2, 1]) {
      final cards =
          _stableTierOrder(tier, tierRows[tier] ?? const <SplendorCard>[]);
      final y = tierRowY[tier]!;

      final backSprite = await loadSprite(GameAssets.cardBack(tier));
      if (myGeneration != _generation) return;
      newDeckBacks.add(DeckBackComponent(
        sprite: backSprite,
        remaining: deckRemainingByTier[tier] ?? 0,
        position: Vector2(cardsX0, y),
        size: Vector2(cardW, cardH),
      ));

      for (var i = 0; i < cards.length; i++) {
        final card = cards[i];
        final imagePath =
            GameAssets.cardFace(card.id) ?? GameAssets.cardBack(card.tier);
        final sprite = await loadSprite(imagePath);
        if (myGeneration != _generation) return;

        final affordable = me == null || canAffordCard(card, me);
        newCards.add(CardComponent(
          card: card,
          reserved: false,
          affordable: affordable,
          sprite: sprite,
          onTap: onCardTap,
          position: Vector2(cardsX0 + (cardW + gap) * (i + 1), y),
          size: Vector2(cardW, cardH),
          remainingCost: _remainingCostFor(card, me),
        ));
      }
    }

    // 귀족 열(왼쪽부터 귀족 열 -> 덱 뒷면 -> 미구매 카드 순으로, 세로). 최대
    // 5개(4인전 기준 인원+1)까지 나오지만 세로로 쌓은 총 높이가 contentHeight
    // (카드 3행 높이)를 넘지 않으므로(0.75*5 + gap*4 < 4.2+0.1) 그 안에서
    // 가운데 정렬만 하면 된다.
    final nobleCount = state.boardNobles.length;
    final nobleColumnHeight =
        nobleCount == 0 ? 0.0 : nobleCount * nobleSize.y + (nobleCount - 1) * gap;
    final nobleStartY = topMargin +
        ((contentHeight - nobleColumnHeight) / 2).clamp(0.0, contentHeight);
    final newNobles = <NobleComponent>[];
    for (var i = 0; i < state.boardNobles.length; i++) {
      final noble = state.boardNobles[i];
      final sprite = await loadSprite(GameAssets.nobleImage(noble.id));
      if (myGeneration != _generation) return;
      newNobles.add(NobleComponent(
        noble: noble,
        sprite: sprite,
        position: Vector2(leftMargin, nobleStartY + i * (nobleSize.y + gap)),
        size: nobleSize,
        selectable: nobleChoiceIds.contains(noble.id),
        remainingRequirement: _remainingRequirementFor(noble, me),
        onTap: onNobleTap,
      ));
    }

    // 토큰 풀(보드에 남은 보석 은행, 미구매 카드 오른쪽에 세로 열). 골드는
    // TakeTokens로 선택할 수 없는 와일드카드(예약 시에만 자동 지급)라서 탭으로
    // 선택되지 않게 하고, 다른 5색과 헷갈리지 않도록 그 사이 간격을 두 배로
    // 띄워 그린다. 6개(5색+골드) 세로 스택 높이가 contentHeight 안에 들어오도록
    // tokenIconSize를 위에서 이미 작게(0.45) 잡아뒀다.
    // 토큰 나열 순서는 Gem.displayOrder(sapphire, ruby, emerald, onyx, diamond,
    // gold)로 통일한다 — 보유 토큰/할인 뱅크와 같은 순서라 색 위치가 어긋나지
    // 않는다. gold는 항상 맨 끝이라 아래 "마지막 직전 색↔gold" 사이 간격 로직은
    // 그대로 유효하다.
    const order = Gem.displayOrder;
    const goldExtraGap = 2; // 5색-gold 사이 간격 배수(그 외 색상 사이는 1배)
    final tokenColumnHeight = order.length * tokenSize.y +
        (order.length - 2) * gap +
        goldExtraGap * gap;
    final tokenStartY = topMargin +
        ((contentHeight - tokenColumnHeight) / 2).clamp(0.0, contentHeight);
    final newGems = <GemTokenComponent>[];
    var tokenY = tokenStartY;
    for (var i = 0; i < order.length; i++) {
      final gem = order[i];
      final isGold = gem == Gem.gold;
      final count = state.tokenBank[gem.wireValue] ?? 0;
      final sprite = await loadSprite(GameAssets.tokenImage(gem.wireValue));
      if (myGeneration != _generation) return;
      final x = tokenColX;
      final y = tokenY;
      tokenY += tokenSize.y +
          (i == order.length - 2 ? goldExtraGap * gap : gap);
      newGems.add(GemTokenComponent(
        gem: gem.wireValue,
        count: count,
        sprite: sprite,
        onTap: onGemTap,
        selectable: !isGold,
        position: Vector2(x, y),
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
