// 카드 비용/귀족 요구조건을 컴포넌트 하단에 보석 색상 pip(원+숫자) 줄로 그리는
// 공용 헬퍼. CardComponent/NobleComponent가 onLoad()에서 각자의 크기 기준으로
// 호출합니다. 카드 원본 아트에 인쇄된 원가 대신, 호출부가 계산해 넘긴 "실제로
// 더 필요한 개수"(비용/요구조건 - 내 보너스)를 그리므로, 내가 보유한 카드가
// 바뀌어 BoardComponent가 보드를 다시 그릴 때마다 자연히 최신 값으로 갱신됩니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show FontWeight, TextStyle;
import '../gem_colors.dart';

/// [amounts](색상 wireValue -> 남은 개수)를 [parent] 하단 가운데에 pip로 그립니다.
/// 0 이하인 색상은 건너뜁니다. gemDisplayOrder(파랑/빨강/초록/검정/흰색) 순서를
/// 그대로 따라 항상 같은 자리에 같은 색이 나오게 합니다.
void addCostPipRow(
  PositionComponent parent, {
  required Map<String, int> amounts,
  required Vector2 componentSize,
  double pipDiameter = 13,
}) {
  final entries = [
    for (final wireValue in gemDisplayOrder)
      if ((amounts[wireValue] ?? 0) > 0) MapEntry(wireValue, amounts[wireValue]!),
  ];
  if (entries.isEmpty) return;

  const gap = 3.0;
  final totalWidth = entries.length * pipDiameter + (entries.length - 1) * gap;
  var x = (componentSize.x - totalWidth) / 2;
  final y = componentSize.y - pipDiameter - 4;

  parent.add(RectangleComponent(
    position: Vector2(0, y - 3),
    size: Vector2(componentSize.x, pipDiameter + 6),
    paint: Paint()..color = const Color(0x99140D0A),
  ));

  for (final entry in entries) {
    parent.add(CircleComponent(
      radius: pipDiameter / 2,
      position: Vector2(x, y),
      paint: Paint()..color = gemPipColor(entry.key),
    ));
    parent.add(TextComponent(
      text: '${entry.value}',
      position: Vector2(x + pipDiameter / 2, y + pipDiameter / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: gemPipTextColor(entry.key),
          fontSize: pipDiameter * 0.62,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
    x += pipDiameter + gap;
  }
}
