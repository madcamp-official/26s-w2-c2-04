import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../state/profile_controller.dart';
import '../theme/app_theme.dart';

/// 프로필 화면. userId를 지정하지 않으면 로그인한 본인의 프로필(GET /profile/me)을,
/// 지정하면 그 유저의 프로필(GET /profile/{userId})을 보여줍니다.
/// 닉네임 변경/아바타 업로드는 백엔드에 대응 엔드포인트가 없거나(닉네임) 별도
/// 범위(아바타 업로드, 멀티파트)라 이 화면은 조회 전용입니다.
class ProfileScreen extends ConsumerStatefulWidget {
  final int? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileControllerProvider.notifier).load(userId: widget.userId),
    );
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
          ProfileLoaded(:final profile) => SingleChildScrollView(
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
                        child: Text(profile.nickname, style: headingStyle(size: 18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _StatsRow(stats: [
                    _StatEntry('Games', '${profile.totalGamesPlayed}'),
                    _StatEntry('Avg place', profile.overallAvgPlace.toStringAsFixed(1)),
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
                    for (final summary in profile.rankings) _RankedRecordRow(summary: summary),
                  const SizedBox(height: 28),
                  Text('RECENT GAMES', style: kickerStyle(size: 12)),
                  const SizedBox(height: 8),
                  if (profile.recentMatches.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('최근 게임 기록이 없습니다.', style: TextStyle(color: AppColors.textMuted)),
                    )
                  else
                    for (final match in profile.recentMatches) _RecentMatchRow(match: match),
                ],
              ),
            ),
        },
      ),
    );
  }
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
  final RankingSummary summary;
  const _RankedRecordRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.goldHairline)),
      ),
      child: Row(
        children: [
          Text('${summary.playerCount} Players',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            '${summary.gamesPlayed}게임 · 평균 ${summary.avgPlace.toStringAsFixed(1)}등',
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

class _RecentMatchRow extends StatelessWidget {
  final RecentMatch match;
  const _RecentMatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: AppColors.goldHairline)),
      child: Row(
        children: [
          Text(
            '${match.playerCount} Players · ${match.isRanked ? 'Ranked' : 'Unranked'}',
            style: const TextStyle(fontSize: 12),
          ),
          const Spacer(),
          Text('${match.place}등', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
