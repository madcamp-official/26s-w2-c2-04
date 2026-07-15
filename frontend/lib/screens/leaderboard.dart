import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../state/leaderboard_controller.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  static const _playerCounts = [2, 3, 4];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _playerCounts.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(leaderboardControllerProvider.notifier)
            .load(_playerCounts[_tabController.index]);
      }
    });
    Future.microtask(
      () => ref.read(leaderboardControllerProvider.notifier).load(_playerCounts[0]),
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(leaderboardControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final playerCount = _playerCounts[_tabController.index];
    if (query.trim().isEmpty) {
      ref.read(leaderboardControllerProvider.notifier).load(playerCount);
    } else {
      ref.read(leaderboardControllerProvider.notifier).search(playerCount, query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GUILD STANDINGS'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _playerCounts.map((n) => Tab(text: '$n PLAYER')).toList(),
        ),
      ),
      body: GemBackdrop(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: OrnateTitle(kicker: 'Season VII · ranked', title: '리더보드'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: '닉네임 또는 유저 ID로 검색',
                ),
                onSubmitted: _submitSearch,
              ),
            ),
            Expanded(
              child: switch (state) {
                LeaderboardInitial() || LeaderboardLoading() =>
                  const Center(child: CircularProgressIndicator()),
                LeaderboardError(:final message) => Center(
                    child: Text(
                      '리더보드를 불러오지 못했습니다: $message',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                LeaderboardLoaded(:final myRank) => Column(
                    children: [
                      if (myRank != null) _MyRankBanner(entry: myRank),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(width: 48, child: Text('RANK', style: kickerStyle(size: 10))),
                            Expanded(child: Text('MERCHANT', style: kickerStyle(size: 10))),
                            SizedBox(width: 70, child: Text('MMR', style: kickerStyle(size: 10))),
                            SizedBox(width: 50, child: Text('AVG.', style: kickerStyle(size: 10))),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(height: 1),
                      ),
                      Expanded(child: _buildList(state)),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(LeaderboardLoaded state) {
    final entries = state.entries;
    if (entries.isEmpty) {
      return const Center(
        child: Text('결과가 없습니다.', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: entries.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final entry = entries[index];
        final isMe = state.myRank?.playerId == entry.playerId;
        return _LeaderboardRow(entry: entry, highlighted: isMe);
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool highlighted;
  const _LeaderboardRow({required this.entry, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final topThree = entry.rank <= 3;
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.goldFaint : null,
        border: const Border(bottom: BorderSide(color: AppColors.goldHairline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '#${entry.rank}',
              style: topThree
                  ? headingStyle(size: 13, color: const Color(0xFFE8C45E), letterSpacing: 0.5)
                  : const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              entry.nickname,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textHeading, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text('${entry.mmr}', style: const TextStyle(color: AppColors.gold)),
          ),
          SizedBox(
            width: 50,
            child: Text(
              entry.avgPlace.toStringAsFixed(1),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyRankBanner extends StatelessWidget {
  final LeaderboardEntry entry;
  const _MyRankBanner({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.panelAlt,
        border: Border.all(color: AppColors.goldFaint),
      ),
      child: Row(
        children: [
          const Icon(Icons.military_tech_outlined, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '내 순위: ${entry.rank}위 · ${entry.mmr} MMR',
              style: headingStyle(size: 13, letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
