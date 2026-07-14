// 카드 비용/귀족 요구조건을 컴포넌트 하단에 보석 색상 pip(원+숫자) 줄로 그리는
// 공용 헬퍼. CardComponent/NobleComponent가 onLoad()에서 각자의 크기 기준으로
// 호출합니다. 카드 원본 아트에 인쇄된 원가 대신, 호출부가 계산해 넘긴 "실제로
// 더 필요한 개수"(비용/요구조건 - 내 보너스)를 그리므로, 내가 보유한 카드가
// 바뀌어 BoardComponent가 보드를 다시 그릴 때마다 자연히 최신 값으로 갱신됩니다.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show FontWeight, TextStyle;
import '../gem_colors.dart';

/// 카드 가격 오버레이 pip 지름 : 카드 폭(cardW) 비율. 정사각 보드 시절 고정
/// 13px 오버레이가 그때의 전형적인 카드 폭(~120px)에서 보이던 크기를 그대로
/// 재현한 값이라, 이후 게임보드 레이아웃이 바뀌어 cardW가 커지거나 작아져도
/// 오버레이가 카드 대비 항상 같은 크기로 보인다.
const double cardPipRatio = 20 / 120;

/// 귀족 요구조건 오버레이 pip 지름 : 귀족 타일 폭(nobleSize.x) 비율. 같은
/// 시절 고정 11px가 당시 귀족 폭(~90px = cardW*0.75)에서 보이던 크기를
/// 재현한 값. 귀족 오버레이는 카드보다 눈에 잘 띄어야 해서(요청에 따라) 최종
/// pipDiameter = nobleSize.x * noblePipRatio * 1.7로, 이 비율 위에 1.7배를
/// 추가로 곱한다(noble_component.dart 참고).
const double noblePipRatio = 6 / 90;

/// [amounts](색상 wireValue -> 남은 개수)를 [parent] 하단에 색상 숫자로 그립니다.
/// [amounts]에 아예 키가 없는 색(그 카드/귀족이 애초에 요구하지 않는 색)은 표기
/// 자체를 건너뛰고, 키가 있는 색은(보너스로 다 상쇄돼 0이 되더라도)
/// gemDisplayOrder(파랑/빨강/초록/검정/흰색) 순서로 표기합니다 — "이 카드가
/// 요구하는 색이 무엇인지"와 "그중 얼마나 남았는지"를 함께 보여주기 위함입니다.
///
/// 예전에는 각 숫자 밑에 보석 색 원(pip)을 깔고 가운데 정렬했지만, 이제는 원 없이
/// 숫자만 보석 색으로 칠해 그립니다(가독성을 위해 어두운 색은 밝게 보정하고,
/// 숫자 뒤에는 얇은 반투명 띠만 깝니다). 카드는 [centered]=false(기본값)로 왼쪽에
/// 몰아 정렬하고, 귀족은 [centered]=true로 가로 중앙 정렬합니다.
///
/// [pipDiameter]는 항상 호출부(CardComponent/NobleComponent)가 자기 컴포넌트
/// 크기(cardW/nobleSize.x)에 비례해 계산해서 넘긴다 — 절대 픽셀 고정값으로 두면
/// 게임보드 레이아웃이 바뀌어 카드/귀족 크기가 달라질 때마다 이 오버레이만
/// 비율이 어긋나(너무 커지거나 작아져) 보이는 문제가 재발하기 때문이다.
void addCostPipRow(
  PositionComponent parent, {
  required Map<String, int> amounts,
  required Vector2 componentSize,
  required double pipDiameter,
  bool centered = false,
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
  final stripWidth = totalWidth.clamp(0, componentSize.x).toDouble();
  final stripHeight = fontSize + 6;
  final y = componentSize.y - stripHeight - 3;
  final stripX = centered ? (componentSize.x - stripWidth) / 2 : 0.0;

  parent.add(RectangleComponent(
    position: Vector2(stripX, y),
    size: Vector2(stripWidth, stripHeight),
    paint: Paint()..color = const Color(0x99140D0A),
  ));

  var x = stripX + leftPad;
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
