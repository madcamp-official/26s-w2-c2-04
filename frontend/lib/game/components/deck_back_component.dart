// 티어별 덱(아직 뒤집히지 않은 카드 더미)의 뒷면 한 장을 그립니다.
// 우하단에 GameState.boardTiers[tier].deckRemaining(= 보드에 공개된 4장을 제외한
// 남은 카드 수)을 숫자로 표시해, 해당 티어의 카드가 얼마나 남았는지 한눈에
// 보여줍니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

class DeckBackComponent extends PositionComponent {
  final Sprite sprite;
  final int remaining;

  DeckBackComponent({
    required this.sprite,
    required this.remaining,
    required Vector2 position,
    required Vector2 size,
    super.priority,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(sprite: sprite, size: size, anchor: Anchor.topLeft));

    add(
      TextComponent(
        text: '$remaining',
        position: Vector2(size.x - 6, size.y - 4),
        anchor: Anchor.bottomRight,
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
}
