// 게임 조회 REST API(읽기 전용). GET /games/{gameId}/state,
// GET /replay/{gameId} 를 처리합니다.
// 실시간 턴 진행(토큰 획득/카드 구매/예약 등)은 REST가 아니라 GameHub
// (SignalR)로 이뤄지므로 socket_service.dart가 담당하고, 이 서비스는
// 관전/디버깅/재접속 폴백 및 리플레이 조회 용도로만 사용합니다.

import 'dart:convert';
import 'api_client.dart';
import '../models/game_state.dart';
import '../models/replay.dart';

class PlayService {
  final ApiClient _client;

  PlayService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<GameState> getGameState(int gameId) async {
    final res = await _client.get('/games/$gameId/state');
    ApiClient.ensureOk(res, '게임 상태를 불러오지 못했습니다.');
    return GameState.fromJson(jsonDecode(res.body));
  }

  Future<ReplayResponse> getReplay(int gameId) async {
    final res = await _client.get('/replay/$gameId');
    ApiClient.ensureOk(res, '리플레이를 불러오지 못했습니다.');
    return ReplayResponse.fromJson(jsonDecode(res.body));
  }
}
