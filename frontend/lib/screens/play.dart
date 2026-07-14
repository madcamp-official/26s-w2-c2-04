import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/assets.dart';
import '../game/board_selection.dart';
import '../game/components/board_component.dart';
import '../game/gem_colors.dart';
import '../game/logic/game_rules.dart';
import '../game/splendor_game.dart';
import '../models/card.dart';
import '../models/game_hub_event.dart';
import '../models/game_state.dart';
import '../models/gameroom.dart';
import '../models/gem.dart';
import '../state/active_room_controller.dart';
import '../state/auth_controller.dart';
import '../state/game_controller.dart';
import '../state/lobby_controller.dart';
import '../theme/app_theme.dart';
import 'friends.dart';
import 'profile.dart';
import 'settings.dart';

/// 방 대기실 + 실제 게임 진행 화면.
/// GameHub 연결 전(WAITING)에는 대기실 UI를, 연결 후(PLAYING)에는 Flame으로 그린
/// 보드(카드/귀족/토큰) + 액션 바 + 플레이어 목록 + 채팅을 보여줍니다.
class PlayScreen extends ConsumerStatefulWidget {
  final GameRoom room;

  /// true면 대기실(플레이어 슬롯/START 버튼) UI를 건너뛰고 바로 GameHub에 연결합니다.
  /// 방 목록/방장 개념이 없는 진입 경로(예: 랭크 매칭)에서 사용합니다. 이 화면은
  /// "왜" 자동 연결해야 하는지는 몰라도 되므로, 랭크 여부 같은 도메인 지식을
  /// widget 파라미터로 들여오지 않습니다.
  final bool autoConnect;

  /// 방 만들기 화면에서 입력한 표시용 방 이름(로컬 전용, 서버에는 저장되지 않음).
  final String? localLabel;

  const PlayScreen({
    super.key,
    required this.room,
    this.autoConnect = false,
    this.localLabel,
  });

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> with RouteAware {
  late final SplendorGame _splendorGame;

  int get _myUserId {
    final auth = ref.read(authControllerProvider);
    return auth is AuthAuthenticated ? auth.user.userId : 0;
  }

  bool get _isHost {
    final auth = ref.read(authControllerProvider);
    return auth is AuthAuthenticated && widget.room.hostId == auth.user.userId;
  }

  @override
  void initState() {
    super.initState();
    _splendorGame = SplendorGame(
      myUserId: _myUserId,
      onClaimNoble: (nobleId) =>
          ref.read(gameControllerProvider.notifier).claimNoble(nobleId),
    );

    // 게임 시작 전까지는 이 방에 들어가 있다는 걸 앱 전역에 기록해둔다.
    // 화면을 벗어나도(뒤로가기) 좌하단 배지로 남아 있다가, 다시 눌러 이
    // PlayScreen으로 돌아올 수 있게 해준다(state/active_room_controller.dart 참고).
    // roomScreenVisible은 이 화면이 떠 있는 동안(=dispose 전까지) true로 둬서,
    // 배지가 자기 자신이 띄운 이 화면 위에 겹쳐 보이지 않도록 한다.
    Future.microtask(() {
      ref.read(activeRoomProvider.notifier).state = widget.room;
      ref.read(roomScreenVisibleProvider.notifier).state = true;
    });

    // 대기실 단계에서도 GameHub에 바로 연결해 PlayerJoined/PlayerLeft를 실시간으로
    // 받는다. 게임이 이미 진행 중이면(autoConnect 경로 등) connect() 도중 StateSync가
    // 도착해 곧바로 GameConnected로 넘어간다.
    Future.microtask(() {
      final auth = ref.read(authControllerProvider);
      if (auth is AuthAuthenticated) {
        ref.read(gameControllerProvider.notifier).connect(
              roomId: widget.room.roomId,
              accessToken: auth.user.accessToken,
              initialPlayers: widget.room.players,
            );
      }
    });
  }

  Future<void> _startGame() async {
    try {
      // GameHub 연결은 대기실 진입 시(initState) 이미 이뤄졌으므로 여기서는 REST로
      // 시작만 알리면 된다. 백엔드가 방 그룹 전체에 StateSync를 브로드캐스트하므로
      // 이미 연결된 다른 참가자들도 자동으로 GameConnected로 넘어간다.
      final result =
          await ref.read(roomServiceProvider).startGame(widget.room.roomId);
      // result.gameId는 재접속 시 GET /games/{gameId}/state 폴백에 사용됩니다.
      debugPrint('게임 시작됨: ${result.gameId} (${result.phase})');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _takeTokens(List<String> gems) {
    return ref.read(gameControllerProvider.notifier).takeTokens(gems);
  }

  Future<void> _purchase(SplendorCard card, {required bool reserved}) {
    return ref.read(gameControllerProvider.notifier).purchaseCard(
          cardId: card.id,
          source: reserved ? 'Reserved' : 'Board',
        );
  }

  Future<void> _reserve(SplendorCard card) {
    return ref
        .read(gameControllerProvider.notifier)
        .reserveCard(cardId: card.id);
  }

  Future<void> _discardTokens(List<String> gems) {
    return ref.read(gameControllerProvider.notifier).discardTokens(gems);
  }

  /// AppBar(대기실 단계)와 게임 화면 우하단 버튼 묶음(플레이 단계) 양쪽에서
  /// 공유하는 "나가기" 로직. REST 퇴장/Hub LeaveRoom 중 하나가 네트워크 문제로
  /// 실패하더라도(예: 배지로 최소화했다가 복귀한 직후처럼 연결이 막 재수립된
  /// 상황), 배지 해제와 화면 나가기는 항상 이뤄져야 한다 — 그렇지 않으면 버튼이
  /// 아무 반응도 없는 것처럼 보이고 좌하단 배지도 계속 남아 다른 참가자에게
  /// 실제 퇴장이 전달됐는지 알 수 없게 된다.
  Future<void> _leaveRoom({required bool isPlaying}) async {
    try {
      if (isPlaying) {
        await ref.read(gameControllerProvider.notifier).leaveRoom();
      } else {
        // 대기실 단계(GameWaitingRoom 등)는 REST로 방을 나가는 것과 별개로,
        // Hub 그룹에서도 빠져나가 다른 대기 참가자에게 PlayerLeft를 알려야 한다.
        await ref
            .read(lobbyControllerProvider.notifier)
            .leaveRoom(widget.room.roomId);
        await ref.read(gameControllerProvider.notifier).leaveRoom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('나가기 처리 중 문제: $e')));
      }
    } finally {
      ref.read(activeRoomProvider.notifier).state = null;
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 이 화면이 얹혀 있는 라우트의 pop을 didPop으로 통지받기 위해 구독한다.
    final route = ModalRoute.of(context);
    if (route != null) playRouteObserver.subscribe(this, route);
  }

  /// 이 화면의 라우트가 pop되는 "순간"(뒤로가기/나가기 버튼의 이벤트 핸들러 안에서
  /// Navigator가 동기 호출) 배지 숨김 플래그를 내린다 — activeRoomProvider 자체는
  /// 건드리지 않는다(그 방에 아직 들어가 있다는 사실은 유효하므로, 배지 표시
  /// 여부만 바꾼다). dispose는 pop 애니메이션이 끝난 뒤 프레임의 finalizeTree
  /// 단계에서야 실행돼 provider 변경 타이밍이 위태롭고(빌드 중 변경 금지, idle이면
  /// postFrameCallback이 영영 안 옴), teardown 중 예외가 나면 통째로 건너뛰어질 수
  /// 있어 여기서 처리하는 것이 구조적으로 안전하다.
  @override
  void didPop() {
    ref.read(roomScreenVisibleProvider.notifier).state = false;
  }

  @override
  void dispose() {
    playRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);

    ref.listen<GameControllerState>(gameControllerProvider, (previous, next) {
      if (next is GameConnected && next.gameOver != null) {
        _showGameOverDialog(next.gameOver!);
      }
      // 게임이 실제로 시작되면(StateSync 수신) 좌하단 "방으로 돌아가기" 배지는
      // 더 이상 필요 없다 — 대기실 단계에서만 쓰는 기능이다.
      if (previous is! GameConnected && next is GameConnected) {
        ref.read(activeRoomProvider.notifier).state = null;
      }
      // 입장/퇴장/최종 라운드/시간초과 등 일회성 안내(notice)를 스낵바로 띄운다.
      final prevNotice = previous is GameConnected ? previous.notice : null;
      if (next is GameConnected &&
          next.notice != null &&
          next.notice != prevNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.notice!),
              duration: const Duration(seconds: 3)),
        );
      }
    });

    return Scaffold(
      // 게임이 실제로 시작되면(GameConnected) 뒤로가기/방 이름/턴 정보를 보여주던
      // 상단 바를 완전히 없앤다 — 그만큼 생긴 여유는 _GameBoard의 게임보드가
      // 그대로 흡수한다(아래 _GameBoard.build() 참고). "나가기"는 이 상태에서
      // 사라지지 않도록 _GameBoard 우하단 버튼 묶음으로 옮겨서 유지한다.
      appBar: gameState is GameConnected
          ? null
          : AppBar(
              title: Text(widget.localLabel ?? '방 ${widget.room.roomId}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  tooltip: '나가기',
                  onPressed: () =>
                      _leaveRoom(isPlaying: gameState is GameConnected),
                ),
              ],
            ),
      body: switch (gameState) {
        GameConnecting() => Center(
            child: widget.autoConnect
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('다른 연금술사들을 기다리는 중입니다…\n정원이 차면 자동으로 시작됩니다.',
                          textAlign: TextAlign.center),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        GameError(:final message) => Center(child: Text('연결 실패: $message')),
        GameConnected(
          :final gameState,
          :final pendingNobleChoice,
          :final players,
          :final turnTimeoutSeq
        ) =>
          _GameBoard(
            room: widget.room.copyWith(players: players),
            gameState: gameState,
            pendingNobleChoice: pendingNobleChoice,
            turnTimeoutSeq: turnTimeoutSeq,
            game: _splendorGame,
            onPurchase: _purchase,
            onReserve: _reserve,
            onTakeTokens: _takeTokens,
            onDiscardTokens: _discardTokens,
            onLeaveRoom: () => _leaveRoom(isPlaying: true),
          ),
        GameWaitingRoom(:final players, :final readyPlayerIds) => _WaitingRoom(
            room: widget.room.copyWith(players: players),
            isHost: _isHost,
            myUserId: _myUserId,
            readyPlayerIds: readyPlayerIds,
            onStart: _startGame,
            onToggleReady: (ready) => ref
                .read(gameControllerProvider.notifier)
                .setReady(ready: ready),
          ),
        GameDisconnected() => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  void _showGameOverDialog(GameHubGameOver gameOver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게임 종료'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('승자: ${gameOver.winnerId}'),
            const SizedBox(height: 8),
            ...gameOver.finalScores
                .map((s) => Text('${s.userId}: ${s.score}점')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('로비로'),
          ),
        ],
      ),
    );
  }
}

