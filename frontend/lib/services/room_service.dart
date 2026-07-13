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

  /// 랭크 매칭. 호출 즉시 대기 중인 랭크 방에 참가하거나 새로 만들어 응답합니다
  /// (폴링용 대기열이 아니라 동기 응답). 정원이 그 자리에서 다 차면 응답의
  /// status가 이미 PLAYING일 수 있습니다.
  ///
  /// 이 계약은 아직 팀 내에서 확정되지 않았습니다(백엔드가 매칭을 서버 주도로
  /// 처리해 바로 게임으로 넘기는 방식으로 바뀔 수 있음). 계약이 바뀌면 이 메서드의
  /// 반환 타입/파싱만 맞춰 수정하면 되고, 호출부(matchmaking.dart)는 roomId만
  /// 사용하므로 영향이 크지 않습니다.
  Future<GameRoom> rankedMatch(int playerCount) async {
    final res = await _client.post('/matchmaking/$playerCount/ranked');
    ApiClient.ensureOk(res, '랭크 매칭에 실패했습니다.');
    return GameRoom.fromJson(jsonDecode(res.body));
  }
}
