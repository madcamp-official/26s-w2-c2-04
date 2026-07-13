import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/board_selection.dart';
import '../game/logic/game_rules.dart';
import '../game/splendor_game.dart';
import '../models/card.dart';
import '../models/game_hub_event.dart';
import '../models/game_state.dart';
import '../models/gameroom.dart';
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

    if (widget.autoConnect) {
      Future.microtask(() {
        final auth = ref.read(authControllerProvider);
        if (auth is AuthAuthenticated) {
          ref.read(gameControllerProvider.notifier).connect(
                roomId: widget.room.roomId,
                accessToken: auth.user.accessToken,
              );
        }
      });
    }
  }

  Future<void> _startGame() async {
    try {
      final result =
          await ref.read(roomServiceProvider).startGame(widget.room.roomId);
      final auth = ref.read(authControllerProvider);
      if (auth is! AuthAuthenticated) return;
      await ref.read(gameControllerProvider.notifier).connect(
            roomId: widget.room.roomId,
            accessToken: auth.user.accessToken,
          );
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
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.localLabel ?? '방 ${widget.room.roomId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: '나가기',
            onPressed: () async {
              if (gameState is GameConnected) {
                await ref.read(gameControllerProvider.notifier).leaveRoom();
              } else {
                await ref
                    .read(lobbyControllerProvider.notifier)
                    .leaveRoom(widget.room.roomId);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: switch (gameState) {
        GameConnecting() => const Center(child: CircularProgressIndicator()),
        GameError(:final message) => Center(child: Text('연결 실패: $message')),
        GameConnected(:final gameState, :final pendingNobleChoice) => _GameBoard(
            room: widget.room,
            gameState: gameState,
            pendingNobleChoice: pendingNobleChoice,
            game: _splendorGame,
            onPurchase: _purchase,
            onReserve: _reserve,
            onTakeTokens: _takeTokens,
            chatController: _chatController,
            onSendChat: _sendChat,
          ),
        GameDisconnected() => widget.autoConnect
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('다른 연금술사들을 기다리는 중입니다…\n정원이 차면 자동으로 시작됩니다.',
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            : _WaitingRoom(
                room: widget.room,
                isHost: _isHost,
                onStart: _startGame,
              ),
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
      await widget.onTakeTokens(selection.gems.toList());
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
          flex: 3,
          child: ClipRect(child: GameWidget(game: widget.game)),
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
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              Text('플레이어', style: Theme.of(context).textTheme.titleSmall),
              for (final player in widget.gameState.playersInOrder)
                ListTile(
                  dense: true,
                  title: Text('${_nicknameFor(player.userId)} · ${player.points}점'),
                  subtitle: Text(
                    '토큰: ${player.tokens.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
                  ),
                ),
            ],
          ),
        ),
        _ChatBar(controller: widget.chatController, onSend: widget.onSendChat),
      ],
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
        ? isValidTokenSelection(selection.gems.toList(), tokenBank)
        : true;
    final confirmLabel = selection.card != null
        ? (selection.cardIsReserved ? '예약 카드 구매' : '구매')
        : '토큰 획득 (${selection.gems.length}/3)';

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