class _WaitingRoom extends StatelessWidget {
  final GameRoom room;
  final bool isHost;
  final int myUserId;
  final Set<int> readyPlayerIds;
  final VoidCallback onStart;
  final ValueChanged<bool> onToggleReady;
  const _WaitingRoom({
    required this.room,
    required this.isHost,
    required this.myUserId,
    required this.readyPlayerIds,
    required this.onStart,
    required this.onToggleReady,
  });

  /// 방장 본인을 제외한 참가자 전원이 준비를 마쳤는지. 방장에게는 준비 토글이
  /// 없으므로(시작 버튼 자체가 방장의 의사 표시) 이 값만 만족하면 시작할 수 있다.
  bool get _allOthersReady => room.players
      .where((p) => p.id != room.hostId)
      .every((p) => readyPlayerIds.contains(p.id));

  @override
  Widget build(BuildContext context) {
    final canStart = isHost && _allOthersReady;
    return GemBackdrop(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child:
                OrnateTitle(kicker: 'Private table', title: '방 ${room.roomId}'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${room.maxPlayers}인 테이블',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                for (final player in room.players)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlayerSlot(
                      name: player.nickname,
                      avatarUrl: player.avatarUrl,
                      isHost: player.id == room.hostId,
                      isReady: readyPlayerIds.contains(player.id),
                      showReadyToggle: !isHost && player.id == myUserId,
                      onToggleReady: player.id == myUserId
                          ? () =>
                              onToggleReady(!readyPlayerIds.contains(myUserId))
                          : null,
                    ),
                  ),
                for (var i = room.players.length; i < room.maxPlayers; i++)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: _PlayerSlot(
                      name: '자리를 기다리는 중…',
                      avatarUrl: null,
                      isHost: false,
                      empty: true,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canStart ? onStart : null,
                child: Text(
                  isHost
                      ? (_allOthersReady
                          ? '게임 시작'
                          : '모든 참가자가 준비할 때까지 기다리는 중...')
                      : '방장이 시작하기를 기다리는 중...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerSlot extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isHost;
  final bool empty;
  final bool isReady;
  final bool showReadyToggle;
  final VoidCallback? onToggleReady;
  const _PlayerSlot({
    required this.name,
    required this.avatarUrl,
    required this.isHost,
    this.empty = false,
    this.isReady = false,
    this.showReadyToggle = false,
    this.onToggleReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: empty ? null : AppColors.goldFaint.withValues(alpha: 0.06),
        border: Border.all(
          color: empty
              ? AppColors.goldHairline
              : AppColors.gold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          if (empty)
            const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.people_outline,
                  color: AppColors.textMuted, size: 18),
            )
          else
            CircleAvatar(
              backgroundColor: avatarToneFor(name),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      name.characters.first,
                      style: const TextStyle(
                          color: AppColors.textHeading, fontSize: 13),
                    )
                  : null,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: empty ? AppColors.textMuted : AppColors.textHeading,
                fontSize: 14,
              ),
            ),
          ),
          if (isHost)
            Text('HOST', style: kickerStyle(size: 10, color: AppColors.gold))
          else if (!empty && showReadyToggle)
            OutlinedButton(
              onPressed: onToggleReady,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                    color: isReady ? AppColors.gold : AppColors.goldHairline),
              ),
              child: Text(
                isReady ? '준비 완료' : '준비하기',
                style: TextStyle(
                    fontSize: 11,
                    color: isReady ? AppColors.gold : AppColors.textMuted),
              ),
            )
          else if (!empty)
            Text(
              isReady ? 'READY' : 'WAITING',
              style: kickerStyle(
                  size: 10,
                  color: isReady ? AppColors.gold : AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

/// Flame 보드 + 액션 바 + 플레이어 목록 + 채팅. gameState/pendingNobleChoice가
/// 바뀔 때마다(didUpdateWidget) SplendorGame에 새 상태를 밀어넣습니다.
class _GameBoard extends StatefulWidget {
  final GameRoom room;
  final GameState gameState;
  final List<String>? pendingNobleChoice;
  // 시간초과로 턴이 강제 종료될 때마다 늘어나는 카운터(game_controller.dart의
  // GameConnected.turnTimeoutSeq). 값이 바뀔 때마다 중앙 토스트를 띄운다.
  final int turnTimeoutSeq;
  final SplendorGame game;
  final Future<void> Function(SplendorCard card, {required bool reserved})
      onPurchase;
  final Future<void> Function(SplendorCard card) onReserve;
  final Future<void> Function(List<String> gems) onTakeTokens;
  final Future<void> Function(List<String> gems) onDiscardTokens;
  final Future<void> Function() onLeaveRoom;

  const _GameBoard({
    required this.room,
    required this.gameState,
    required this.pendingNobleChoice,
    required this.turnTimeoutSeq,
    required this.game,
    required this.onPurchase,
    required this.onReserve,
    required this.onTakeTokens,
    required this.onDiscardTokens,
    required this.onLeaveRoom,
  });

  @override
  State<_GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<_GameBoard> {
  bool _showTimeoutToast = false;
  Timer? _timeoutToastTimer;

  @override
  void initState() {
    super.initState();
    _pushStateToGame();
    // 보드 위 카드를 탭하면 SplendorGame이 inspect에 그 카드를 실어주고, 여기서
    // 상세 팝업(이미지/할인 전 가격/구매·예약)을 띄운다.
    widget.game.inspect.addListener(_onInspect);
  }

  @override
  void didUpdateWidget(covariant _GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState.sequence != widget.gameState.sequence ||
        oldWidget.pendingNobleChoice != widget.pendingNobleChoice) {
      _pushStateToGame();
    }
    if (oldWidget.turnTimeoutSeq != widget.turnTimeoutSeq) {
      _flashTimeoutToast();
    }
  }

  void _flashTimeoutToast() {
    _timeoutToastTimer?.cancel();
    setState(() => _showTimeoutToast = true);
    _timeoutToastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showTimeoutToast = false);
    });
  }

  @override
  void dispose() {
    _timeoutToastTimer?.cancel();
    widget.game.inspect.removeListener(_onInspect);
    super.dispose();
  }

  void _pushStateToGame() {
    widget.game.updateGameState(
      widget.gameState,
      nobleChoiceIds: widget.pendingNobleChoice ?? const [],
    );
  }

  void _onInspect() {
    final req = widget.game.inspect.value;
    if (req == null) return;
    widget.game.inspect.value = null; // 한 번 소비하고 비운다
    // 보드 위 카드(미구매) 또는 내 예약 카드는 실제로 구매/예약이 가능하다.
    _showCardDetail(req.card, reserved: req.reserved, actionable: true);
  }

  /// 카드 상세 팝업. 보드 미구매 카드/내 예약 카드는 물론, 좌석 패널의 구매·예약
  /// 카드 썸네일에서도 같은 팝업을 띄운다. [actionable]이 false면(이미 구매된
  /// 카드나 다른 사람의 예약 카드) 정보만 보여주고 구매/예약 버튼은 내지 않는다.
  Future<void> _showCardDetail(
    SplendorCard card, {
    required bool reserved,
    required bool actionable,
  }) async {
    final me = widget.gameState.playerById(widget.game.myUserId);
    final myTurn = widget.gameState.currentPlayerId == widget.game.myUserId;
    final mustDiscard = me != null && myTurn && me.totalTokens > 10;
    final canAct = actionable && me != null && myTurn && !mustDiscard;
    final canBuy = canAct && canAffordCard(card, me);
    // 예약은 아직 내 예약 카드가 아닌(보드 위) 카드만, 예약 칸(3장)이 남았을 때.
    final canReserve = canAct && !reserved && canReserveMore(me);

    await showDialog<void>(
      context: context,
      builder: (ctx) => _CardDetailDialog(
        card: card,
        reserved: reserved,
        canBuy: canBuy,
        canReserve: canReserve,
        onBuy: () {
          Navigator.of(ctx).pop();
          _purchaseCard(card, reserved: reserved);
        },
        onReserve: () {
          Navigator.of(ctx).pop();
          _reserveCard(card);
        },
      ),
    );
  }

  Future<void> _purchaseCard(SplendorCard card,
      {required bool reserved}) async {
    await widget.onPurchase(card, reserved: reserved);
    widget.game.clearSelection();
  }

  Future<void> _reserveCard(SplendorCard card) async {
    await widget.onReserve(card);
    widget.game.clearSelection();
  }

  Future<void> _confirmTokens(BoardSelection selection) async {
    if (selection.gems.isEmpty) return;
    await widget.onTakeTokens(selection.gemsAsList);
    widget.game.clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.gameState.playerById(widget.game.myUserId);
    // 서버는 내 토큰이 10개를 초과하면 반납(DiscardTokens) 전까지 내 턴의 다른
    // 모든 행동을 막는다(EnsureNotAwaitingDiscard) — 그동안은 평소 액션 바 대신
    // 반납 전용 UI를 보여준다.
    final mustDiscard = me != null &&
        widget.gameState.currentPlayerId == widget.game.myUserId &&
        me.totalTokens > 10;

    return Column(
      children: [
        // 뒤로가기/방 이름/턴 번호/현재 차례를 보여주던 상단 바는 완전히
        // 없앴다 — 현재 차례는 이미 좌석 오버레이(_PlayerSeatPanel.isCurrentTurn)
        // 강조 표시로 알 수 있다. 그만큼 늘어난 세로 공간은 곧바로 아래
        // Expanded(_TableLayout)의 LayoutBuilder 제약으로 흘러들어가 게임보드
        // (boardWidth/boardHeight)가 더 커지고, 카드/토큰/귀족 크기도
        // board_component.dart의 비례 공식(cardW 기준)을 그대로 따라 함께 커진다.
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              _TableLayout(
                room: widget.room,
                gameState: widget.gameState,
                myUserId: widget.game.myUserId,
                board: ClipRect(child: GameWidget(game: widget.game)),
                onCardTap: (card, {required reserved, required actionable}) =>
                    _showCardDetail(card,
                        reserved: reserved, actionable: actionable),
              ),
              // 게임 중에도 메인 화면처럼 프로필/친구/설정을 열 수 있는 작은
              // 버튼들과, 상단 바에서 옮겨온 "나가기"·제한시간 타이머를 우하귀에
              // 한데 모았다(사용 중인 유일한 여유 모서리라 다른 위젯과 겹치지
              // 않음이 이미 확인된 자리).
              Positioned(
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TurnTimer(deadlineUtc: widget.gameState.turnDeadlineUtc),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _InGameMenuButton(
                          icon: Icons.exit_to_app,
                          tooltip: '나가기',
                          onTap: widget.onLeaveRoom,
                        ),
                        const SizedBox(width: 8),
                        const _InGameMenuButtons(),
                      ],
                    ),
                  ],
                ),
              ),
              // 시간초과로 턴이 강제 종료됐을 때만 뜨는 중앙 안내 — 다른
              // notice(입장/퇴장 등)처럼 SnackBar로 하단에 줄줄이 쌓이지 않고,
              // 게임 화면 중앙에서 살짝 위쪽에 반투명 창으로 3초간 떴다 사라진다.
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showTimeoutToast ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Align(
                    alignment: Alignment(0, -0.25),
                    child: _TurnTimeoutToast(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (mustDiscard)
          _DiscardBar(me: me, onDiscard: widget.onDiscardTokens)
        else
          ValueListenableBuilder<BoardSelection>(
            valueListenable: widget.game.selection,
            builder: (context, selection, _) => _ActionBar(
              selection: selection,
              tokenBank: widget.gameState.tokenBank,
              onConfirm: () => _confirmTokens(selection),
              onCancel: widget.game.clearSelection,
            ),
          ),
      ],
    );
  }
}

