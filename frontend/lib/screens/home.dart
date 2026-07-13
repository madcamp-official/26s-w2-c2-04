import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';
import '../theme/app_theme.dart';
import 'friends.dart';
import 'leaderboard.dart';
import 'profile.dart';
import 'settings.dart';
import 'setup.dart';

/// 로그인 이후 첫 화면. Main page design/App.tsx의 기본 레이아웃(SPLENDOR 타이틀 +
/// MULTIPLAYER/LEADERBOARD 버튼 + 우하단 Profile/Friends/Settings 유틸리티 버튼)에
/// 대응합니다. 여기서 바로 방 목록으로 넘어가지 않고, MULTIPLAYER를 누르면
/// setup.dart(모드/방식/인원수 선택)를 먼저 거칩니다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GemBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: '로그아웃',
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logOut();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (_) => false);
                    }
                  },
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'THE GUILD OF GEM MERCHANTS',
                        textAlign: TextAlign.center,
                        style: kickerStyle(letterSpacing: 4),
                      ),
                      const SizedBox(height: 12),
                      Text('SPLENDOR', style: headingStyle(size: 48, letterSpacing: 8)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 56, height: 1, color: AppColors.gold),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.emoji_events, size: 18, color: AppColors.gold),
                          ),
                          Container(width: 56, height: 1, color: AppColors.gold),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gather your patrons. Build a legacy in precious stones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 48),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _HomeActionCard(
                            icon: Icons.sports_kabaddi,
                            title: 'MULTIPLAYER',
                            subtitle: 'ENTER THE MARKET',
                            filled: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SetupScreen()),
                            ),
                          ),
                          _HomeActionCard(
                            icon: Icons.emoji_events_outlined,
                            title: 'LEADERBOARD',
                            subtitle: 'SEASON VII',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Row(
                  children: [
                    _UtilityButton(
                      icon: Icons.person_outline,
                      tooltip: '프로필',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _UtilityButton(
                      icon: Icons.group_outlined,
                      tooltip: '친구',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FriendsScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _UtilityButton(
                      icon: Icons.settings_outlined,
                      tooltip: '설정',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: filled ? AppColors.goldFaint.withValues(alpha: 0.12) : AppColors.panelAlt.withValues(alpha: 0.5),
          border: Border.all(color: filled ? AppColors.gold.withValues(alpha: 0.6) : AppColors.goldHairline),
        ),
        child: Column(
          children: [
            Icon(icon, color: filled ? AppColors.gold : AppColors.sapphire, size: 26),
            const SizedBox(height: 10),
            Text(title, style: headingStyle(size: 15)),
            const SizedBox(height: 4),
            Text(subtitle, style: kickerStyle(size: 10)),
          ],
        ),
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _UtilityButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.panelAlt.withValues(alpha: 0.8),
            border: Border.all(color: AppColors.goldHairline),
          ),
          child: Icon(icon, size: 18, color: AppColors.gold.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}
