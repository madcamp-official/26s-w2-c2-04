// 방 생성/목록/조회/참가/퇴장/시작/삭제 등 방(Room) 생명주기 REST API 전부를
// 처리합니다. 방장이 /rooms/{roomId}/start를 호출한 이후의 실제 게임 진행은
// GameHub(SignalR)로 넘어가므로 socket_service.dart가 담당합니다.

import 'dart:convert';
import 'api_client.dart';
import '../models/gameroom.dart';
import '../models/room_list_response.dart';

class RoomService {
  final ApiClient _client;

  RoomService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<GameRoom> createRoom({
    int maxPlayers = 4,
    bool isPrivate = false,
    String? password,
  }) async {
    final res = await _client.post(
      '/rooms',
      body: {
        'maxPlayers': maxPlayers,
        'isPrivate': isPrivate,
        'password': password,
      },
    );
    ApiClient.ensureOk(res, '방 생성에 실패했습니다.');
    return GameRoom.fromJson(jsonDecode(res.body));
  }

  Future<RoomListResponse> listRooms({int page = 1, int limit = 20}) async {
    final res = await _client.get(
      '/rooms',
      query: {'page': '$page', 'limit': '$limit'},
    );
    ApiClient.ensureOk(res, '방 목록을 불러오지 못했습니다.');
    return RoomListResponse.fromJson(jsonDecode(res.body));
  }

  Future<GameRoom> getRoom(int roomId) async {
    final res = await _client.get('/rooms/$roomId');
    ApiClient.ensureOk(res, '방 정보를 불러오지 못했습니다.');
    return GameRoom.fromJson(jsonDecode(res.body));
  }

  Future<GameRoom> joinRoom(int roomId, {String? password}) async {
    final res = await _client.post(
      '/rooms/$roomId/join',
      body: password == null ? {} : {'password': password},
    );
    ApiClient.ensureOk(res, '방 참가에 실패했습니다.');
    return GameRoom.fromJson(jsonDecode(res.body));
  }

  Future<void> leaveRoom(int roomId) async {
    final res = await _client.post('/rooms/$roomId/leave');
    ApiClient.ensureOk(res, '방 퇴장에 실패했습니다.');
  }

  /// 대기실에서 내 "준비" 상태를 갱신합니다(README 4/8절). 서버가 갱신된 방을
  /// 돌려주고, 방 그룹(GameHub) 전체에 PlayerReadyChanged를 브로드캐스트하므로
  /// 호출한 본인도 그 이벤트로 상태가 맞춰집니다.
  Future<GameRoom> setReady(int roomId, bool ready) async {
    final res = await _client.post(
      '/rooms/$roomId/ready',
      body: {'ready': ready},
    );
    ApiClient.ensureOk(res, '준비 상태 변경에 실패했습니다.');
    return GameRoom.fromJson(jsonDecode(res.body));
  }

  /// 방장이 게임을 시작합니다. 이후 진행은 GameHub의 JoinRoom/StateSync로 이어집니다.
  Future<({int gameId, String phase})> startGame(int roomId) async {
    final res = await _client.post('/rooms/$roomId/start');
    ApiClient.ensureOk(res, '게임 시작에 실패했습니다.');
    final json = jsonDecode(res.body);
    return (
      gameId: (json['gameId'] as num).toInt(),
      phase: json['phase'] as String,
    );
  }

  Future<void> deleteRoom(int roomId) async {
    final res = await _client.delete('/rooms/$roomId');
    ApiClient.ensureOk(res, '방 삭제에 실패했습니다.');
  }

  /// 랭크 매칭. POST /matchmaking/{playerCount}/ranked는 대기열에 넣을 뿐
  /// 즉시 방을 돌려주지 않습니다(MatchmakingDtos.MatchmakingStatusResponse,
  /// Status: QUEUED/MATCHED/NOT_QUEUED) — 실제 매칭은 MatchmakingWorker가
  /// 2초 주기 백그라운드 틱으로 처리하므로, 성사될 때까지
  /// GET /matchmaking/{playerCount}/status를 폴링해야 합니다. MATCHED가 되면
  /// roomId가 채워지고, 그 방을 GET /rooms/{roomId}로 조회해 돌려줍니다.
  ///
  /// [isCancelled]가 true를 반환하면(매칭 화면에서 취소) 폴링을 멈추고 실패로
  /// 끝냅니다 — 대기열 이탈 자체는 [cancelRankedMatch]로 별도 호출해야 합니다.
  Future<GameRoom> rankedMatch(
    int playerCount, {
    Duration pollInterval = const Duration(seconds: 2),
    bool Function()? isCancelled,
  }) async {
    final enqueueRes = await _client.post('/matchmaking/$playerCount/ranked');
    ApiClient.ensureOk(enqueueRes, '랭크 매칭에 실패했습니다.');

    while (true) {
      if (isCancelled?.call() ?? false) {
        throw StateError('랭크 매칭이 취소되었습니다.');
      }

      final statusRes = await _client.get('/matchmaking/$playerCount/status');
      ApiClient.ensureOk(statusRes, '랭크 매칭 상태를 확인하지 못했습니다.');
      final status = jsonDecode(statusRes.body) as Map<String, dynamic>;

      switch (status['status']) {
        case 'MATCHED':
          final roomId = (status['roomId'] as num).toInt();
          return getRoom(roomId);
        case 'QUEUED':
          await Future.delayed(pollInterval);
          continue;
        default:
          // NOT_QUEUED: TTL 만료 등으로 대기열에서 예기치 않게 빠진 경우.
          throw StateError('랭크 매칭 대기열에서 이탈했습니다. 다시 시도해주세요.');
      }
    }
  }

  /// 랭크 매칭 대기열에서 스스로 빠집니다(매칭 화면 취소 버튼).
  Future<void> cancelRankedMatch(int playerCount) async {
    final res = await _client.delete('/matchmaking/$playerCount/ranked');
    ApiClient.ensureOk(res, '랭크 매칭 취소에 실패했습니다.');
  }
}
