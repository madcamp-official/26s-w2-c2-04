// 보드 위 귀족 타일 하나(스프라이트 + 점수 배지)를 그립니다. 귀족은 조건을
// 만족하면 서버가 자동으로 부여하므로 기본적으로 탭 액션이 없지만, 동시에 여러
// 귀족 조건을 만족했을 때(NobleChoiceRequired) 고를 수 있도록 탭 콜백을 둡니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;
import '../../models/noble.dart';

class NobleComponent extends PositionComponent with TapCallbacks {
  final Noble noble;
  final Sprite sprite;
  final bool selectable;
  final void Function(Noble noble)? onTap;

  NobleComponent({
    required this.noble,
    required this.sprite,
    required Vector2 position,
    required Vector2 size,
    this.selectable = false,
    this.onTap,
    super.priority,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(sprite: sprite, size: size, anchor: Anchor.topLeft));

    if (selectable) {
      add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFFD2AE55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ));
    }

    add(
      TextComponent(
        text: '${noble.points}',
        position: Vector2(4, 4),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFF6E6BD),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (selectable) onTap?.call(noble);
  }
}
