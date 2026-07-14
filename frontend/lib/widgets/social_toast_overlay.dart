// 로그인해 있는 동안(SocialHub 상시 연결) 앱 어느 화면에서든, 친구의 메시지나
// 친구 추가 요청이 실시간으로 도착하면 화면 우하귀에 작은 알림을 띄운다.
// main.dart의 MaterialApp.builder Stack에 얹혀 있어 어떤 라우트 위에서도 보인다.
//
// - 메시지 알림: 보낸 텍스트 + 그 자리에서 바로 답장할 수 있는 작은 입력창.
// - 친구 요청 알림: 수락/거절/닫기 버튼.
// 두 알림 모두 10초가 지나면 자동으로 사라진다.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_hub_event.dart';
import '../services/social_socket_service.dart';
import '../state/friend_controller.dart';
import '../theme/app_theme.dart';

/// 화면에 떠 있는 알림 하나. 종류별(메시지/친구요청) 데이터를 함께 들고 있다.
class _Toast {
  final int id;
  final bool isRequest;
  // 공통
  final int userId;
  final String title;
  // 메시지 전용
  final String? messageText;
  // 요청 전용
  final int requestId;
  final String requestNickname;

  const _Toast({
    required this.id,
    required this.isRequest,
    required this.userId,
    required this.title,
    this.messageText,
    this.requestId = 0,
    this.requestNickname = '',
  });
}

class SocialToastOverlay extends ConsumerStatefulWidget {
  const SocialToastOverlay({super.key});

  @override
  ConsumerState<SocialToastOverlay> createState() => _SocialToastOverlayState();
}

class _SocialToastOverlayState extends ConsumerState<SocialToastOverlay> {
  StreamSubscription<SocialHubEvent>? _sub;
  final List<_Toast> _toasts = [];
  final Map<int, Timer> _timers = {};
  int _nextId = 0;

  static const _autoDismiss = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    // 세션 내내 살아있는 공유 SocialHub 소켓의 이벤트를 구독한다(로그인 상태에서만
    // 실제 이벤트가 흘러오므로 미로그인 시에는 아무 알림도 뜨지 않는다).
    _sub = ref.read(socialSocketProvider).events.listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    for (final t in _timers.values) {
      t.cancel();
    }
    super.dispose();
  }

  void _onEvent(SocialHubEvent event) {
    event.when(
      friendRequestReceived: (requestId, fromUserId, fromNickname) => _push(_Toast(
        id: _nextId++,
        isRequest: true,
        userId: fromUserId,
        title: '친구 요청',
        requestId: requestId,
        requestNickname: fromNickname,
      )),
      friendRequestAccepted: (_, __) {},
      friendStatusChanged: (_, __) {},
      friendMessageReceived: (fromUserId, text, ts) => _push(_Toast(
        id: _nextId++,
        isRequest: false,
        userId: fromUserId,
        title: '새 메시지',
        messageText: text,
      )),
    );
  }

  void _push(_Toast toast) {
    if (!mounted) return;
    setState(() => _toasts.add(toast));
    _timers[toast.id] = Timer(_autoDismiss, () => _dismiss(toast.id));
  }

  void _dismiss(int id) {
    _timers.remove(id)?.cancel();
    if (!mounted) return;
    setState(() => _toasts.removeWhere((t) => t.id == id));
  }

  Future<void> _accept(_Toast toast) async {
    _dismiss(toast.id);
    try {
      await ref.read(friendServiceProvider).acceptRequest(toast.requestId);
    } catch (_) {
      // 알림에서의 수락 실패는 조용히 넘긴다 — 친구 화면에서 다시 처리할 수 있다.
    }
  }

  Future<void> _reject(_Toast toast) async {
    _dismiss(toast.id);
    try {
      await ref.read(friendServiceProvider).rejectRequest(toast.requestId);
    } catch (_) {}
  }

  Future<void> _reply(_Toast toast, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _dismiss(toast.id);
    try {
      await ref
          .read(socialSocketProvider)
          .sendFriendMessage(toUserId: toast.userId, text: trimmed);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_toasts.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final toast in _toasts)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: toast.isRequest
                    ? _FriendRequestToast(
                        nickname: toast.requestNickname,
                        onAccept: () => _accept(toast),
                        onReject: () => _reject(toast),
                        onClose: () => _dismiss(toast.id),
                      )
                    : _MessageToast(
                        text: toast.messageText ?? '',
                        onSend: (reply) => _reply(toast, reply),
                        onClose: () => _dismiss(toast.id),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToastShell extends StatelessWidget {
  final Widget child;
  const _ToastShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _FriendRequestToast extends StatelessWidget {
  final String nickname;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onClose;
  const _FriendRequestToast({
    required this.nickname,
    required this.onAccept,
    required this.onReject,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _ToastShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('친구 요청',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeading)),
              ),
              InkWell(
                onTap: onClose,
                child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('$nickname 님이 친구 요청을 보냈습니다.',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onReject, child: const Text('거절')),
              const SizedBox(width: 6),
              ElevatedButton(onPressed: onAccept, child: const Text('수락')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageToast extends StatefulWidget {
  final String text;
  final ValueChanged<String> onSend;
  final VoidCallback onClose;
  const _MessageToast({
    required this.text,
    required this.onSend,
    required this.onClose,
  });

  @override
  State<_MessageToast> createState() => _MessageToastState();
}

class _MessageToastState extends State<_MessageToast> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ToastShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('새 메시지',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeading)),
              ),
              InkWell(
                onTap: widget.onClose,
                child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: '답장…',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onSubmitted: widget.onSend,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, size: 18),
                onPressed: () => widget.onSend(_controller.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
