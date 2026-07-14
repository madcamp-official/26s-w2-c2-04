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

  /// 골드처럼 TakeTokens로 직접 선택할 수 없는 토큰은 false로 넘겨 탭을
  /// 무시한다(선택 테두리/배지도 절대 표시되지 않음).
  final bool selectable;

  int _selectedCount;
  RectangleComponent? _selectionRing;
  TextComponent? _selectedBadge;

  GemTokenComponent({
    required this.gem,
    required this.count,
    required this.sprite,
    required this.onTap,
    required Vector2 position,
    required Vector2 size,
    this.selectable = true,
    int selectedCount = 0,
    super.priority,
  })  : _selectedCount = selectedCount,
        super(position: position, size: size, anchor: Anchor.topLeft);

  /// 아이콘은 정사각형으로 그리고(가로폭 기준), 그 아래 남는 세로 공간에
  /// 개수 숫자를 별도 줄로 둡니다 — 이전에는 숫자가 아이콘 정사각형 안쪽
  /// 하단에 겹쳐 그려져서 코인 그림과 뒤섞여 보였습니다.
  double get _iconSize => size.x;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _selectionRing = RectangleComponent(
      size: Vector2.all(_iconSize),
      paint: Paint()
        ..color = _selectedCount > 0 ? const Color(0xFFD2AE55) : const Color(0x00000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(_selectionRing!);

    final inset = _iconSize * 0.12;
    add(SpriteComponent(
      sprite: sprite,
      position: Vector2.all(inset),
      size: Vector2.all(_iconSize - inset * 2),
      anchor: Anchor.topLeft,
    ));

    add(
      TextComponent(
        text: '$count',
        position: Vector2(_iconSize / 2, _iconSize + 2),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFF6E6BD),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // 동일 색 2개를 선택했을 때(요구사항: 같은 토큰을 두 번 눌러 2개 선택)
    // 몇 개를 고른 상태인지 한눈에 보이도록 아이콘 우상단에 "×2" 배지를 둡니다.
    _selectedBadge = TextComponent(
      text: _selectedCount == 2 ? '×2' : '',
      position: Vector2(_iconSize - 2, 2),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFD2AE55),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_selectedBadge!);
  }

  void setSelected(int selectedCount) {
    _selectedCount = selectedCount;
    _selectionRing?.paint.color =
        selectedCount > 0 ? const Color(0xFFD2AE55) : const Color(0x00000000);
    _selectedBadge?.text = selectedCount == 2 ? '×2' : '';
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (count > 0 && selectable) onTap(gem);
  }
}
