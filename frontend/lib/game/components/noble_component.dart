// 보드 위 귀족 타일 하나(스프라이트 + 요구조건 오버레이)를 그립니다. 귀족은
// 조건을 만족하면 서버가 자동으로 부여하므로 기본적으로 탭 액션이 없지만, 동시에
// 여러 귀족 조건을 만족했을 때(NobleChoiceRequired) 고를 수 있도록 탭 콜백을 둡니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
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

    final remaining = remainingRequirement;
    if (remaining != null) {
      // noblePipRatio(정사각 보드 시절 비율 복원)에 1.7배를 더 곱해 카드보다
      // 눈에 잘 띄게 키운다.
      addCostPipRow(
        this,
        amounts: remaining,
        componentSize: size,
        pipDiameter: size.x * noblePipRatio * 1.7,
        centered: true,
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (selectable) onTap?.call(noble);
  }
}
