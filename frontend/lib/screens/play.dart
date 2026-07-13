import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';
import '../models/game_hub_event.dart';
import '../models/game_state.dart';
import '../models/gameroom.dart';
import '../models/gem.dart';
import '../state/auth_controller.dart';
import '../state/game_controller.dart';
import '../state/lobby_controller.dart';
import '../theme/app_theme.dart';

/// 방 대기실 + 실제 게임 진행 화면.
/// GameHub 연결 전(WAITING)에는 대기실 UI를, 연결 후(PLAYING)에는 보드/토큰/
/// 카드/귀족/채팅 등 실시간 게임 UI를 보여줍니다.
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
  final Set<Gem> _selectedGems = {};

  bool get _isHost {
    final auth = ref.read(authControllerProvider);
    return auth is AuthAuthenticated && widget.room.hostId == auth.user.userId;
  }

  @override
  void initState() {
    super.initState();
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

  void _toggleGem(Gem gem) {
    setState(() {
      if (_selectedGems.contains(gem)) {
        _selectedGems.remove(gem);
      } else if (_selectedGems.length < 3) {
        _selectedGems.add(gem);
      }
    });
  }

  Future<void> _confirmTakeTokens() async {
    if (_selectedGems.isEmpty) return;
    await ref
        .read(gameControllerProvider.notifier)
        .takeTokens(_selectedGems.map((g) => g.wireValue).toList());
    setState(() => _selectedGems.clear());
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
        GameConnected(:final gameState) => _GameBoard(
            room: widget.room,
            gameState: gameState,
            selectedGems: _selectedGems,
            onToggleGem: _toggleGem,
            onConfirmTakeTokens: _confirmTakeTokens,
            onPurchase: _purchase,
            onReserve: _reserve,
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

class _GameBoard extends StatelessWidget {
  final GameRoom room;
  final GameState gameState;
  final Set<Gem> selectedGems;
  final ValueChanged<Gem> onToggleGem;
  final VoidCallback onConfirmTakeTokens;
  final Future<void> Function(SplendorCard card, {required bool reserved})
      onPurchase;
  final Future<void> Function(SplendorCard card) onReserve;
  final TextEditingController chatController;
  final VoidCallback onSendChat;

  const _GameBoard({
    required this.room,
    required this.gameState,
    required this.selectedGems,
    required this.onToggleGem,
    required this.onConfirmTakeTokens,
    required this.onPurchase,
    required this.onReserve,
    required this.chatController,
    required this.onSendChat,
  });

  /// 백엔드 GameState.PlayerState에는 닉네임이 없어서 방 참가자 목록에서 조회합니다.
  String _nicknameFor(int userId) {
    for (final p in room.players) {
      if (p.id == userId) return p.nickname;
    }
    return 'User $userId';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '턴 ${gameState.turnNumber} · 현재 차례: ${gameState.currentPlayerId != null ? _nicknameFor(gameState.currentPlayerId!) : '-'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _TokenPool(
          tokens: gameState.tokenBank,
          selectedGems: selectedGems,
          onToggleGem: onToggleGem,
          onConfirm: onConfirmTakeTokens,
        ),
        Expanded(
          child: ListView(
            children: [
              for (final tier in gameState.boardTiers.reversed)
                _BoardTierRow(
                  tier: tier,
                  onPurchase: (card) => onPurchase(card, reserved: false),
                  onReserve: onReserve,
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('귀족', style: Theme.of(context).textTheme.titleSmall),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final noble in gameState.boardNobles)
                    Chip(label: Text('${noble.id} (+${noble.points})')),
                ],
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('플레이어', style: Theme.of(context).textTheme.titleSmall),
              ),
              for (final player in gameState.playersInOrder)
                ListTile(
                  title: Text(
                      '${_nicknameFor(player.userId)} · ${player.points}점'),
                  subtitle: Text(
                    '토큰: ${player.tokens.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
                  ),
                ),
            ],
          ),
        ),
        _ChatBar(controller: chatController, onSend: onSendChat),
      ],
    );
  }
}

class _TokenPool extends StatelessWidget {
  final Map<String, int> tokens;
  final Set<Gem> selectedGems;
  final ValueChanged<Gem> onToggleGem;
  final VoidCallback onConfirm;

  const _TokenPool({
    required this.tokens,
    required this.selectedGems,
    required this.onToggleGem,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                for (final gem in Gem.values.where((g) => g != Gem.gold))
                  FilterChip(
                    label: Text('${gem.wireValue} ${tokens[gem.wireValue] ?? 0}'),
                    selected: selectedGems.contains(gem),
                    onSelected: (_) => onToggleGem(gem),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: selectedGems.isEmpty ? null : onConfirm,
            child: const Text('토큰 획득'),
          ),
        ],
      ),
    );
  }
}

class _BoardTierRow extends StatelessWidget {
  final BoardTier tier;
  final Future<void> Function(SplendorCard card) onPurchase;
  final Future<void> Function(SplendorCard card) onReserve;

  const _BoardTierRow({
    required this.tier,
    required this.onPurchase,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('티어 ${tier.tier} (덱 ${tier.deckRemaining}장 남음)'),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final card in tier.visibleCards)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${card.bonus} +${card.points}점'),
                          Text(
                            card.cost.entries
                                .map((e) => '${e.key}:${e.value}')
                                .join(' '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => onPurchase(card),
                                child: const Text('구매'),
                              ),
                              TextButton(
                                onPressed: () => onReserve(card),
                                child: const Text('예약'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
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
