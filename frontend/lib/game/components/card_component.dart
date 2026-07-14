// 보드 위(또는 내 예약 카드 줄)의 카드 한 장을 그리는 컴포넌트.
// 스프라이트는 BoardComponent가 미리 로드해서 넘겨줍니다(SplendorGame이 캐시를
// 갖고 있어서 매번 새로 로드하지 않음) — 이 컴포넌트 자체는 에셋을 로드하지 않습니다.
// 탭하면 부모가 넘겨준 콜백으로 SplendorGame에 선택을 알립니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../models/card.dart';
import 'cost_pips.dart';

class CardComponent extends PositionComponent with TapCallbacks {
  final SplendorCard card;
  final bool reserved;
  final bool affordable;
  final Sprite sprite;

  /// 카드 인쇄 원가(card.cost)에서 내 보너스(구매한 카드 할인)를 뺀, 실제로
  /// 더 내야 하는 색상별 개수. null이면(관전 등 "나"를 특정할 수 없는 경우)
  /// 오버레이를 그리지 않고 인쇄된 원가만 보여줍니다. BoardComponent가 매
  /// StateSync마다 보드를 통째로 다시 그리므로, 내가 카드를 살 때마다 이 값도
  /// 새로 계산돼 전달되어 오버레이가 항상 최신 상태를 반영합니다.
  final Map<String, int>? remainingCost;

  final void Function(SplendorCard card, bool reserved) onTap;

  bool _selected;
  RectangleComponent? _selectionBorder;

  CardComponent({
    required this.card,
    required this.reserved,
    required this.affordable,
    required this.sprite,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
    this.remainingCost,
    bool selected = false,
    super.priority,
  })  : _selected = selected,
        super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(sprite: sprite, size: size, anchor: Anchor.topLeft));

    if (!affordable) {
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0x88000000),
      ));
    }

    final remaining = remainingCost;
    if (remaining != null) {
      // 카드 폭(size.x)에 비례한 값 — 예전 정사각 보드 시절의 "카드 가격
      // 오버레이 크기 : 카드 크기" 비(고정 13px : 카드폭 ~120px)를 그대로
      // 되살려 고정 비율로 만든 것. 절대 픽셀로 두면 게임보드 레이아웃이
      // 바뀌어 카드가 작아지거나 커질 때마다 오버레이만 비율이 어긋난다.
      addCostPipRow(
        this,
        amounts: remaining,
        componentSize: size,
        pipDiameter: size.x * cardPipRatio,
      );
    }

    _selectionBorder = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = _selected ? const Color(0xFFD2AE55) : const Color(0x00000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    add(_selectionBorder!);
  }

  void setSelected(bool selected) {
    _selected = selected;
    _selectionBorder?.paint.color =
        selected ? const Color(0xFFD2AE55) : const Color(0x00000000);
  }

  bool get isSelected => _selected;

  @override
  void onTapUp(TapUpEvent event) => onTap(card, reserved);
}