const Map<String, Color> _gemPanelColors = {
  'sapphire': AppColors.sapphire,
  'ruby': AppColors.ruby,
  'emerald': AppColors.emerald,
  'onyx': Color(0xFF4B4750),
  'diamond': Color(0xFFE7E1D2),
};

Color _gemPanelColor(String bonusWireValue) =>
    _gemPanelColors[bonusWireValue.toLowerCase()] ?? AppColors.textMuted;

/// 좌/우 좌석 패널을 [RotatedBox]로 눕히기 전, 눕히지 않은 상태에서 차지하는
/// "짧은 쪽" 치수. 좌/우에서는 이 값이 화면에 그려지는 폭이 되고, 상/하에서는
/// 그냥 패널의 자연스러운 높이 예산으로 쓰입니다. 구매/예약 카드 줄이 이제
/// 게임보드 오버레이(_GameBoardWithCardOverlays)로 옮겨갔으므로, _PlayerSeatPanel엔
/// 아바타/이름 줄 + 토큰 줄 + 보너스 줄만 남아 예전(180)보다 훨씬 작다.
const double _seatPanelCrossAxis = 100;

/// 구매/예약 카드 오버레이(_PlayerCardsRow)가 보드 가장자리 바로 바깥에서
/// 차지하는 통로 두께(보드 변에 수직인 방향) = _overlayThicknessPerBoardWidth ×
/// boardWidth + _overlayGap.
///
/// 카드 위젯 크기가 "게임보드 미구매 카드의 0.5배"로 고정됐으므로, 통로도 그
/// 카드가 최대로 쌓였을 때(_GemCardStack이 허용하는 maxColumnH) 높이를 정확히
/// 담도록 boardWidth에 비례해 확보한다 — 그래야 카드가 몇 장 쌓이든, 어떤 창
/// 크기에서도 카드가 통로를 넘어 게임보드를 침범하지 않는다(통로 두께와 카드
/// 크기 모두 boardWidth에 선형 비례하므로 이 비율은 창 크기와 무관하게 고정).
///
/// 상/하/좌/우 네 방향 모두 같은 두께다: 좌/우 오버레이는 90도 회전하지만 회전
/// 뒤 통로 두께 방향으로 차지하는 크기 역시 회전 전의 세로 높이(=maxColumnH)라
/// 상/하와 같기 때문이다. (아래 _overlayThicknessPerBoardWidth 유도는
/// _GemCardStack의 maxColumnH 계산과 board_component.dart의 카드 크기 공식을
/// 그대로 참조하므로, 그 상수들이 바뀌어도 자동으로 맞춰진다.)
final double _overlayThicknessPerBoardWidth = 0.5 *
    BoardComponent.cardSizeFor(1.0, 1.0 / BoardComponent.contentAspect).y *
    _GemCardStack._maxColumnHRatio;

