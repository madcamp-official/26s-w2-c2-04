import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/player.dart';
import '../state/auth_controller.dart';
import '../state/friend_controller.dart';
import '../theme/app_theme.dart';
import 'profile.dart';

/// 친구 화면. Main page design/App.tsx의 FriendsOverlay(온라인/오프라인 목록,
/// 검색+추가, 요청 수락/거절, 프로필 보기/메시지 보내기)에 대응합니다.
/// README 3절/9절 스펙대로 REST + SocialHub를 완전히 구현했지만, 백엔드에
/// 아직 친구 관련 엔드포인트가 없어(backend/Backend/Endpoints 기준) 지금은
/// 로딩 실패 상태가 그대로 노출됩니다.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(friendControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openChat(Friend friend) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FriendChatScreen(friend: friend)),
    );
  }

  void _openProfile(int userId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)),
    );
  }

  void _showFriendActions(Friend friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('프로필 보기'),
              onTap: () {
                Navigator.of(context).pop();
                _openProfile(friend.userId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('메시지 보내기'),
              onTap: () {
                Navigator.of(context).pop();
                _openChat(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined, color: AppColors.danger),
              title: const Text('친구 삭제', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(friendControllerProvider.notifier).deleteFriend(friend.userId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddFriendDialog() async {
    _searchController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const OrnateTitle(kicker: 'Social hub', title: '친구 추가'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: '닉네임으로 검색',
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
                onSubmitted: (v) =>
                    ref.read(friendControllerProvider.notifier).searchUsers(v),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(friendControllerProvider);
                  final results = state is FriendsLoaded ? state.searchResults : <Player>[];
                  if (results.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('검색 결과가 없습니다.', style: TextStyle(color: AppColors.textMuted)),
                    );
                  }
                  return SizedBox(
                    height: 200,
                    child: ListView(
                      children: [
                        for (final user in results)
                          ListTile(
                            title: Text(user.nickname),
                            trailing: TextButton(
                              onPressed: () async {
                                await ref
                                    .read(friendControllerProvider.notifier)
                                    .sendFriendRequest(user.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(content: Text('친구 요청을 보냈습니다.')));
                                }
                              },
                              child: const Text('요청'),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('FRIENDS')),
      body: GemBackdrop(
        child: switch (state) {
          FriendsInitial() || FriendsLoading() =>
            const Center(child: CircularProgressIndicator()),
          FriendsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '친구 목록을 불러오지 못했습니다.\n$message',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          FriendsLoaded() => ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                const OrnateTitle(kicker: 'Social hub', title: '친구'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showAddFriendDialog,
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('ADD A FRIEND'),
                  ),
                ),
                if (state.incomingRequests.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('REQUESTS · ${state.incomingRequests.length}', style: kickerStyle(size: 11)),
                  const SizedBox(height: 8),
                  for (final request in state.incomingRequests)
                    _RequestRow(
                      request: request,
                      onAccept: () => ref.read(friendControllerProvider.notifier).acceptRequest(request),
                      onReject: () => ref.read(friendControllerProvider.notifier).rejectRequest(request),
                    ),
                ],
                const SizedBox(height: 24),
                Text('ONLINE · ${state.online.length}', style: kickerStyle(size: 11, color: AppColors.success)),
                const SizedBox(height: 8),
                if (state.online.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('온라인 친구가 없습니다.', style: TextStyle(color: AppColors.textMuted)),
                  )
                else
                  for (final friend in state.online)
                    _FriendRow(friend: friend, onTap: () => _showFriendActions(friend)),
                if (state.offline.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('OFFLINE · ${state.offline.length}', style: kickerStyle(size: 11)),
                  const SizedBox(height: 8),
                  for (final friend in state.offline)
                    _FriendRow(friend: friend, onTap: () => _showFriendActions(friend)),
                ],
              ],
            ),
        },
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final Friend friend;
  final VoidCallback onTap;
  const _FriendRow({required this.friend, required this.onTap});

  Color get _statusColor => switch (friend.status) {
        FriendStatus.inGame => AppColors.gold,
        FriendStatus.online => AppColors.success,
        FriendStatus.away => AppColors.textMuted,
        FriendStatus.offline => AppColors.textMuted,
      };

  String get _statusLabel => switch (friend.status) {
        FriendStatus.inGame => 'in game',
        FriendStatus.online => 'online',
        FriendStatus.away => 'away',
        FriendStatus.offline => 'offline',
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: AppColors.goldHairline)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: avatarToneFor(friend.nickname),
              backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
              child: friend.avatarUrl == null
                  ? Text(friend.nickname.characters.first,
                      style: const TextStyle(color: AppColors.textHeading, fontSize: 13))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.nickname, style: const TextStyle(fontSize: 13)),
                  Text(_statusLabel,
                      style: TextStyle(fontSize: 10, color: _statusColor, letterSpacing: 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _RequestRow({required this.request, required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: AppColors.goldHairline)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: avatarToneFor(request.nickname),
            child: Text(request.nickname.characters.first,
                style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(request.nickname)),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.success),
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.danger),
            onPressed: onReject,
          ),
        ],
      ),
    );
  }
}

class _FriendChatScreen extends ConsumerStatefulWidget {
  final Friend friend;
  const _FriendChatScreen({required this.friend});

  @override
  ConsumerState<_FriendChatScreen> createState() => _FriendChatScreenState();
}

class _FriendChatScreenState extends ConsumerState<_FriendChatScreen> {
  final _draftController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 영구 저장된 이전 대화 이력을 불러온다(실시간 송수신은 SocialHub가 계속 처리).
    Future.microtask(() {
      final auth = ref.read(authControllerProvider);
      if (auth is AuthAuthenticated) {
        ref.read(friendControllerProvider.notifier).loadHistory(
              widget.friend.userId,
              myUserId: auth.user.userId,
            );
      }
    });
  }

  Future<void> _send() async {
    final text = _draftController.text.trim();
    if (text.isEmpty) return;
    await ref
        .read(friendControllerProvider.notifier)
        .sendChatMessage(widget.friend.userId, text);
    _draftController.clear();
  }

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendControllerProvider);
    final history = state is FriendsLoaded ? (state.chatHistory[widget.friend.userId] ?? const []) : const [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.friend.nickname)),
      body: GemBackdrop(
        child: Column(
          children: [
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text('대화를 시작해보세요', style: TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final message in history)
                          Align(
                            alignment: message.mine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              constraints: const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color: message.mine
                                    ? AppColors.goldFaint.withValues(alpha: 0.2)
                                    : AppColors.panelAlt,
                                border: Border.all(color: AppColors.goldHairline),
                              ),
                              child: Text(message.text),
                            ),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _draftController,
                      decoration: const InputDecoration(hintText: '메시지 입력…'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
