// 실시간 게임 보드를 그리는 Flame 엔트리포인트.
// Riverpod과는 직접 얽히지 않고, play.dart가 GameController의 상태 변화를
// updateGameState()로 밀어넣고 액션 콜백(onTakeTokens 등)을 통해 결과를
// 받아가는 구조입니다 — 즉 이 파일은 순수하게 "보드 렌더링 + 입력 캡처"만 합니다.

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../models/game_state.dart';
import '../models/noble.dart';
import 'board_selection.dart';
import 'components/board_component.dart';

class SplendorGame extends FlameGame {
  final int myUserId;

  /// 카드/토큰 탭은 이 게임 안에서 선택 상태([selection])만 바꾸고, 실제
  /// 구매/예약/토큰 획득 호출은 play.dart의 액션 바가 [selection]을 구독해서
  /// 수행합니다. 귀족만 예외 — NobleChoiceRequired 상황에서는 탭이 곧 선택
  /// 확정이라 별도 확인 버튼 없이 바로 이 콜백을 호출합니다.
  final void Function(String nobleId) onClaimNoble;

  SplendorGame({
    required this.myUserId,
    required this.onClaimNoble,
  });

  final ValueNotifier<BoardSelection> selection = ValueNotifier(BoardSelection.empty);

  late final BoardComponent _board;
  GameState? _latestState;
  List<String> _nobleChoiceIds = const [];
  final Map<String, Sprite> _spriteCache = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 실제 카드/귀족/토큰 아트는 assets/image/ 아래에 있는데(assets/images/가
    // 아니라 image 단수), Flame의 기본 prefix는 'assets/images/'라서 맞춰줍니다.
    images.prefix = 'assets/image/';

    _board = BoardComponent(
      myUserId: myUserId,
      loadSprite: _cachedSprite,
      onCardTap: _handleCardTap,
      onGemTap: _handleGemTap,
      onNobleTap: _handleNobleTap,
    );
    world.add(_board);
  }

  Future<Sprite> _cachedSprite(String path) async {
    final cached = _spriteCache[path];
    if (cached != null) return cached;
    final sprite = await loadSprite(path);
    _spriteCache[path] = sprite;
    return sprite;
  }

  /// GameController의 GameState가 바뀔 때마다 play.dart가 호출합니다.
  Future<void> updateGameState(GameState state, {List<String> nobleChoiceIds = const []}) async {
    _latestState = state;
    _nobleChoiceIds = nobleChoiceIds;
    await _board.updateBoard(state, nobleChoiceIds: nobleChoiceIds);
    _board.applySelectionHighlight(selection.value);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final state = _latestState;
    if (state != null) {
      _board.updateBoard(state, nobleChoiceIds: _nobleChoiceIds);
    }
  }

  void _handleCardTap(SplendorCard card, bool reserved) {
    final current = selection.value;
    if (current.card?.id == card.id) {
      selection.value = current.copyWith(clearCard: true);
    } else {
      selection.value = BoardSelection(card: card, cardIsReserved: reserved, gems: current.gems);
    }
    _board.applySelectionHighlight(selection.value);
  }

  void _handleGemTap(String gem) {
    final current = Set<String>.from(selection.value.gems);
    if (current.contains(gem)) {
      current.remove(gem);
    } else if (current.length < 3) {
      current.add(gem);
    }
    selection.value = selection.value.copyWith(gems: current);
    _board.applySelectionHighlight(selection.value);
  }

  void _handleNobleTap(Noble noble) => onClaimNoble(noble.id);

  void clearSelection() {
    selection.value = BoardSelection.empty;
    _board.applySelectionHighlight(selection.value);
  }
}
