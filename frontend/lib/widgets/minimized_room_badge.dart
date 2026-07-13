// 게임 시작 전 방에 들어가 있는 동안, 다른 화면으로 뒤로가기 했을 때
// 화면 좌하단에 떠서 "그 방으로 돌아가기"를 제공하는 작은 배지.
// main.dart의 MaterialApp.builder에서 activeRoomProvider를 감시해 띄운다.

import 'package:flutter/material.dart';
import '../models/gameroom.dart';
import '../screens/play.dart';
import '../theme/app_theme.dart';

class MinimizedRoomBadge extends StatelessWidget {
  final GameRoom room;
  final GlobalKey<NavigatorState> navigatorKey;

  const MinimizedRoomBadge({
    super.key,
    required this.room,
    required this.navigatorKey,
  });

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
            onTap: () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => PlayScreen(room: room)),
              );
            },
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
                    '방 ${room.roomId} 대기 중',
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
