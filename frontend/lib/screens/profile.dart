import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../state/auth_controller.dart';
import '../state/profile_controller.dart';
import '../theme/app_theme.dart';

/// 프로필 화면. userId를 지정하지 않으면 로그인한 본인의 프로필을 보여줍니다.
/// (친구 목록에서 "프로필 보기"를 통해 다른 유저의 프로필도 같은 화면으로 봅니다.)
/// 백엔드에 GET /users/{userId}, /users/{userId}/stats가 아직 없어 로딩에 실패하면
/// 에러 상태가 그대로 노출됩니다 — README 스펙대로 프런트를 완성해둔 상태입니다.
class ProfileScreen extends ConsumerStatefulWidget {
  final int? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool get _isOwnProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final targetId = widget.userId ?? _currentUserId();
      if (targetId != null) {
        ref.read(profileControllerProvider.notifier).load(targetId);
      }
    });
  }

  int? _currentUserId() {
    final auth = ref.read(authControllerProvider);
    return auth is AuthAuthenticated ? auth.user.userId : null;
  }

  Future<void> _editNickname() async {
    final state = ref.read(profileControllerProvider);
    if (state is! ProfileLoaded) return;
    final controller = TextEditingController(text: state.profile.nickname);

    final newNickname = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const OrnateTitle(kicker: 'Merchant dossier', title: '닉네임 수정'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: '닉네임')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (newNickname != null && newNickname.isNotEmpty) {
      await ref.read(profileControllerProvider.notifier).updateNickname(newNickname);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MERCHANT DOSSIER')),
      body: GemBackdrop(
        child: switch (state) {
          ProfileInitial() || ProfileLoading() =>
            const Center(child: CircularProgressIndicator()),
          ProfileError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '프로필을 불러오지 못했습니다.\n$message',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          ProfileLoaded(:final profile, :final stats) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: avatarToneFor(profile.nickname),
                        backgroundImage:
                            profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                        child: profile.avatarUrl == null
                            ? Text(profile.nickname.characters.first,
                                style: const TextStyle(color: AppColors.textHeading))
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.nickname, style: headingStyle(size: 18)),
                            const SizedBox(height: 4),
                            Text(
                              '길드 가입일 ${_formatDate(profile.createdAt)}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (_isOwnProfile)
                        OutlinedButton(onPressed: _editNickname, child: const Text('수정')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _StatsRow(stats: [
                    _StatEntry('Games', '${stats.gamesPlayed}'),
                    _StatEntry('Wins', '${stats.wins}'),
                    _StatEntry('Avg score', stats.avgScore.toStringAsFixed(1)),
                    _StatEntry('Avg turns', stats.avgTurns.toStringAsFixed(1)),
                  ]),
                  const SizedBox(height: 28),
                  Text('RANKED RECORD', style: kickerStyle(size: 12)),
                  const SizedBox(height: 8),
                  if (profile.rankings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('랭크전 기록이 없습니다.', style: TextStyle(color: AppColors.textMuted)),
                    )
                  else
                    for (final entry in profile.rankings.entries)
                      _RankedRecordRow(playerCount: entry.key, summary: entry.value),
                  const SizedBox(height: 28),
                  Text('RECENT GAMES', style: kickerStyle(size: 12)),
                  const SizedBox(height: 8),
                  if (profile.recentGames.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('최근 게임 기록이 없습니다.', style: TextStyle(color: AppColors.textMuted)),
                    )
                  else
                    for (final game in profile.recentGames) _RecentGameRow(game: game),
                ],
              ),
            ),
        },
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

class _StatEntry {
  final String label;
  final String value;
  const _StatEntry(this.label, this.value);
}

class _StatsRow extends StatelessWidget {
  final List<_StatEntry> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final s in stats)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 1),
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: AppColors.panelAlt,
              child: Column(
                children: [
                  Text(s.value, style: headingStyle(size: 14)),
                  const SizedBox(height: 4),
                  Text(s.label, style: kickerStyle(size: 9)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RankedRecordRow extends StatelessWidget {
  final String playerCount;
  final RankingSummary summary;
  const _RankedRecordRow({required this.playerCount, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.goldHairline)),
      ),
      child: Row(
        children: [
          Text('$playerCount Players', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            '${summary.gamesPlayedSeason}게임 · 평균 ${summary.avgPlace.toStringAsFixed(1)}등',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const Spacer(),
          Text('#${summary.rank} · ${summary.mmr} MMR',
              style: const TextStyle(color: AppColors.gold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _RecentGameRow extends StatelessWidget {
  final RecentGame game;
  const _RecentGameRow({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: AppColors.goldHairline)),
      child: Row(
        children: [
          Text(
            '${game.playersNumber} Players · ${game.gameType}',
            style: const TextStyle(fontSize: 12),
          ),
          const Spacer(),
          Text('${game.place}등', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
