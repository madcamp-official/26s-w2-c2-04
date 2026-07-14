import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/assets.dart';
import '../game/board_selection.dart';
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
  final _chatController = TextEditingController();
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
    return ref.read(gameControllerProvider.notifier).reserveCard(cardId: card.id);
  }

  Future<void> _discardTokens(List<String> gems) {
    return ref.read(gameControllerProvider.notifier).discardTokens(gems);
  }

  Future<void> _sendChat() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    await ref.read(gameControllerProvider.notifier).sendChatMessage(text);
    _chatController.clear();
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
    _chatController.dispose();
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
      if (next is GameConnected && next.notice != null && next.notice != prevNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.notice!), duration: const Duration(seconds: 3)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.localLabel ?? '방 ${widget.room.roomId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: '나가기',
            onPressed: () async {
              // REST 퇴장/Hub LeaveRoom 중 하나가 네트워크 문제로 실패하더라도
              // (예: 배지로 최소화했다가 복귀한 직후처럼 연결이 막 재수립된
              // 상황), 배지 해제와 화면 나가기는 항상 이뤄져야 한다 — 그렇지
              // 않으면 버튼이 아무 반응도 없는 것처럼 보이고 좌하단 배지도
              // 계속 남아 다른 참가자에게 실제 퇴장이 전달됐는지 알 수 없게 된다.
              try {
                if (gameState is GameConnected) {
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('나가기 처리 중 문제: $e')));
                }
              } finally {
                ref.read(activeRoomProvider.notifier).state = null;
                if (context.mounted) Navigator.of(context).pop();
              }
            },
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
        GameConnected(:final gameState, :final pendingNobleChoice, :final players) =>
          _GameBoard(
            room: widget.room.copyWith(players: players),
            gameState: gameState,
            pendingNobleChoice: pendingNobleChoice,
            game: _splendorGame,
            onPurchase: _purchase,
            onReserve: _reserve,
            onTakeTokens: _takeTokens,
            onDiscardTokens: _discardTokens,
            chatController: _chatController,
            onSendChat: _sendChat,
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
            child: OrnateTitle(kicker: 'Private table', title: '방 ${room.roomId}'),
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
                          ? () => onToggleReady(!readyPlayerIds.contains(myUserId))
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
                      ? (_allOthersReady ? '게임 시작' : '모든 참가자가 준비할 때까지 기다리는 중...')
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
          color: empty ? AppColors.goldHairline : AppColors.gold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          if (empty)
            const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.people_outline, color: AppColors.textMuted, size: 18),
            )
          else
            CircleAvatar(
              backgroundColor: avatarToneFor(name),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      name.characters.first,
                      style: const TextStyle(color: AppColors.textHeading, fontSize: 13),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: isReady ? AppColors.gold : AppColors.goldHairline),
              ),
              child: Text(
                isReady ? '준비 완료' : '준비하기',
                style: TextStyle(fontSize: 11, color: isReady ? AppColors.gold : AppColors.textMuted),
              ),
            )
          else if (!empty)
            Text(
              isReady ? 'READY' : 'WAITING',
              style: kickerStyle(size: 10, color: isReady ? AppColors.gold : AppColors.textMuted),
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
  final SplendorGame game;
  final Future<void> Function(SplendorCard card, {required bool reserved}) onPurchase;
  final Future<void> Function(SplendorCard card) onReserve;
  final Future<void> Function(List<String> gems) onTakeTokens;
  final Future<void> Function(List<String> gems) onDiscardTokens;
  final TextEditingController chatController;
  final VoidCallback onSendChat;

  const _GameBoard({
    required this.room,
    required this.gameState,
    required this.pendingNobleChoice,
    required this.game,
    required this.onPurchase,
    required this.onReserve,
    required this.onTakeTokens,
    required this.onDiscardTokens,
    required this.chatController,
    required this.onSendChat,
  });

  @override
  State<_GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<_GameBoard> {
  @override
  void initState() {
    super.initState();
    _pushStateToGame();
  }

  @override
  void didUpdateWidget(covariant _GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState.sequence != widget.gameState.sequence ||
        oldWidget.pendingNobleChoice != widget.pendingNobleChoice) {
      _pushStateToGame();
    }
  }

  void _pushStateToGame() {
    widget.game.updateGameState(
      widget.gameState,
      nobleChoiceIds: widget.pendingNobleChoice ?? const [],
    );
  }

  /// 백엔드 GameState.PlayerState에는 닉네임이 없어서 방 참가자 목록에서 조회합니다.
  String _nicknameFor(int userId) {
    for (final p in widget.room.players) {
      if (p.id == userId) return p.nickname;
    }
    return 'User $userId';
  }

  Future<void> _confirm(BoardSelection selection) async {
    if (selection.card != null) {
      await widget.onPurchase(selection.card!, reserved: selection.cardIsReserved);
    } else if (selection.gems.isNotEmpty) {
      await widget.onTakeTokens(selection.gemsAsList);
    } else {
      return;
    }
    widget.game.clearSelection();
  }

  Future<void> _reserveSelected(BoardSelection selection) async {
    if (selection.card == null) return;
    await widget.onReserve(selection.card!);
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
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '턴 ${widget.gameState.turnNumber} · 현재 차례: '
                  '${widget.gameState.currentPlayerId != null ? _nicknameFor(widget.gameState.currentPlayerId!) : '-'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _TurnTimer(deadlineUtc: widget.gameState.turnDeadlineUtc),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: _SquareTable(
            room: widget.room,
            gameState: widget.gameState,
            myUserId: widget.game.myUserId,
            board: ClipRect(child: GameWidget(game: widget.game)),
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
              me: me,
              onConfirm: () => _confirm(selection),
              onReserve: () => _reserveSelected(selection),
              onCancel: widget.game.clearSelection,
            ),
          ),
        _ChatBar(controller: widget.chatController, onSend: widget.onSendChat),
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
/// 그냥 패널의 자연스러운 높이 예산으로 쓰입니다. _PlayerSeatPanel의 내용
/// (아바타/이름 줄 + 토큰/보너스 줄 + 카드 줄 + 예약 카드 줄 + 패딩)이 이 안에
/// 들어오도록 _GemCardStack의 치수와 함께 맞춰뒀습니다.
const double _seatPanelCrossAxis = 180;

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

