// 게임 시작 전 방에 들어가 있는 동안, 다른 화면으로 뒤로가기 했을 때
// 화면 좌하단에 떠서 "그 방으로 돌아가기"를 제공하는 작은 배지.
// main.dart의 MaterialApp.builder에서 activeRoomProvider를 감시해 띄운다.

import 'package:flutter/material.dart';
import '../models/gameroom.dart';
import '../screens/play.dart';
import '../theme/app_theme.dart';

class MinimizedRoomBadge extends StatefulWidget {
  final GameRoom room;
  final GlobalKey<NavigatorState> navigatorKey;

  const MinimizedRoomBadge({
    super.key,
    required this.room,
    required this.navigatorKey,
  });

  @override
  State<MinimizedRoomBadge> createState() => _MinimizedRoomBadgeState();
}

class _MinimizedRoomBadgeState extends State<MinimizedRoomBadge> {
  // 이 배지 자체는 PlayScreen이 mount되면(roomScreenVisibleProvider) main.dart가
  // 트리에서 완전히 빼버리므로 더 이상 겹쳐 보이지 않는다. 다만 그 상태 반영이
  // 한 프레임 늦을 수 있어, push가 끝나기(그 라우트가 pop되기) 전까지 추가 탭을
  // 무시하는 보조 가드를 남겨둔다.
  bool _pushing = false;

  void _openRoom() {
    if (_pushing) return;
    setState(() => _pushing = true);
    widget.navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (_) => PlayScreen(room: widget.room)))
        .whenComplete(() {
      if (mounted) setState(() => _pushing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: _openRoom,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.meeting_room, size: 18, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    '방 ${widget.room.roomId} 대기 중',
                    style: const TextStyle(
                      color: AppColors.textHeading,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