/// 게임보드 변과 카드 오버레이 사이에 두는 최소 여백(px). 통로 두께에 더해
/// 보드와 카드가 살짝 떨어져 보이게 한다.
const double _overlayGap = 6;

/// playersInOrder에서 내 자리를 항상 "하단"에 고정하고, 턴 진행 순서를 시계
/// 방향(하단 → 우측 → 상단 → 좌측)으로 배정합니다. Splendor는 2~4인이라 남는
/// 좌석은 비워둡니다.
class _TableSeats {
  final GamePlayerState? bottom;
  final GamePlayerState? right;
  final GamePlayerState? top;
  final GamePlayerState? left;
  const _TableSeats({this.bottom, this.right, this.top, this.left});
}

_TableSeats _assignTableSeats(
  List<GamePlayerState> playersInOrder,
  int myUserId,
) {
  if (playersInOrder.isEmpty) return const _TableSeats();
  final myIndex = playersInOrder.indexWhere((p) => p.userId == myUserId);
  final start = myIndex == -1 ? 0 : myIndex;
  final rotated = [
    for (var i = 0; i < playersInOrder.length; i++)
      playersInOrder[(start + i) % playersInOrder.length],
  ];
  GamePlayerState? at(int index) =>
      index < rotated.length ? rotated[index] : null;

  // 인원수별로 상대 좌석 배치가 달라진다: 2인전은 정면(top)에서 마주보고,
  // 3인전은 좌/우에 나눠 앉아(정면은 비워 테이블을 넓게 쓰고), 4인전만
  // 위/좌/우를 모두 채운다. rotated는 항상 나(index 0) 기준 시계 방향
  // (다음 차례 -> 오른쪽) 순서이므로 인원수별로 슬롯 매핑만 바꾼다.
  switch (rotated.length) {
    case 1:
      return _TableSeats(bottom: at(0));
    case 2:
      return _TableSeats(bottom: at(0), top: at(1));
    case 3:
      return _TableSeats(bottom: at(0), right: at(1), left: at(2));
    default:
      return _TableSeats(
        bottom: at(0),
        right: at(1),
        top: at(2),
        left: at(3),
      );
  }
}

/// 카드 썸네일(구매/예약)을 탭했을 때 상세 팝업을 여는 콜백. [reserved]는 예약
/// 카드 여부, [actionable]은 지금 구매/예약 행동을 걸 수 있는 카드인지(=보드 위
/// 미구매 카드나 내 예약 카드)를 뜻한다.
typedef CardTapCallback = void Function(
  SplendorCard card, {
  required bool reserved,
  required bool actionable,
});

/// 직사각 테이블에 4명이 둘러앉은 형태의 보드 레이아웃. 중앙에는 게임보드
/// (_GameBoardWithCardOverlays, Flame 귀족/카드/토큰 + 각 플레이어의 구매/예약
/// 카드 오버레이)를 board_component.dart의 BoardComponent.contentAspect(가로로
/// 넓은 직사각형) 비율에 맞춰 배치하고, 상/하 좌석 패널(프로필/토큰/보너스)은
/// 그대로, 좌/우 좌석 패널은 [RotatedBox]로 90도 돌려 실제로 테이블에 둘러앉은
/// 것처럼 보여줍니다.
class _TableLayout extends StatelessWidget {
  final GameRoom room;
  final GameState gameState;
  final int myUserId;
  final Widget board;
  final CardTapCallback onCardTap;

  const _TableLayout({
    required this.room,
    required this.gameState,
    required this.myUserId,
    required this.board,
    required this.onCardTap,
  });

  String _nicknameFor(int userId) {
    for (final p in room.players) {
      if (p.id == userId) return p.nickname;
    }
    return 'User $userId';
  }

  String? _avatarFor(int userId) {
    for (final p in room.players) {
      if (p.id == userId) return p.avatarUrl;
    }
    return null;
  }

  Widget _seat(GamePlayerState? player) {
    if (player == null) return const SizedBox.shrink();
    return _PlayerSeatPanel(
      player: player,
      nickname: _nicknameFor(player.userId),
      avatarUrl: _avatarFor(player.userId),
      isCurrentTurn: player.userId == gameState.currentPlayerId,
    );
  }

  /// 좌/우 좌석을 회전시켜 배치합니다. 패널 내용이 [_seatPanelCrossAxis] 예산을
  /// 넘더라도(닉네임이 길거나 카드가 많이 쌓인 경우) [ClipRect]로 그 지점에서
  /// 잘라내, 넘친 부분이 옆의 보드 영역 위로 그려져 카드/토큰을 가리는 일이
  /// 없도록 합니다.
  Widget _sideSeat(GamePlayerState? player, int quarterTurns) {
    if (player == null) return const SizedBox.shrink();
    return ClipRect(
      child: SizedBox(
        width: _seatPanelCrossAxis,
        child: RotatedBox(quarterTurns: quarterTurns, child: _seat(player)),
      ),
    );
  }

