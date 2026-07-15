import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gameroom.dart';
import '../state/lobby_controller.dart';
import '../theme/app_theme.dart';
import 'play.dart';

/// "Join room" 단계. setup.dart에서 선택한 인원수의 대기 중인 방 목록을 보여주고,
/// 참가하면 대기실(PlayScreen의 WAITING 상태)로 들어갑니다.
/// Main page design/App.tsx의 layer === "rooms" 화면에 대응합니다.
class RoomsScreen extends ConsumerStatefulWidget {
  final int players;
  const RoomsScreen({super.key, required this.players});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(lobbyControllerProvider.notifier).loadRooms());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(lobbyControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom(GameRoom room) async {
    String? password;
    if (room.isPrivate) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const OrnateTitle(kicker: 'Private table', title: '비밀번호 입력'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: '비밀번호'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('참가'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      password = controller.text;
    }

    try {
      final joined = await ref
          .read(lobbyControllerProvider.notifier)
          .joinRoom(room.roomId, password: password);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlayScreen(room: joined)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: '설정으로 돌아가기',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('OPEN TABLES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: lobbyState is LobbyLoading
                ? null
                : () => ref.read(lobbyControllerProvider.notifier).loadRooms(),
          ),
        ],
      ),
      body: GemBackdrop(
        child: RefreshIndicator(
          onRefresh: () => ref.read(lobbyControllerProvider.notifier).loadRooms(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: OrnateTitle(kicker: 'Open tables', title: '${widget.players}인 방 목록'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('ROOM', style: kickerStyle(size: 10)),
                    const Spacer(),
                    Text('PLAYERS', style: kickerStyle(size: 10)),
                    const SizedBox(width: 24),
                    Text('STATUS', style: kickerStyle(size: 10)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Divider(height: 1),
              ),
              Expanded(
                child: switch (lobbyState) {
                  LobbyInitial() || LobbyLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  LobbyError(:final message) => ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            '방 목록을 불러오지 못했습니다: $message',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  LobbyLoaded(:final rooms) when _filter(rooms).isEmpty => ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            '${widget.players}인 대기 중인 방이 없습니다. 방을 만들어보세요!',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  LobbyLoaded(:final rooms, :final hasMore) => ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: _filter(rooms).length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        final filtered = _filter(rooms);
                        if (index >= filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final room = filtered[index];
                        return _RoomRow(room: room, onJoin: () => _joinRoom(room));
                      },
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<GameRoom> _filter(List<GameRoom> rooms) =>
      rooms.where((r) => r.maxPlayers == widget.players).toList();
}

class _RoomRow extends StatelessWidget {
  final GameRoom room;
  final VoidCallback onJoin;
  const _RoomRow({required this.room, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final full = room.players.length >= room.maxPlayers;
    final isPlaying = room.status == RoomStatus.playing;
    final disabled = full || isPlaying;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.goldHairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              room.isPrivate ? Icons.lock_outline : Icons.circle,
              size: room.isPrivate ? 16 : 8,
              color: AppColors.gold.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '방 ${room.roomId}',
                style: headingStyle(size: 14, letterSpacing: 1),
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                '${room.players.length} / ${room.maxPlayers}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 84,
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: disabled ? null : onJoin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    textStyle: const TextStyle(fontSize: 11, letterSpacing: 1),
                  ),
                  child: Text(isPlaying ? 'PLAYING' : full ? 'FULL' : 'JOIN'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
