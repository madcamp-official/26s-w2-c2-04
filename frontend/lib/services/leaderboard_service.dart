// 리더보드 조회/검색 REST API. GET /leaderboard/{playerCount},
// GET /leaderboard/{playerCount}/search 를 처리합니다.

import 'dart:convert';
import 'api_client.dart';
import '../models/leaderboard_list_response.dart';

class LeaderboardService {
  final ApiClient _client;

  LeaderboardService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<LeaderboardListResponse> getLeaderboard(
    int playerCount, {
    int page = 1,
  }) async {
    final res = await _client.get(
      '/leaderboard/$playerCount',
      query: {'page': '$page'},
    );
    ApiClient.ensureOk(res, '리더보드를 불러오지 못했습니다.');
    return LeaderboardListResponse.fromJson(jsonDecode(res.body));
  }

  Future<LeaderboardListResponse> search(int playerCount, String query) async {
    final res = await _client.get(
      '/leaderboard/$playerCount/search',
      query: {'query': query},
    );
    ApiClient.ensureOk(res, '랭킹 검색에 실패했습니다.');
    return LeaderboardListResponse.fromJson(jsonDecode(res.body));
  }
}
