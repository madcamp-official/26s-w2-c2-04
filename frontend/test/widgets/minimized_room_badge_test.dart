import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/gameroom.dart';
import 'package:splendor_multiplayer/screens/play.dart';
import 'package:splendor_multiplayer/state/active_room_controller.dart';
import 'package:splendor_multiplayer/widgets/minimized_room_badge.dart';

/// main.dart의 MyApp과 같은 구조(MaterialApp.builder 안에서 ref.watch + Stack)를
/// 재현한 테스트 셸. 실제 PlayScreen을 push/pop하며 배지 표시 로직을 검증한다.
class _TestShell extends ConsumerWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const _TestShell({required this.navigatorKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [playRouteObserver],
      home: const Scaffold(body: Text('홈 화면')),
      builder: (context, child) {
        final activeRoom = ref.watch(activeRoomProvider);
        final roomScreenVisible = ref.watch(roomScreenVisibleProvider);
        return Stack(
          children: [
            if (child != null) child,
            if (activeRoom != null && !roomScreenVisible)
              MinimizedRoomBadge(room: activeRoom, navigatorKey: navigatorKey),
          ],
        );
      },
    );
  }
}

void main() {
  testWidgets('대기실에서 뒤로가기(pop)하면 좌하단 최소화 배지가 나타난다', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final room = GameRoom(
      roomId: 5566,
      hostId: 1024,
      players: const [],
      createdAt: DateTime.utc(2026, 7, 14),
    );

    await tester.pumpWidget(
      ProviderScope(child: _TestShell(navigatorKey: navigatorKey)),
    );

    navigatorKey.currentState!
        .push(MaterialPageRoute(builder: (_) => PlayScreen(room: room)));
    // push 애니메이션 + initState의 activeRoom/roomScreenVisible microtask 반영.
    // (PlayScreen이 CircularProgressIndicator를 돌리고 있어 pumpAndSettle은 못 쓴다.)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 방 화면이 떠 있는 동안에는 배지가 숨어 있어야 한다.
    expect(find.byType(MinimizedRoomBadge), findsNothing);

    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 뒤로가기 후에는 배지가 다시 나타나야 한다(회귀: dispose에 의존하던 시절
    // 플래그가 영영 안 풀려 배지가 안 뜨던 버그).
    expect(find.byType(MinimizedRoomBadge), findsOneWidget);
    expect(find.text('방 5566 대기 중'), findsOneWidget);
  });
}
