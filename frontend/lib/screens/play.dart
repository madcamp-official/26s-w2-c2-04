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

/// 방 대기실 + 실제 게임 진행 화면.
/// GameHub 연결 전(WAITING)에는 대기실 UI를, 연결 후(PLAYING)에는 보드/토큰/
/// 카드/귀족/채팅 등 실시간 게임 UI를 보여줍니다.
class PlayScreen extends ConsumerStatefulWidget {
  final GameRoom room;
  const PlayScreen({super.key, required this.room});

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
        title: Text('방 ${widget.room.roomId}'),
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
            gameState: gameState,
            selectedGems: _selectedGems,
            onToggleGem: _toggleGem,
            onConfirmTakeTokens: _confirmTakeTokens,
            onPurchase: _purchase,
            onReserve: _reserve,
            chatController: _chatController,
            onSendChat: _sendChat,
          ),
        GameDisconnected() => _WaitingRoom(
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
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('참가자', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (final player in room.players)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: player.avatarUrl != null
                        ? NetworkImage(player.avatarUrl!)
                        : null,
                    child: player.avatarUrl == null
                        ? Text(player.nickname.characters.first)
                        : null,
                  ),
                  title: Text(player.nickname),
                  trailing: player.id == room.hostId
                      ? const Chip(label: Text('방장'))
                      : null,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isHost ? onStart : null,
              child: Text(isHost ? '게임 시작' : '방장이 시작하기를 기다리는 중...'),
            ),
          ),
        ),
      ],
    );
  }
}

class _GameBoard extends StatelessWidget {
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
    required this.gameState,
    required this.selectedGems,
    required this.onToggleGem,
    required this.onConfirmTakeTokens,
    required this.onPurchase,
    required this.onReserve,
    required this.chatController,
    required this.onSendChat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '턴 ${gameState.turnNumber} · 현재 차례: ${gameState.currentPlayerId ?? '-'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _TokenPool(
          tokens: gameState.tokens,
          selectedGems: selectedGems,
          onToggleGem: onToggleGem,
          onConfirm: onConfirmTakeTokens,
        ),
        Expanded(
          child: ListView(
            children: [
              for (final tier in gameState.board.reversed)
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
                  for (final noble in gameState.nobles)
                    Chip(label: Text('${noble.id} (+${noble.points})')),
                ],
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('플레이어', style: Theme.of(context).textTheme.titleSmall),
              ),
              for (final player in gameState.players)
                ListTile(
                  title: Text('${player.nickname} · ${player.score}점'),
                  subtitle: Text(
                    '토큰: ${player.gems.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
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