/// 정사각 테이블에 4명이 둘러앉은 형태의 보드 레이아웃. 중앙에 Flame 보드(귀족/
/// 카드/토큰)를 정사각형으로 배치하고, 상/하 플레이어는 그대로, 좌/우 플레이어는
/// [RotatedBox]로 90도 돌려 실제로 테이블에 둘러앉은 것처럼 보여줍니다.
class _SquareTable extends StatelessWidget {
  final GameRoom room;
  final GameState gameState;
  final int myUserId;
  final Widget board;

  const _SquareTable({
    required this.room,
    required this.gameState,
    required this.myUserId,
    required this.board,
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
        // 좌/우가 차지하는 폭(_seatPanelCrossAxis, 있을 때만)을 뺀 나머지와
        // 상/하가 차지하는 높이를 뺀 나머지 중 더 작은 쪽이 실제로 그려질
        // 중앙 보드 한 변의 길이(AspectRatio(1)이 최종적으로 계산할 값과 동일).
        final horizontalBudget =
            (seats.left != null ? _seatPanelCrossAxis : 0.0) +
                (seats.right != null ? _seatPanelCrossAxis : 0.0);
        final verticalBudget =
            (seats.top != null ? _seatPanelCrossAxis : 0.0) +
                (seats.bottom != null ? _seatPanelCrossAxis : 0.0);
        final boardEdge = math.min(
          constraints.maxWidth - horizontalBudget,
          constraints.maxHeight - verticalBudget,
        ).clamp(0.0, double.infinity);
        final centerSeatWidth = boardEdge * 0.92;

        return Column(
          children: [
            _centerSeat(seats.top, centerSeatWidth),
            Expanded(
              child: Row(
                children: [
                  _sideSeat(seats.left, 1),
                  Expanded(
                    child: Center(
                      child: AspectRatio(aspectRatio: 1, child: board),
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
/// 보너스(할인) 요약 칩 줄, 그리고 구매한 카드를 보석 색상별로 겹쳐서 정리한
/// 5개 열. 스플렌더는 공개 정보 게임이라 상대의 보유 토큰도 항상 보여줍니다.
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
    // 대비해 Gem.fromWireValue로 정규화한 뒤 카드/보너스 모두 같은 키(wireValue)로
    // 묶는다 — 대소문자가 어긋나 카드 더미나 보너스 숫자가 조용히 0으로 보이는
    // 사고를 막기 위함이다.
    final cardsByGem = <String, List<SplendorCard>>{};
    for (final card in player.purchasedCards) {
      final key = Gem.fromWireValue(card.bonus).wireValue;
      cardsByGem.putIfAbsent(key, () => []).add(card);
    }
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final gem in gemDisplayOrder)
                _GemCardStack(
                  color: _gemPanelColor(gem),
                  cards: cardsByGem[gem] ?? const [],
                ),
            ],
          ),
          // 예약 카드는 서버가 모든 참가자에게 실제 카드 정보를 그대로 보내므로
          // (backend/Backend/testFrontend의 참고 클라이언트도 reservedCardIds를
          // 전원에게 보여준다), 보드 위 "내 예약 카드 줄"과 별개로 다른 플레이어의
          // 예약 카드도 여기 좌석 패널에 작게 표시합니다 — 이전에는 예약 카드가
          // 이 화면 어디에도 그려지지 않아 다른 사람에게는 안 보이는 것처럼
          // 보였습니다.
          if (player.reservedCards.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final card in player.reservedCards)
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: _ReservedCardThumb(card: card),
                  ),
              ],
            ),
          ],
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
  const _ReservedCardThumb({required this.card});

  static const _w = 18.0;
  static const _h = 25.0;

  @override
  Widget build(BuildContext context) {
    final imagePath = GameAssets.cardFace(card.id);
    return Container(
      width: _w,
      height: _h,
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
    );
  }
}

/// 한 보석 색상으로 구매한 카드들을 세로로 겹쳐서(overlap) 보여줍니다. 카드가
/// 없으면 빈 칸 테두리를, 여러 장이면 많이 모을수록 더 촘촘히 겹쳐 정해진
/// 세로 폭([_maxColumnH]) 안에 들어오게 합니다 — 실물 카드를 쌓아두는 느낌.
class _GemCardStack extends StatelessWidget {
  final Color color;
  final List<SplendorCard> cards;

  static const _cardW = 26.0;
  static const _cardH = 36.0;
  static const _maxColumnH = 56.0;

  const _GemCardStack({required this.color, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Container(
        width: _cardW,
        height: _cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.goldHairline, width: 1),
        ),
      );
    }

    // 하한을 4.0으로 두면 카드가 7장 이상 쌓였을 때 겹침 간격이 그 아래로
    // 내려가야 총 높이가 _maxColumnH 안에 들어오는데도 강제로 4.0을 유지해서
    // 실제 높이가 _maxColumnH를 넘어버렸다(좌석 패널 Column이 bottom overflow).
    // 하한을 0.0으로 낮춰 카드 수와 무관하게 항상 _maxColumnH 이하로 맞춘다.
    final overlap = cards.length == 1
        ? 0.0
        : ((_maxColumnH - _cardH) / (cards.length - 1)).clamp(0.0, 14.0);
    final height = _cardH + overlap * (cards.length - 1);

    return SizedBox(
      width: _cardW,
      height: height,
      child: Stack(
        children: [
          for (var i = 0; i < cards.length; i++)
            Positioned(
              top: overlap * i,
              child: _CardThumb(card: cards[i], color: color),
            ),
        ],
      ),
    );
  }
}

