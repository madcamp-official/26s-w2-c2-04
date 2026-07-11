// 인원수(2/3/4)별 리더보드 탭 전환, 페이지네이션, 검색 상태를 관리합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../services/leaderboard_service.dart';

sealed class LeaderboardState {
  const LeaderboardState();
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  final int playerCount;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? myRank;
  final int page;
  final int total;
  final bool hasMore;
  final String? searchQuery;
  const LeaderboardLoaded({
    required this.playerCount,
    required this.entries,
    required this.myRank,
    required this.page,
    required this.total,
    required this.hasMore,
    this.searchQuery,
  });
}

class LeaderboardError extends LeaderboardState {
  final String message;
  const LeaderboardError(this.message);
}

final leaderboardServiceProvider = Provider((ref) => LeaderboardService());

final leaderboardControllerProvider =
    StateNotifierProvider<LeaderboardController, LeaderboardState>((ref) {
  return LeaderboardController(ref.read(leaderboardServiceProvider));
});

class LeaderboardController extends StateNotifier<LeaderboardState> {
  final LeaderboardService _service;
  LeaderboardController(this._service) : super(const LeaderboardInitial());

  Future<void> load(int playerCount) async {
    state = const LeaderboardLoading();
    try {
      final res = await _service.getLeaderboard(playerCount, page: 1);
      state = LeaderboardLoaded(
        playerCount: playerCount,
        entries: res.entries,
        myRank: res.myRank,
        page: res.page ?? 1,
        total: res.total,
        hasMore: res.entries.length < res.total,
      );
    } catch (e) {
      state = LeaderboardError(e.toString());
    }
  }

  /// 무한 스크롤: page=1은 1~100등, page=2는 101~200등 ... 순으로 이어 붙입니다.
  Future<void> loadMore() async {
    final current = state;
    if (current is! LeaderboardLoaded ||
        !current.hasMore ||
        current.searchQuery != null) {
      return;
    }
    try {
      final nextPage = current.page + 1;
      final res = await _service.getLeaderboard(
        current.playerCount,
        page: nextPage,
      );
      final merged = [...current.entries, ...res.entries];
      state = LeaderboardLoaded(
        playerCount: current.playerCount,
        entries: merged,
        myRank: current.myRank,
        page: res.page ?? nextPage,
        total: res.total,
        hasMore: merged.length < res.total,
      );
    } catch (e) {
      state = LeaderboardError(e.toString());
    }
  }

  Future<void> search(int playerCount, String query) async {
    state = const LeaderboardLoading();
    try {
      final res = await _service.search(playerCount, query);
      state = LeaderboardLoaded(
        playerCount: playerCount,
        entries: res.entries,
        myRank: res.myRank,
        page: 1,
        total: res.total,
        hasMore: false,
        searchQuery: query,
      );
    } catch (e) {
      state = LeaderboardError(e.toString());
    }
  }
}