  /// 상/하 좌석도 동일한 이유로 높이를 [_seatPanelCrossAxis]로 제한하고 잘라냅니다.
  /// 폭은 [width]로 제한해 중앙 보드 한 변의 길이보다 살짝 작게 맞춥니다 —
  /// 이전에는 폭 제한이 없어 프로그램 창 가장자리까지 늘어났습니다.
  Widget _centerSeat(GamePlayerState? player, double width) {
    if (player == null) return const SizedBox.shrink();
    return ClipRect(
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _seatPanelCrossAxis),
          child: _seat(player),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seats = _assignTableSeats(gameState.playersInOrder, myUserId);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 각 방향에서 좌석 패널(_seatPanelCrossAxis)과 카드 오버레이 통로를 뺀
        // 나머지가 게임보드가 차지할 박스다. 통로 두께는 boardWidth에 비례
        // (_overlayThicknessPerBoardWidth·boardWidth + _overlayGap)하고 boardWidth는
        // 다시 그 통로를 뺀 값이라 서로 얽혀 있으므로 대수적으로 푼다. 이렇게
        // 통로 두께를 카드 크기에 정확히 맞춰 확보해야, 카드가 통로를 넘어
        // 게임보드를 침범(overlap)하는 일이 구조적으로 생기지 않는다.
        //
        // 게임보드는 BoardComponent.contentAspect(가로로 넓은 직사각형) 비율로
        // 고정 — board_component.dart가 이 비율의 박스를 여백 없이 꽉 채운다.
        final hOverlayCount =
            (seats.left != null ? 1 : 0) + (seats.right != null ? 1 : 0);
        final vOverlayCount =
            (seats.top != null ? 1 : 0) + (seats.bottom != null ? 1 : 0);
        final hSeatBudget = (seats.left != null ? _seatPanelCrossAxis : 0.0) +
            (seats.right != null ? _seatPanelCrossAxis : 0.0);
        final vSeatBudget = (seats.top != null ? _seatPanelCrossAxis : 0.0) +
            (seats.bottom != null ? _seatPanelCrossAxis : 0.0);

        final k = _overlayThicknessPerBoardWidth;
        const aspect = BoardComponent.contentAspect;

        // 가로 제약: maxWidth = hSeatBudget + hOverlayCount·(k·bW + gap) + bW
        // 세로 제약: maxHeight = vSeatBudget + vOverlayCount·(k·bW + gap) + bW/aspect
        // 각각 bW에 대해 풀어 더 빡빡한(작은) 쪽을 택한다.
        final bwFromWidth =
            (constraints.maxWidth - hSeatBudget - hOverlayCount * _overlayGap) /
                (1 + hOverlayCount * k);
        final bwFromHeight =
            (constraints.maxHeight - vSeatBudget - vOverlayCount * _overlayGap) /
                (1 / aspect + vOverlayCount * k);
        final boardWidth = (bwFromWidth < bwFromHeight ? bwFromWidth : bwFromHeight)
            .clamp(0.0, double.infinity);
        final boardHeight = boardWidth / aspect;
        final overlayThickness = k * boardWidth + _overlayGap;

        final centerSeatWidth = boardWidth * 0.92;

        return Column(
          children: [
            _centerSeat(seats.top, centerSeatWidth),
            Expanded(
              child: Row(
                children: [
                  _sideSeat(seats.left, 1),
                  Expanded(
                    child: Center(
                      child: _GameBoardWithCardOverlays(
                        board: board,
                        boardWidth: boardWidth,
                        boardHeight: boardHeight,
                        overlayThickness: overlayThickness,
                        seats: seats,
                        myUserId: myUserId,
                        onCardTap: onCardTap,
                      ),
                    ),
                  ),
                  _sideSeat(seats.right, 3),
                ],
              ),
            ),
            _centerSeat(seats.bottom, centerSeatWidth),
          ],
        );
      },
    );
  }
}

/// 좌석 한 명 분: 아바타/이름/차례 표시 + 점수, 현재 보유 토큰(골드 포함) 줄,
/// 보너스(할인) 요약 칩 줄. 구매/예약 카드는 더 이상 이 패널의 자식이 아니라
/// 게임보드 오버레이(_GameBoardWithCardOverlays)의 자식이다 — 스플렌더는 공개
/// 정보 게임이라 상대의 보유 토큰도 항상 보여줍니다.
class _PlayerSeatPanel extends StatelessWidget {
  final GamePlayerState player;
  final String nickname;
  final String? avatarUrl;
  final bool isCurrentTurn;

  const _PlayerSeatPanel({
    required this.player,
    required this.nickname,
    required this.avatarUrl,
    required this.isCurrentTurn,
  });

