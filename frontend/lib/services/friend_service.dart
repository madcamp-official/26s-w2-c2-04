// 친구 목록/요청/삭제 REST API. README 3절 스펙을 따르며, 백엔드에는 아직
// 이 엔드포인트들이 없습니다(구현되면 경로/필드만 맞추면 됩니다).

import 'dart:convert';
import 'api_client.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';

class FriendService {
  final ApiClient _client;

  FriendService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<Friend>> getFriends({FriendStatus? status}) async {
    final res = await _client.get(
      '/friends',
      query: status == null ? null : {'status': _statusWire(status)},
    );
    ApiClient.ensureOk(res, '친구 목록을 불러오지 못했습니다.');
    final json = jsonDecode(res.body);
    return (json['friends'] as List)
        .map((e) => Friend.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FriendRequest> sendRequest(int targetUserId) async {
    final res = await _client.post(
      '/friends/requests',
      body: {'targetUserId': targetUserId},
    );
    ApiClient.ensureOk(res, '친구 요청을 보내지 못했습니다.');
    return FriendRequest.fromJson(jsonDecode(res.body));
  }

  /// direction: 'incoming' | 'outgoing'
  Future<List<FriendRequest>> getRequests({String direction = 'incoming'}) async {
    final res = await _client.get('/friends/requests', query: {'direction': direction});
    ApiClient.ensureOk(res, '친구 요청 목록을 불러오지 못했습니다.');
    final json = jsonDecode(res.body);
    return (json['requests'] as List)
        .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Friend> acceptRequest(int requestId) async {
    final res = await _client.post('/friends/requests/$requestId/accept');
    ApiClient.ensureOk(res, '친구 요청 수락에 실패했습니다.');
    return Friend.fromJson(jsonDecode(res.body));
  }

  Future<void> rejectRequest(int requestId) async {
    final res = await _client.post('/friends/requests/$requestId/reject');
    ApiClient.ensureOk(res, '친구 요청 거절에 실패했습니다.');
  }

  Future<void> deleteFriend(int friendUserId) async {
    final res = await _client.delete('/friends/$friendUserId');
    ApiClient.ensureOk(res, '친구 삭제에 실패했습니다.');
  }

  String _statusWire(FriendStatus status) => switch (status) {
        FriendStatus.online => 'online',
        FriendStatus.offline => 'offline',
        FriendStatus.inGame => 'in_game',
        FriendStatus.away => 'away',
      };
}
