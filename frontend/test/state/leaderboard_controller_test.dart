import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/leaderboard.dart';
import 'package:splendor_multiplayer/models/leaderboard_list_response.dart';
import 'package:splendor_multiplayer/services/leaderboard_service.dart';
import 'package:splendor_multiplayer/state/leaderboard_controller.dart';

LeaderboardEntry _entry(int rank, int id) => LeaderboardEntry(
      rank: rank,
      playerId: id,
      nickname: '유저$rank',
      mmr: 2000 - rank,
      avgPlace: 2.0,
      gamesPlayedSeason: 10,
    );

class _FakeLeaderboardService implements LeaderboardService {
  @override
  Future<LeaderboardListResponse> getLeaderboard(
    int playerCount, {
    int page = 1,
  }) async {
    if (page == 1) {
      return LeaderboardListResponse(
        playerCount: playerCount,
        page: 1,
        limit: 2,
        total: 3,
        entries: [_entry(1, 1), _entry(2, 2)],
        myRank: _entry(357, 1000),
      );
    }
    return LeaderboardListResponse(
      playerCount: playerCount,
      page: 2,
      limit: 2,
      total: 3,
      entries: [_entry(3, 3)],
    );
  }

  @override
  Future<LeaderboardListResponse> search(int playerCount, String query) async {
    return LeaderboardListResponse(
      playerCount: playerCount,
      total: 1,
      query: query,
      entries: [_entry(9, 9)],
    );
  }
}

void main() {
  test('load는 1페이지 + myRank를 담은 LeaderboardLoaded 상태로 만든다', () async {
    final controller = LeaderboardController(_FakeLeaderboardService());

    await controller.load(3);

    final state = controller.state as LeaderboardLoaded;
    expect(state.entries, hasLength(2));
    expect(state.myRank?.playerId, 1000);
    expect(state.hasMore, isTrue);
  });

  test('loadMore는 다음 페이지를 이어 붙인다', () async {
    final controller = LeaderboardController(_FakeLeaderboardService());
    await controller.load(3);

    await controller.loadMore();

    final state = controller.state as LeaderboardLoaded;
    expect(state.entries.map((e) => e.playerId), [1, 2, 3]);
    expect(state.hasMore, isFalse);
  });

  test('search는 검색 결과로 상태를 바꾸고 loadMore를 막는다', () async {
    final controller = LeaderboardController(_FakeLeaderboardService());

    await controller.search(3, '유저9');
    var state = controller.state as LeaderboardLoaded;
    expect(state.entries.single.playerId, 9);
    expect(state.searchQuery, '유저9');

    await controller.loadMore();
    state = controller.state as LeaderboardLoaded;
    // 검색 결과 상태에서는 loadMore가 아무것도 바꾸지 않아야 합니다.
    expect(state.entries.single.playerId, 9);
  });
}
