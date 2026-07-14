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

    // Flame의 기본 카메라는 viewfinder.anchor가 Anchor.center라서 world 좌표
    // (0,0)이 화면 "중앙"에 오도록 매핑된다. 그런데 BoardComponent는 자신의
    // (0,0)(좌상단, 기본 Anchor.topLeft)을 기준으로 game.size 전체를 채우도록
    // 카드/귀족/토큰 좌표를 계산한다 — 즉 (0,0)이 화면 "좌상단"이라고 가정한
    // 좌표계다. 이 둘이 어긋나면 보드의 좌상단 1/4만 화면 우하단에 찌그러져
    // 보이는 문제가 생긴다. topLeft로 맞춰서 world (0,0) = 화면 좌상단이 되게
    // 하면, 보드가 정확히 뷰포트 전체를 채우는 구조상 보드의 중심도 자연히
    // 화면 중앙과 일치하게 된다.
    camera.viewfinder.anchor = Anchor.topLeft;

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

    // play.dart의 _GameBoard.initState()는 이 onLoad()가 끝나길 기다리지 않고
    // 곧바로 updateGameState()를 호출할 수 있다(Flame의 onLoad는 비동기라 위젯
    // 마운트 시점과 순서가 보장되지 않음). 그동안 들어온 최신 상태는 이미
    // _latestState/_nobleChoiceIds에 버퍼링돼 있으므로, 보드가 준비된 지금
    // 곧바로 반영해 "첫 프레임에 빈 보드가 보이는" 현상을 막는다.
    final pending = _latestState;
    if (pending != null) {
      await _board.updateBoard(pending, nobleChoiceIds: _nobleChoiceIds);
      _board.applySelectionHighlight(selection.value);
    }
  }

  Future<Sprite> _cachedSprite(String path) async {
    final cached = _spriteCache[path];
    if (cached != null) return cached;
    final sprite = await loadSprite(path);
    _spriteCache[path] = sprite;
    return sprite;
  }

  /// GameController의 GameState가 바뀔 때마다 play.dart가 호출합니다.
  /// onLoad()가 아직 끝나지 않아 _board가 준비되지 않았을 수 있으므로(위젯이
  /// Flame보다 먼저 이 메서드를 호출할 수 있음), 그런 경우엔 상태만 버퍼링해두고
  /// onLoad()가 끝나는 즉시 적용되도록 한다.
  Future<void> updateGameState(GameState state, {List<String> nobleChoiceIds = const []}) async {
    _latestState = state;
    _nobleChoiceIds = nobleChoiceIds;
    if (!isLoaded) return;
    await _board.updateBoard(state, nobleChoiceIds: nobleChoiceIds);
    _board.applySelectionHighlight(selection.value);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;
    final state = _latestState;
    if (state != null) {
      // 액션 바가 늘어나거나 줄어들 때(예: 토큰 1개를 처음 선택해 버튼 줄이
      // 나타날 때)도 이 콜백이 불려 보드를 통째로 다시 그린다. 이때
      // applySelectionHighlight를 다시 불러주지 않으면, 새로 만들어진
      // GemTokenComponent/CardComponent는 선택 상태 없이(테두리 없이) 시작해서
      // 이미 선택돼 있던 토큰의 테두리가 사라진 것처럼 보인다 — 이후 다른
      // 토큰을 선택해 이 메서드가 다시 불려야만 현재 선택이 다시 반영됐다.
      _board.updateBoard(state, nobleChoiceIds: _nobleChoiceIds).then((_) {
        _board.applySelectionHighlight(selection.value);
      });
    }
  }

  // 카드와 토큰은 한 턴에 하나만 고를 수 있는 서로 다른 행동이라, 한쪽을
  // 고르면 반대쪽 선택은 항상 지운다(둘 다 선택된 채로 남는 걸 막는다).
  void _handleCardTap(SplendorCard card, bool reserved) {
    final current = selection.value;
    if (current.card?.id == card.id) {
      selection.value = current.copyWith(clearCard: true);
    } else {
      selection.value = BoardSelection(card: card, cardIsReserved: reserved);
    }
    _board.applySelectionHighlight(selection.value);
  }

  void _handleGemTap(String gem) {
    final tokenBank = _latestState?.tokenBank ?? const <String, int>{};
    selection.value = BoardSelection(
      gems: _nextGemSelection(selection.value.gems, gem, tokenBank),
    );
    _board.applySelectionHighlight(selection.value);
  }

  void _handleNobleTap(Noble noble) => onClaimNoble(noble.id);

  void clearSelection() {
    selection.value = BoardSelection.empty;
    _board.applySelectionHighlight(selection.value);
  }
}

/// 토큰 탭 한 번에 대한 다음 선택 상태를 계산합니다(순수 함수, 테스트하기 쉽게
/// SplendorGame 밖으로 뺐습니다). backend GameEngine.TakeTokens와 동일한 규칙
/// (서로 다른 3색 1개씩, 또는 동일 색 2개(은행에 4개 이상 있을 때만))을 향해서만
/// 상태가 이동하도록 만들어, "완료" 버튼을 누르기 전에도 항상 유효하거나 유효로
/// 가는 중간 상태만 존재하게 합니다.
///
/// - 선택 안 된 색을 탭:
///   - 이미 동일 색 2개가 선택된 상태였다면, 그중 1개를 자동 반납하고(1개로 줄이고)
///     새로 탭한 색을 1개 추가합니다(서로 다른 2색, 1개씩).
///   - 아직 3색 미만이 선택돼 있으면 그대로 추가합니다.
///   - 이미 3색이 다 선택돼 있으면 무시합니다(더 담을 자리가 없음).
/// - 이미 1개 선택된 색을 다시 탭: 은행에 그 색이 4개 이상 남아 있으면 "2개
///   가져가기"로 전환합니다 — 이때 함께 선택돼 있던 다른 색들은 전부 자동
///   반납(2개-1색 조합과 공존 불가능한 조합이므로)하고 이 색만 2개로 남깁니다.
///   은행에 4개 미만이면 2개를 만들 수 없으니 그 색만 반납(해제)합니다.
/// - 이미 2개 선택된(유일한) 색을 다시 탭: 전부 반납(선택 해제)합니다.
Map<String, int> _nextGemSelection(
  Map<String, int> current,
  String gem,
  Map<String, int> tokenBank,
) {
  final currentCount = current[gem] ?? 0;

  if (currentCount == 0) {
    final isTwoSameSelected = current.length == 1 && current.values.single == 2;
    if (isTwoSameSelected) {
      final onlyColor = current.keys.single;
      return {onlyColor: 1, gem: 1};
    }
    if (current.length >= 3) {
      return current;
    }
    return {...current, gem: 1};
  }

  if (currentCount == 1) {
    if ((tokenBank[gem] ?? 0) >= 4) {
      return {gem: 2};
    }
    return (Map<String, int>.from(current)..remove(gem));
  }

  // currentCount == 2
  return const {};
}
