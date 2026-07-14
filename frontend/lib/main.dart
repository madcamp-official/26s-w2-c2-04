import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/leaderboard.dart';
import 'state/active_room_controller.dart';
import 'state/auth_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/minimized_room_badge.dart';
import 'widgets/social_toast_overlay.dart';

/// MaterialApp.builder는 실제 Navigator 바깥(위)에서 실행되므로, 배지에서
/// 화면을 미는(push) 데 필요한 NavigatorState를 여기 전역 키로 들고 있는다.
final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      navigatorObservers: [playRouteObserver],
      title: 'Splendor Multiplayer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
      },
      builder: (context, child) {
        final activeRoom = ref.watch(activeRoomProvider);
        final roomScreenVisible = ref.watch(roomScreenVisibleProvider);
        return Stack(
          children: [
            if (child != null) child,
            if (activeRoom != null && !roomScreenVisible)
              MinimizedRoomBadge(room: activeRoom, navigatorKey: rootNavigatorKey),
            // 로그인 중 어느 화면에서든 친구 메시지/요청이 오면 우하귀에 알림을 띄운다.
            const SocialToastOverlay(),
          ],
        );
      },
    );
  }
}

/// 앱 시작 시 저장된 세션(accessToken/refreshToken)이 있으면 홈 화면으로,
/// 없으면 로그인 화면으로 보냅니다.
class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).restoreSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return switch (authState) {
      AuthAuthenticated() => const HomeScreen(),
      _ => const LoginScreen(),
    };
  }
}
