// 보드 토큰 풀에 있는 보석 하나의 더미(스프라이트 + 남은 개수 배지)를 그립니다.
// 탭하면 부모가 넘겨준 콜백으로 SplendorGame에 선택/해제를 알립니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

class GemTokenComponent extends PositionComponent with TapCallbacks {
  final String gem; // Gem.wireValue (PascalCase)
  final int count;
  final Sprite sprite;
  final void Function(String gem) onTap;

  bool _selected;
  RectangleComponent? _selectionRing;

  GemTokenComponent({
    required this.gem,
    required this.count,
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

    _selectionRing = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = _selected ? const Color(0xFFD2AE55) : const Color(0x00000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(_selectionRing!);

    final inset = size.x * 0.12;
    add(SpriteComponent(
      sprite: sprite,
      position: Vector2.all(inset),
      size: size - Vector2.all(inset * 2),
      anchor: Anchor.topLeft,
    ));

    add(
      TextComponent(
        text: '$count',
        position: Vector2(size.x / 2, size.y - 4),
        anchor: Anchor.bottomCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFF6E6BD),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void setSelected(bool selected) {
    _selected = selected;
    _selectionRing?.paint.color =
        selected ? const Color(0xFFD2AE55) : const Color(0x00000000);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (count > 0) onTap(gem);
  }
}
