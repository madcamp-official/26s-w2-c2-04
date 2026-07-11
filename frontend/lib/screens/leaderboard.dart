import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../state/leaderboard_controller.dart';

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
        title: const Text('리더보드'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _playerCounts.map((n) => Tab(text: '$n인')).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '닉네임 또는 유저 ID로 검색',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _submitSearch,
            ),
          ),
          Expanded(
            child: switch (state) {
              LeaderboardInitial() || LeaderboardLoading() =>
                const Center(child: CircularProgressIndicator()),
              LeaderboardError(:final message) =>
                Center(child: Text('리더보드를 불러오지 못했습니다: $message')),
              LeaderboardLoaded(:final myRank) => Column(
                  children: [
                    if (myRank != null) _MyRankBanner(entry: myRank),
                    Expanded(child: _buildList(state)),
                  ],
                ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(LeaderboardLoaded state) {
    final entries = state.entries;
    if (entries.isEmpty) {
      return const Center(child: Text('결과가 없습니다.'));
    }
    return ListView.builder(
      controller: _scrollController,
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
        return ListTile(
          tileColor: isMe ? Theme.of(context).colorScheme.primaryContainer : null,
          leading: CircleAvatar(child: Text('${entry.rank}')),
          title: Text(entry.nickname),
          subtitle: Text('평균 등수 ${entry.avgPlace.toStringAsFixed(1)} · ${entry.gamesPlayedSeason}판'),
          trailing: Text('${entry.mmr} MMR'),
        );
      },
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
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(12),
      child: Text(
        '내 순위: ${entry.rank}위 · ${entry.mmr} MMR',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