  @override
  Widget build(BuildContext context) {
    // 백엔드 GemType은 PascalCase("Sapphire")로 직렬화되지만, 계약이 흔들릴 걸
    // 대비해 Gem.fromWireValue로 정규화한 뒤 보너스/토큰 모두 같은 키(wireValue)로
    // 묶는다 — 대소문자가 어긋나 숫자가 조용히 0으로 보이는 사고를 막기 위함이다.
    final bonusesByGem = <String, int>{
      for (final entry in player.bonuses.entries)
        Gem.fromWireValue(entry.key).wireValue: entry.value,
    };
    // 보너스(bonuses)와 달리 보유 토큰(tokens)에는 gold가 포함되므로 별도 줄로
    // 그린다 — StateSync가 올 때마다 이 위젯도 새로 build되므로 항상 최신 값.
    final tokensByGem = <String, int>{
      for (final entry in player.tokens.entries)
        Gem.fromWireValue(entry.key).wireValue: entry.value,
    };

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? AppColors.goldFaint.withValues(alpha: 0.12)
            : AppColors.panelAlt.withValues(alpha: 0.55),
        border: Border.all(
          color: isCurrentTurn
              ? AppColors.gold.withValues(alpha: 0.6)
              : AppColors.goldHairline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: avatarToneFor(nickname),
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        nickname.characters.first,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textHeading,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeading,
                      ),
                    ),
                    Text(
                      isCurrentTurn ? '현재 차례' : '대기',
                      style: kickerStyle(size: 8, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text('${player.points}', style: headingStyle(size: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final gem in Gem.values)
                _TokenChip(
                  gem: gem,
                  count: tokensByGem[gem.wireValue] ?? 0,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final gem in gemDisplayOrder)
                _BonusChip(
                  color: _gemPanelColor(gem),
                  count: bonusesByGem[gem] ?? 0,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 한 플레이어의 구매 카드(보석 색상별로 겹쳐 쌓음) + 예약 카드 줄. 더 이상
/// _PlayerSeatPanel의 자식이 아니라, 게임보드 오버레이
/// (_GameBoardWithCardOverlays)의 자식으로 그 플레이어와 가장 가까운 보드
/// 가장자리 바로 바깥에 붙는다. 카드를 탭하면 상세 팝업이 뜬다(구매 카드는
/// 정보만, 내 예약 카드는 구매까지 가능 — [isMe]로 판단).
class _PlayerCardsRow extends StatelessWidget {
  final GamePlayerState player;
  final bool isMe;
  final CardTapCallback onCardTap;

  /// 구매/예약 카드 위젯 한 장의 크기 — 게임보드 안 미구매 카드 크기의 0.5배로
  /// _GameBoardWithCardOverlays가 고정해서 넘긴다(구매 카드 스택과 예약 카드
  /// 썸네일이 서로 다른 크기로 보이지 않도록 둘 다 이 값을 그대로 쓴다).
  final double cardWidth;
  final double cardHeight;

  const _PlayerCardsRow({
    required this.player,
    required this.isMe,
    required this.onCardTap,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    // 백엔드 GemType은 PascalCase("Sapphire")로 직렬화되지만, 계약이 흔들릴 걸
    // 대비해 Gem.fromWireValue로 정규화한다 — 카드 더미가 조용히 0으로 보이는
    // 사고를 막기 위함이다.
    final cardsByGem = <String, List<SplendorCard>>{};
    for (final card in player.purchasedCards) {
      final key = Gem.fromWireValue(card.bonus).wireValue;
      cardsByGem.putIfAbsent(key, () => []).add(card);
    }

    // 원래 카드 폭(26) 기준으로 튜닝된 여백/구분선 두께를 실제 cardWidth에
    // 비례해서 맞춘다.
    final gapFactor = cardWidth / 26.0;

    // mainAxisSize.min으로 내용 폭에 맞게 스스로 크기를 정해야, 이 위젯을 감싸는
    // Center(_GameBoardWithCardOverlays)가 보드 가장자리 중점을 지나는 선 위에
    // 정확히 중앙 정렬할 수 있다(Row가 부모 폭을 그대로 채워버리면 Center가
    // 아무 효과도 없다).
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final gem in gemDisplayOrder)
          Padding(
            padding: EdgeInsets.only(right: 3 * gapFactor),
            child: _GemCardStack(
              color: _gemPanelColor(gem),
              cards: cardsByGem[gem] ?? const [],
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              onCardTap: (card) =>
                  onCardTap(card, reserved: false, actionable: false),
            ),
          ),
        // 예약 카드는 서버가 모든 참가자에게 실제 카드 정보를 그대로 보내므로
        // (참고 클라이언트도 reservedCardIds를 전원에게 보여준다) 각 플레이어의
        // 구매 카드 오른쪽에 함께 그린다. 구매 카드와 크기가 같아 보이도록
        // 예약 카드 썸네일도 같은 cardWidth/cardHeight를 쓴다.
        if (player.reservedCards.isNotEmpty) ...[
          Container(
            width: 1,
            height: 40 * gapFactor,
            margin: EdgeInsets.symmetric(horizontal: 4 * gapFactor),
            color: AppColors.goldHairline,
          ),
          for (final card in player.reservedCards)
            Padding(
              padding: EdgeInsets.only(right: 3 * gapFactor),
              child: _ReservedCardThumb(
                card: card,
                width: cardWidth,
                height: cardHeight,
                onTap: () => onCardTap(card, reserved: true, actionable: isMe),
              ),
            ),
        ],
      ],
    );
  }
}

/// 게임보드 위젯 — Flame 보드(귀족/미구매 카드/토큰 뱅크)를 직사각형(boardWidth x
/// boardHeight) 한가운데 두고, 자리가 찬 각 방향(top/bottom/left/right)마다 그
/// 플레이어의 구매/예약 카드 오버레이(_PlayerCardsRow)를 보드와 가장 가까운 변
/// 바로 바깥에 띄운다.
///
/// 네 방향 카드 오버레이 통로 두께는 [overlayThickness] 하나로 통일한다 —
/// _TableLayout이 "게임보드 미구매 카드의 0.5배" 크기 카드가 최대로 쌓였을 때
/// 높이(maxColumnH)를 정확히 담도록 boardWidth에 비례해 계산해 넘기므로, 카드가
/// 이 통로를 넘어 게임보드를 침범(overlap)하는 일이 없다. 카드 위젯 자체 크기도
/// 같은 0.5배 규칙(BoardComponent.cardSizeFor(boardWidth, boardHeight)/2)이라
/// 네 플레이어 모두 같은 크기로 보인다(회전 각도만 다르다).
///
/// 각 오버레이는 그 변과 길이가 같은 통로 사각형 안에서 [Center]로 배치되므로,
/// 오버레이의 중심은 항상 "그 변의 중점을 지나는 수직선" 위에 오게 된다 —
/// 좌/우는 좌석 패널과 같은 방향으로 [RotatedBox] 처리해 눕히고, 상단(반대편
/// 플레이어)은 180도 돌려 그 플레이어 시점으로 바로 보이게 한다. 이 위젯 자체가
/// 카드 오버레이의 부모이며(더 이상 _PlayerSeatPanel의 자식이 아니다), 보드
/// 사각형과 카드 오버레이 통로는 서로 겹치지 않는 별개의 [Positioned] 영역을
/// 차지한다.
class _GameBoardWithCardOverlays extends StatelessWidget {
  final Widget board;
  final double boardWidth;
  final double boardHeight;
  final double overlayThickness;
  final _TableSeats seats;
  final int myUserId;
  final CardTapCallback onCardTap;

  const _GameBoardWithCardOverlays({
    required this.board,
    required this.boardWidth,
    required this.boardHeight,
    required this.overlayThickness,
    required this.seats,
    required this.myUserId,
    required this.onCardTap,
  });

  /// 통로 "길이" 방향(변을 따라가는 방향)으로 카드 줄이 넘칠 수 있는 극단적인
  /// 경우(예약 카드까지 많이 쌓인 경우 등)에 대비해 ClipRect로 감싼다 — 통로
  /// "두께" 방향은 _TableLayout이 카드 크기에 맞춰 확보하므로 넘치지 않는다.
  Widget _cardsOverlay(GamePlayerState? player, Vector2 cardSize) {
    if (player == null) return const SizedBox.shrink();
    return ClipRect(
      child: _PlayerCardsRow(
        player: player,
        isMe: player.userId == myUserId,
        onCardTap: onCardTap,
        cardWidth: cardSize.x,
        cardHeight: cardSize.y,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftExtent = seats.left != null ? overlayThickness : 0.0;
    final rightExtent = seats.right != null ? overlayThickness : 0.0;
    final topExtent = seats.top != null ? overlayThickness : 0.0;
    final bottomExtent = seats.bottom != null ? overlayThickness : 0.0;
    // 게임보드 안 미구매 카드 크기의 0.5배로 고정(_TableLayout의 통로 두께
    // 계산과 같은 규칙). 이 크기의 카드가 최대로 쌓여도 overlayThickness 안에
    // 들어오도록 통로가 확보돼 있어 게임보드와 겹치지 않는다.
    final boardCardSize = BoardComponent.cardSizeFor(boardWidth, boardHeight);
    final cardSize = boardCardSize / 2;

    return SizedBox(
      width: leftExtent + boardWidth + rightExtent,
      height: topExtent + boardHeight + bottomExtent,
      child: Stack(
        children: [
          Positioned(
            left: leftExtent,
            top: topExtent,
            width: boardWidth,
            height: boardHeight,
            child: board,
          ),
          if (seats.top != null)
            Positioned(
              left: leftExtent,
              top: 0,
              width: boardWidth,
              height: topExtent,
              // 반대편(내 정면) 플레이어의 카드 위젯은 그 플레이어 시점으로
              // 바로 보이도록 180도 뒤집는다.
              child: Center(
                child: RotatedBox(
                  quarterTurns: 2,
                  child: _cardsOverlay(seats.top, cardSize),
                ),
              ),
            ),
          if (seats.bottom != null)
            Positioned(
              left: leftExtent,
              top: topExtent + boardHeight,
              width: boardWidth,
              height: bottomExtent,
              child: Center(child: _cardsOverlay(seats.bottom, cardSize)),
            ),
          if (seats.left != null)
            Positioned(
              left: 0,
              top: topExtent,
              width: leftExtent,
              height: boardHeight,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: _cardsOverlay(seats.left, cardSize),
                ),
              ),
            ),
          if (seats.right != null)
            Positioned(
              left: leftExtent + boardWidth,
              top: topExtent,
              width: rightExtent,
              height: boardHeight,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: _cardsOverlay(seats.right, cardSize),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BonusChip extends StatelessWidget {
  final Color color;
  final int count;
  const _BonusChip({required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 현재 보유한 토큰 1색 분(개수 포함). 골드는 다른 5색과 색이 겹치지 않고
/// 와일드카드라는 게 눈에 띄도록 칩을 한 단계 크게 그리고 테두리를 강조합니다.
/// gemPipColor/gemPipTextColor(game/gem_colors.dart)는 카드/귀족 가격 오버레이와
/// 같은 팔레트라 보드 쪽 표기와 색이 어긋나지 않습니다.
class _TokenChip extends StatelessWidget {
  final Gem gem;
  final int count;
  const _TokenChip({required this.gem, required this.count});

  @override
  Widget build(BuildContext context) {
    final isGold = gem == Gem.gold;
    final size = isGold ? 26.0 : 22.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gemPipColor(gem.wireValue),
        shape: BoxShape.circle,
        border: Border.all(
          color: isGold ? Colors.white70 : Colors.white24,
          width: isGold ? 1.5 : 0.8,
        ),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: isGold ? 13.5 : 12.5,
          fontWeight: FontWeight.w800,
          color: gemPipTextColor(gem.wireValue),
        ),
      ),
    );
  }
}

/// 다른 플레이어의 예약 카드를 실제 얼굴로 작게 보여줍니다(백엔드가
/// reservedCards를 전원에게 실제 카드 정보로 보내므로 감출 이유가 없습니다).
class _ReservedCardThumb extends StatelessWidget {
  final SplendorCard card;
  final VoidCallback? onTap;
  // 구매 카드(_GemCardStack)와 같은 크기로 보이도록, 호출부가 게임보드 미구매
  // 카드 크기의 0.5배를 그대로 넘긴다.
  final double width;
  final double height;
  const _ReservedCardThumb({
    required this.card,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = GameAssets.cardFace(card.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: AppColors.panelAlt,
          border: Border.all(color: AppColors.goldHairline, width: 1),
          image: imagePath != null
              ? DecorationImage(
                  image: AssetImage('assets/image/$imagePath'),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
    );
  }
}

/// 한 보석 색상으로 구매한 카드들을 세로로 겹쳐서(overlap) 보여줍니다. 카드가
/// 없으면 빈 칸 테두리를, 여러 장이면 많이 모을수록 더 촘촘히 겹쳐 정해진
/// 세로 폭(maxColumnH) 안에 들어오게 합니다 — 실물 카드를 쌓아두는 느낌.
class _GemCardStack extends StatelessWidget {
  final Color color;
  final List<SplendorCard> cards;
  final void Function(SplendorCard card)? onCardTap;
  // 카드 한 장의 크기 — _ReservedCardThumb와 같은 값을 받아 구매/예약 카드가
  // 항상 같은 크기로 보이게 한다(게임보드 미구매 카드 크기의 0.5배).
  final double cardWidth;
  final double cardHeight;

  /// 여러 장 겹쳤을 때 스택이 넘지 않을 최대 세로 폭. 원래 카드 크기(36) 대비
  /// 56의 비율을 그대로 유지해, 카드가 커지거나 작아져도 겹침 정도가 똑같아
  /// 보이게 한다.
  static const _maxColumnHRatio = 56.0 / 36.0;

  const _GemCardStack({
    required this.color,
    required this.cards,
    required this.cardWidth,
    required this.cardHeight,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardW = cardWidth;
    final cardH = cardHeight;
    final maxColumnH = cardHeight * _maxColumnHRatio;

    if (cards.isEmpty) {
      return Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.goldHairline, width: 1),
        ),
      );
    }

    // 하한을 4.0으로 두면 카드가 7장 이상 쌓였을 때 겹침 간격이 그 아래로
    // 내려가야 총 높이가 maxColumnH 안에 들어오는데도 강제로 4.0을 유지해서
    // 실제 높이가 maxColumnH를 넘어버렸다(좌석 패널 Column이 bottom overflow).
    // 하한을 0.0으로 낮춰 카드 수와 무관하게 항상 maxColumnH 이하로 맞춘다.
    final overlap = cards.length == 1
        ? 0.0
        : ((maxColumnH - cardH) / (cards.length - 1))
            .clamp(0.0, 14.0 * cardHeight / 36.0);
    final height = cardH + overlap * (cards.length - 1);

    return SizedBox(
      width: cardW,
      height: height,
      child: Stack(
        children: [
          for (var i = 0; i < cards.length; i++)
            Positioned(
              top: overlap * i,
              child: GestureDetector(
                onTap: onCardTap == null ? null : () => onCardTap!(cards[i]),
                child: _CardThumb(
                  card: cards[i],
                  color: color,
                  width: cardW,
                  height: cardH,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardThumb extends StatelessWidget {
  final SplendorCard card;
  final Color color;
  final double width;
  final double height;
  const _CardThumb({
    required this.card,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = GameAssets.cardFace(card.id);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color.withValues(alpha: 0.85),
        image: imagePath != null
            ? DecorationImage(
                image: AssetImage('assets/image/$imagePath'),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

/// 시간초과로 턴이 강제 종료됐을 때 게임 화면 중앙에서 살짝 위쪽에 3초간 떴다
/// 사라지는 반투명 안내 창(_GameBoardState._flashTimeoutToast가 표시/애니메이션을
/// 담당하고, 이 위젯은 순수하게 모양만 그린다).
class _TurnTimeoutToast extends StatelessWidget {
  const _TurnTimeoutToast();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldHairline),
      ),
      child: const Text(
        '시간 초과로 턴이 넘어갔습니다.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textHeading,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// gameState.turnDeadlineUtc(피셔 룰 턴 마감 시각)를 기준으로 매초 남은 시간을
/// 세는 위젯. 실제 만료 판정/턴 넘김은 서버(TurnTimeoutWorker)가 하므로 여기서는
/// 표시만 하고 별도 클라이언트 동작은 하지 않는다. 5초 이하로 남으면 경고 표시.
class _TurnTimer extends StatefulWidget {
  final DateTime? deadlineUtc;
  const _TurnTimer({required this.deadlineUtc});

  @override
  State<_TurnTimer> createState() => _TurnTimerState();
}

class _TurnTimerState extends State<_TurnTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadline = widget.deadlineUtc;
    if (deadline == null) return const SizedBox.shrink();

    final remaining =
        deadline.difference(DateTime.now().toUtc()).inSeconds.clamp(0, 99);
    final isWarning = remaining <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.withValues(alpha: 0.15)
            : AppColors.goldFaint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isWarning ? Colors.redAccent : AppColors.goldHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: isWarning ? Colors.redAccent : AppColors.gold,
          ),
          const SizedBox(width: 4),
          Text(
            '${remaining}s',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isWarning ? Colors.redAccent : AppColors.textHeading,
            ),
          ),
        ],
      ),
    );
  }
}

/// 토큰 획득 전용 하단 액션 바. 카드 구매/예약은 카드 상세 팝업(_CardDetailDialog)
/// 으로 옮겨졌으므로, 이 바는 이제 보드에서 고른 토큰을 확정/취소하는 일만 한다.
class _ActionBar extends StatelessWidget {
  final BoardSelection selection;
  final Map<String, int> tokenBank;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ActionBar({
    required this.selection,
    required this.tokenBank,
    required this.onConfirm,
    required this.onCancel,
  });

  // 안내 문구(토큰 미선택)와 확정/취소 버튼 줄(토큰 선택 중)은 세로 크기가 서로
  // 다르다(버튼은 ElevatedButtonTheme의 vertical:16 패딩 때문에 텍스트 한 줄보다
  // 훨씬 높다). 이 바가 Column 안에서 남은 세로 공간을 Expanded(_TableLayout)와
  // 나눠 쓰는 구조라, 두 상태의 높이가 다르면 토큰을 탭해 버튼이 나타나는 순간
  // 이 바의 높이가 바뀌어 위쪽 게임보드 전체가 미세하게 리사이즈된다(카드/토큰/
  // 귀족/좌석 오버레이가 순간 작아지거나 밀리는 것처럼 보임). 두 상태 모두 같은
  // 고정 높이 안에서 가운데 정렬해 이 흔들림을 없앤다.
  static const double _height = 64;

  @override
  Widget build(BuildContext context) {
    if (selection.gems.isEmpty) {
      return const SizedBox(
        height: _height,
        child: Center(
          child: Text(
            '토큰을 탭해서 가져오거나, 카드를 탭해서 구매/예약하세요.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      );
    }

    final canConfirm = isValidTokenSelection(selection.gemsAsList, tokenBank);
    final selectedTokenCount =
        selection.gems.values.fold<int>(0, (sum, v) => sum + v);

    return SizedBox(
      height: _height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: canConfirm ? onConfirm : null,
                child: Text('토큰 획득 ($selectedTokenCount/3)'),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onCancel, child: const Text('취소')),
          ],
        ),
      ),
    );
  }
}

/// 게임 화면 우하귀의 프로필/친구/설정 버튼 묶음. 메인 화면 하단 우측과 같은
/// 구성으로, 각 화면을 게임 위에 라우트로 띄운다(게임은 그대로 아래 유지).
class _InGameMenuButtons extends StatelessWidget {
  const _InGameMenuButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _InGameMenuButton(
          icon: Icons.person_outline,
          tooltip: '프로필',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        const SizedBox(width: 8),
        _InGameMenuButton(
          icon: Icons.group_outlined,
          tooltip: '친구',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FriendsScreen()),
          ),
        ),
        const SizedBox(width: 8),
        _InGameMenuButton(
          icon: Icons.settings_outlined,
          tooltip: '설정',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}

class _InGameMenuButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _InGameMenuButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.panel.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 18, color: AppColors.gold),
          ),
        ),
      ),
    );
  }
}

/// 카드를 탭했을 때 뜨는 상세 팝업. 카드 이미지와 "할인 적용 전" 인쇄 가격
/// (card.cost 원본)을 보여주고, 지금 실제로 할 수 있는 행동만 버튼으로 노출한다
/// (구매/예약은 호출부에서 내 턴·보유 자원·예약 칸을 따져 canBuy/canReserve로
/// 넘겨준다). 상대 카드나 내 턴이 아닐 때는 정보만 보여준다.
class _CardDetailDialog extends StatelessWidget {
  final SplendorCard card;
  final bool reserved;
  final bool canBuy;
  final bool canReserve;
  final VoidCallback onBuy;
  final VoidCallback onReserve;

  const _CardDetailDialog({
    required this.card,
    required this.reserved,
    required this.canBuy,
    required this.canReserve,
    required this.onBuy,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = GameAssets.cardFace(card.id);
    return AlertDialog(
      backgroundColor: AppColors.panel,
      title: Row(
        children: [
          Text('Tier ${card.tier}', style: headingStyle(size: 15)),
          const Spacer(),
          if (card.points > 0)
            Text('${card.points}점', style: headingStyle(size: 15)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 150,
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _gemPanelColor(card.bonus).withValues(alpha: 0.85),
                image: imagePath != null
                    ? DecorationImage(
                        image: AssetImage('assets/image/$imagePath'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BonusChip(color: _gemPanelColor(card.bonus), count: 1),
              const SizedBox(width: 8),
              const Text('구매 시 이 색 할인 +1',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('할인 적용 전 가격',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            children: [
              // 이 카드가 애초에 요구하지 않는 색(card.cost에 키 자체가 없는 색)은
              // 표기하지 않는다 — 0을 보여줄 대상은 "요구하지만 다 냈거나 할인으로
              // 상쇄된" 경우뿐이라 여기(할인 적용 전 원가)에서는 해당되지 않는다.
              for (final gem in gemDisplayOrder)
                if (card.cost.containsKey(gem))
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _gemPanelColor(gem),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white24, width: 0.5),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${card.cost[gem] ?? 0}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ),
      actions: [
        if (canReserve)
          OutlinedButton(onPressed: onReserve, child: const Text('예약')),
        if (canBuy)
          ElevatedButton(
            onPressed: onBuy,
            child: Text(reserved ? '예약 카드 구매' : '구매'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

/// 내 턴에 토큰을 가져와 총 보유량이 10개를 넘겼을 때, 정확히 10개가 되도록
/// 일부를 골라 반납하는 UI. 서버(GameEngine.DiscardTokens)가 "정확히 10개"만
/// 받아주므로 목표 개수를 다 고르기 전에는 반납 버튼을 막아둔다.
class _DiscardBar extends StatefulWidget {
  final GamePlayerState me;
  final Future<void> Function(List<String> gems) onDiscard;
  const _DiscardBar({required this.me, required this.onDiscard});

  @override
  State<_DiscardBar> createState() => _DiscardBarState();
}

class _DiscardBarState extends State<_DiscardBar> {
  final Map<String, int> _picked = {};

  int get _need => widget.me.totalTokens - 10;
  int get _pickedCount => _picked.values.fold(0, (sum, v) => sum + v);

  void _inc(String gem) {
    final have = widget.me.tokens[gem] ?? 0;
    final current = _picked[gem] ?? 0;
    if (current >= have || _pickedCount >= _need) return;
    setState(() => _picked[gem] = current + 1);
  }

  void _dec(String gem) {
    final current = _picked[gem] ?? 0;
    if (current <= 0) return;
    setState(() {
      if (current == 1) {
        _picked.remove(gem);
      } else {
        _picked[gem] = current - 1;
      }
    });
  }

  Future<void> _confirm() async {
    final gems = [
      for (final entry in _picked.entries)
        for (var i = 0; i < entry.value; i++) entry.key,
    ];
    await widget.onDiscard(gems);
    if (mounted) setState(_picked.clear);
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _pickedCount == _need;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.goldFaint.withValues(alpha: 0.14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '토큰이 10개를 초과했습니다. $_need개를 반납하세요 ($_pickedCount/$_need)',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textHeading,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final gem in Gem.values)
                if ((widget.me.tokens[gem.wireValue] ?? 0) > 0)
                  _DiscardStepper(
                    gem: gem,
                    have: widget.me.tokens[gem.wireValue] ?? 0,
                    picked: _picked[gem.wireValue] ?? 0,
                    onInc: () => _inc(gem.wireValue),
                    onDec: () => _dec(gem.wireValue),
                  ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canConfirm ? _confirm : null,
              child: const Text('반납'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscardStepper extends StatelessWidget {
  final Gem gem;
  final int have;
  final int picked;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _DiscardStepper({
    required this.gem,
    required this.have,
    required this.picked,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: gemPipColor(gem.wireValue),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
          ),
          Text('$picked/$have',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 16),
                onPressed: picked > 0 ? onDec : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 16),
                onPressed: picked < have ? onInc : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
