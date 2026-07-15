// 카드 비용/귀족 요구조건 오버레이(components/cost_pips.dart)에서 공통으로 쓰는
// 보석 색상 팔레트. Gem.wireValue(PascalCase, "Sapphire" 등)를 키로 받으며,
// theme/app_theme.dart의 AppColors(에메랄드/루비/사파이어)와 톤을 맞췄습니다 —
// 다만 이 파일은 순수 Flame(dart:ui) 쪽이라 Flutter 위젯 테마를 import하지 않고
// 값만 그대로 복제해서 씁니다.

import 'dart:ui';

/// 카드 비용/귀족 요구조건 오버레이 및 좌석 패널의 보너스/구매 카드 줄에서
/// 항상 이 순서(파랑/빨강/초록/검정/흰색)로 보석 색을 나열합니다. gold는 카드
/// 보너스/비용으로 나오지 않으므로 제외합니다.
const List<String> gemDisplayOrder = [
  'Sapphire',
  'Ruby',
  'Emerald',
  'Onyx',
  'Diamond',
];

const Map<String, Color> gemPipColors = {
  'diamond': Color(0xFFE7E1D2),
  'sapphire': Color(0xFF357FC7),
  'emerald': Color(0xFF4CA879),
  'ruby': Color(0xFFBD3045),
  'onyx': Color(0xFF4B4750),
  'gold': Color(0xFFD2AE55),
};

/// pip 배경색 위에 올릴 숫자 색. diamond/gold처럼 밝은 배경엔 어두운 글씨를 씁니다.
const Set<String> _lightGemBackgrounds = {'diamond', 'gold'};

Color gemPipColor(String wireValue) =>
    gemPipColors[wireValue.toLowerCase()] ?? const Color(0xFFD7C8AA);

Color gemPipTextColor(String wireValue) => _lightGemBackgrounds.contains(wireValue.toLowerCase())
    ? const Color(0xFF241811)
    : const Color(0xFFF6E6BD);