class _CardThumb extends StatelessWidget {
  final SplendorCard card;
  final Color color;
  const _CardThumb({required this.card, required this.color});

  @override
  Widget build(BuildContext context) {
    final imagePath = GameAssets.cardFace(card.id);
    return Container(
      width: _GemCardStack._cardW,
      height: _GemCardStack._cardH,
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
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
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

    final remaining = deadline.difference(DateTime.now().toUtc()).inSeconds.clamp(0, 99);
    final isWarning = remaining <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.withValues(alpha: 0.15)
            : AppColors.goldFaint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isWarning ? Colors.redAccent : AppColors.goldHairline),
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

class _ActionBar extends StatelessWidget {
  final BoardSelection selection;
  final Map<String, int> tokenBank;
  final GamePlayerState? me;
  final VoidCallback onConfirm;
  final VoidCallback onReserve;
  final VoidCallback onCancel;

  const _ActionBar({
    required this.selection,
    required this.tokenBank,
    required this.me,
    required this.onConfirm,
    required this.onReserve,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (selection.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          '카드나 토큰을 탭해서 선택하세요.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    final isGemSelection = selection.card == null;
    final myPlayer = me;
    // me가 없으면(관전 등 "나"를 특정할 수 없는 경우) 판단 근거가 없으니
    // 서버 판정에 맡기고 버튼을 막지 않는다.
    final canConfirm = isGemSelection
        ? isValidTokenSelection(selection.gemsAsList, tokenBank)
        : (myPlayer == null || canAffordCard(selection.card!, myPlayer));
    final showReserve = selection.card != null && !selection.cardIsReserved;
    final canReserve =
        showReserve && (myPlayer == null || canReserveMore(myPlayer));
    final selectedTokenCount =
        selection.gems.values.fold<int>(0, (sum, v) => sum + v);
    final confirmLabel = selection.card != null
        ? (selection.cardIsReserved ? '예약 카드 구매' : '구매')
        : '토큰 획득 ($selectedTokenCount/3)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canConfirm ? onConfirm : null,
              child: Text(confirmLabel),
            ),
          ),
          if (showReserve) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: canReserve ? onReserve : null,
              child: const Text('예약'),
            ),
          ],
          const SizedBox(width: 8),
          TextButton(onPressed: onCancel, child: const Text('취소')),
        ],
      ),
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
          Text('$picked/$have', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
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

class _ChatBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: '채팅 (친구에게만 전달됩니다)'),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: onSend),
        ],
      ),
    );
  }
}
