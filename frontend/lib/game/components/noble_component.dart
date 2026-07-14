// 보드 위 귀족 타일 하나(스프라이트 + 점수 배지)를 그립니다. 귀족은 조건을
// 만족하면 서버가 자동으로 부여하므로 기본적으로 탭 액션이 없지만, 동시에 여러
// 귀족 조건을 만족했을 때(NobleChoiceRequired) 고를 수 있도록 탭 콜백을 둡니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;
import '../../models/noble.dart';
import 'cost_pips.dart';

class NobleComponent extends PositionComponent with TapCallbacks {
  final Noble noble;
  final Sprite sprite;
  final bool selectable;

  /// 귀족 요구조건(noble.requirement)에서 내 보너스를 뺀, 아직 더 모아야 하는
  /// 색상별 개수(귀족은 카드 비용과 달리 할인 없이 보너스 개수를 그대로 요구
  /// 조건과 비교합니다). null이면(관전 등) 오버레이 없이 원래 요구조건만
  /// 보여줍니다. 카드 컴포넌트와 마찬가지로 BoardComponent가 매 StateSync마다
  /// 다시 계산해 넘기므로 항상 최신 상태를 반영합니다.
  final Map<String, int>? remainingRequirement;

  final void Function(Noble noble)? onTap;

  NobleComponent({
    required this.noble,
    required this.sprite,
    required Vector2 position,
    required Vector2 size,
    this.selectable = false,
    this.remainingRequirement,
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

    final remaining = remainingRequirement;
    if (remaining != null) {
      addCostPipRow(this, amounts: remaining, componentSize: size, pipDiameter: 11);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (selectable) onTap?.call(noble);
  }
}
