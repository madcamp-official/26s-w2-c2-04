// 카드 비용/귀족 요구조건을 컴포넌트 하단에 보석 색상 pip(원+숫자) 줄로 그리는
// 공용 헬퍼. CardComponent/NobleComponent가 onLoad()에서 각자의 크기 기준으로
// 호출합니다. 카드 원본 아트에 인쇄된 원가 대신, 호출부가 계산해 넘긴 "실제로
// 더 필요한 개수"(비용/요구조건 - 내 보너스)를 그리므로, 내가 보유한 카드가
// 바뀌어 BoardComponent가 보드를 다시 그릴 때마다 자연히 최신 값으로 갱신됩니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show FontWeight, TextStyle;
import '../gem_colors.dart';

/// [amounts](색상 wireValue -> 남은 개수)를 [parent] 하단 "왼쪽"에 색상 숫자로
/// 그립니다. [amounts]에 아예 키가 없는 색(그 카드/귀족이 애초에 요구하지 않는
/// 색)은 표기 자체를 건너뛰고, 키가 있는 색은(보너스로 다 상쇄돼 0이 되더라도)
/// gemDisplayOrder(파랑/빨강/초록/검정/흰색) 순서로 표기합니다 — "이 카드가
/// 요구하는 색이 무엇인지"와 "그중 얼마나 남았는지"를 함께 보여주기 위함입니다.
///
/// 예전에는 각 숫자 밑에 보석 색 원(pip)을 깔고 가운데 정렬했지만, 이제는 원 없이
/// 숫자만 보석 색으로 칠해 카드 왼쪽으로 몰아 정렬합니다(가독성을 위해 어두운
/// 색은 밝게 보정하고, 숫자 뒤에는 얇은 반투명 띠만 깝니다).
void addCostPipRow(
  PositionComponent parent, {
  required Map<String, int> amounts,
  required Vector2 componentSize,
  double pipDiameter = 13,
}) {
  final entries = [
    for (final wireValue in gemDisplayOrder)
      if (amounts.containsKey(wireValue))
        MapEntry(wireValue, amounts[wireValue]!),
  ];
  if (entries.isEmpty) return;

  const gap = 6.0;
  const leftPad = 5.0;
  final glyphWidth = pipDiameter; // 숫자 한 글자가 차지할 대략적인 폭
  final fontSize = pipDiameter * 0.95;
  final totalWidth =
      leftPad * 2 + entries.length * glyphWidth + (entries.length - 1) * gap;
  final stripHeight = fontSize + 6;
  final y = componentSize.y - stripHeight - 3;

  parent.add(RectangleComponent(
    position: Vector2(0, y),
    size: Vector2(totalWidth.clamp(0, componentSize.x), stripHeight),
    paint: Paint()..color = const Color(0x99140D0A),
  ));

  var x = leftPad;
  for (final entry in entries) {
    parent.add(TextComponent(
      text: '${entry.value}',
      position: Vector2(x, y + stripHeight / 2),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: TextStyle(
          color: _legibleOnDark(gemPipColor(entry.key)),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
    x += glyphWidth + gap;
  }
}

/// 어두운 띠 위에서도 읽히도록 보석 색을 흰색 쪽으로 살짝 당겨 밝힙니다
/// (특히 onyx처럼 어두운 색). 이미 밝은 색(diamond 등)은 큰 변화가 없습니다.
Color _legibleOnDark(Color base) =>
    Color.lerp(base, const Color(0xFFFFFFFF), 0.35)!;
