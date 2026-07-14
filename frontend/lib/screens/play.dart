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

class _PlayScreenState extends ConsumerState<PlayScreen> {
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
    Future.microtask(
      () => ref.read(activeRoomProvider.notifier).state = widget.room,
    );

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

  Future<void> _sendChat() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    await ref.read(gameControllerProvider.notifier).sendChatMessage(text);
    _chatController.clear();
  }

  @override
  void dispose() {
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
            chatController: _chatController,
            onSendChat: _sendChat,
          ),
        GameWaitingRoom(:final players) => _WaitingRoom(
            room: widget.room.copyWith(players: players),
            isHost: _isHost,
            onStart: _startGame,
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
  final VoidCallback onStart;
  const _WaitingRoom({
    required this.room,
    required this.isHost,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
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
                onPressed: isHost ? onStart : null,
                child: Text(isHost ? '게임 시작' : '방장이 시작하기를 기다리는 중...'),
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
  const _PlayerSlot({
    required this.name,
    required this.avatarUrl,
    required this.isHost,
    this.empty = false,
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
            Text('HOST', style: kickerStyle(size: 10, color: AppColors.gold)),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '턴 ${widget.gameState.turnNumber} · 현재 차례: '
            '${widget.gameState.currentPlayerId != null ? _nicknameFor(widget.gameState.currentPlayerId!) : '-'}',
            style: Theme.of(context).textTheme.titleMedium,
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
        ValueListenableBuilder<BoardSelection>(
          valueListenable: widget.game.selection,
          builder: (context, selection, _) => _ActionBar(
            selection: selection,
            tokenBank: widget.gameState.tokenBank,
            onConfirm: () => _confirm(selection),
            onReserve:
                selection.card == null || selection.cardIsReserved
                    ? null
                    : () => _reserveSelected(selection),
            onCancel: widget.game.clearSelection,
          ),
        ),
        _ChatBar(controller: widget.chatController, onSend: widget.onSendChat),
      ],
    );
  }
}

/// 카드 색상별 겹침 배치에서 항상 이 순서로 5개 열을 그립니다(보너스 칩 줄과도
/// 동일한 순서). gold는 카드 보너스로 나오지 않으므로 제외합니다.
const List<String> _cardBonusGemOrder = [
  'Sapphire',
  'Ruby',
  'Emerald',
  'Onyx',
  'Diamond',
];

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
/// (아바타/이름 줄 + 보너스 줄 + 카드 줄 + 패딩)이 이 안에 들어오도록
/// _GemCardStack의 치수와 함께 맞춰뒀습니다.
const double _seatPanelCrossAxis = 128;

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
  Widget _centerSeat(GamePlayerState? player) {
    if (player == null) return const SizedBox.shrink();
    return ClipRect(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _seatPanelCrossAxis),
        child: _seat(player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seats = _assignTableSeats(gameState.playersInOrder, myUserId);

    return Column(
      children: [
        _centerSeat(seats.top),
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
        _centerSeat(seats.bottom),
      ],
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
              for (final gem in _cardBonusGemOrder)
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
              for (final gem in _cardBonusGemOrder)
                _GemCardStack(
                  color: _gemPanelColor(gem),
                  cards: cardsByGem[gem] ?? const [],
                ),
            ],
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 9,
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
    final size = isGold ? 18.0 : 15.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gemPipColor(gem.wireValue),
        shape: BoxShape.circle,
        border: Border.all(
          color: isGold ? Colors.white70 : Colors.white24,
          width: isGold ? 1.2 : 0.5,
        ),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: isGold ? 9.5 : 8.5,
          fontWeight: FontWeight.w800,
          color: gemPipTextColor(gem.wireValue),
        ),
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

    final overlap = cards.length == 1
        ? 0.0
        : ((_maxColumnH - _cardH) / (cards.length - 1)).clamp(4.0, 14.0);
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

class _ActionBar extends StatelessWidget {
  final BoardSelection selection;
  final Map<String, int> tokenBank;
  final VoidCallback onConfirm;
  final VoidCallback? onReserve;
  final VoidCallback onCancel;

  const _ActionBar({
    required this.selection,
    required this.tokenBank,
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
    final canConfirm = isGemSelection
        ? isValidTokenSelection(selection.gemsAsList, tokenBank)
        : true;
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
          if (onReserve != null) ...[
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onReserve, child: const Text('예약')),
          ],
          const SizedBox(width: 8),
          TextButton(onPressed: onCancel, child: const Text('취소')),
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
