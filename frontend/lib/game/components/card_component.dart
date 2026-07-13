// 보드 위(또는 내 예약 카드 줄)의 카드 한 장을 그리는 컴포넌트.
// 스프라이트는 BoardComponent가 미리 로드해서 넘겨줍니다(SplendorGame이 캐시를
// 갖고 있어서 매번 새로 로드하지 않음) — 이 컴포넌트 자체는 에셋을 로드하지 않습니다.
// 탭하면 부모가 넘겨준 콜백으로 SplendorGame에 선택을 알립니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;
import '../../models/card.dart';

class CardComponent extends PositionComponent with TapCallbacks {
  final SplendorCard card;
  final bool reserved;
  final bool affordable;
  final Sprite sprite;
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

    add(
      TextComponent(
        text: '${card.points}',
        position: Vector2(6, 4),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFF6E6BD),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

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
