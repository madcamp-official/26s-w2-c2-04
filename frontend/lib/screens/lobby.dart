import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gameroom.dart';
import '../state/auth_controller.dart';
import '../state/lobby_controller.dart';
import 'play.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
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

  Future<void> _showCreateRoomDialog() async {
    int maxPlayers = 4;
    bool isPrivate = false;
    final passwordController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('방 만들기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: maxPlayers,
                decoration: const InputDecoration(labelText: '최대 인원'),
                items: const [2, 3, 4]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n명')))
                    .toList(),
                onChanged: (v) => setState(() => maxPlayers = v ?? 4),
              ),
              SwitchListTile(
                title: const Text('비공개 방'),
                value: isPrivate,
                onChanged: (v) => setState(() => isPrivate = v),
              ),
              if (isPrivate)
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: '비밀번호'),
                  obscureText: true,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('만들기'),
            ),
          ],
        ),
      ),
    );

    if (created != true || !mounted) return;
    try {
      final room = await ref.read(lobbyControllerProvider.notifier).createRoom(
            maxPlayers: maxPlayers,
            isPrivate: isPrivate,
            password: isPrivate ? passwordController.text : null,
          );
      if (!mounted) return;
      _enterRoom(room);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _joinRoom(GameRoom room) async {
    String? password;
    if (room.isPrivate) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('비밀번호 입력'),
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
      _enterRoom(joined);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _enterRoom(GameRoom room) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlayScreen(room: room)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('로비'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: '리더보드',
            onPressed: () => Navigator.of(context).pushNamed('/leaderboard'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoomDialog,
        icon: const Icon(Icons.add),
        label: const Text('방 만들기'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(lobbyControllerProvider.notifier).loadRooms(),
        child: switch (lobbyState) {
          LobbyInitial() || LobbyLoading() =>
            const Center(child: CircularProgressIndicator()),
          LobbyError(:final message) => ListView(
              children: [
                const SizedBox(height: 80),
                Center(child: Text('방 목록을 불러오지 못했습니다: $message')),
              ],
            ),
          LobbyLoaded(:final rooms) when rooms.isEmpty => ListView(
              children: const [
                SizedBox(height: 80),
                Center(child: Text('열려있는 방이 없습니다. 방을 만들어보세요!')),
              ],
            ),
          LobbyLoaded(:final rooms, :final hasMore) => ListView.builder(
              controller: _scrollController,
              itemCount: rooms.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= rooms.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(room.isPrivate ? Icons.lock : Icons.lock_open),
                    title: Text('방 ${room.roomId}'),
                    subtitle: Text('${room.players.length} / ${room.maxPlayers}명'),
                    trailing: ElevatedButton(
                      onPressed: room.players.length >= room.maxPlayers
                          ? null
                          : () => _joinRoom(room),
                      child: const Text('참가'),
                    ),
                  ),
                );
              },
            ),
        },
      ),
    );
  }
}
