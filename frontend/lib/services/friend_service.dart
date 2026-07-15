// 친구 목록/요청/검색 REST API. backend/Backend/Endpoints/FriendEndpoints.cs를
// 그대로 따릅니다.

import 'dart:convert';
import 'api_client.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/player.dart';

/// POST /friends/requests의 두 가지 응답을 구분해서 표현합니다. 상대가 이미
/// 나에게 요청을 보내둔 상태였다면 서버가 즉시 수락 처리하고 FriendResponse를
/// (본문 모양이 FriendRequestResponse와 다름) 돌려주므로, 호출부가 "요청이
/// 접수됐다"와 "바로 친구가 됐다"를 구분해 반영할 수 있어야 합니다.
sealed class SendFriendRequestResult {
  const SendFriendRequestResult();
}

class FriendRequestSent extends SendFriendRequestResult {
  final FriendRequest request;
  const FriendRequestSent(this.request);
}

class FriendRequestAutoAccepted extends SendFriendRequestResult {
  final Friend friend;
  const FriendRequestAutoAccepted(this.friend);
}

class FriendService {
  final ApiClient _client;

  FriendService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<Friend>> getFriends() async {
    final res = await _client.get('/friends');
    ApiClient.ensureOk(res, '친구 목록을 불러오지 못했습니다.');
    final json = jsonDecode(res.body);
    return (json['friends'] as List)
        .map((e) => Friend.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SendFriendRequestResult> sendRequest(int targetUserId) async {
    final res = await _client.post(
      '/friends/requests',
      body: {'targetUserId': targetUserId},
    );
    ApiClient.ensureOk(res, '친구 요청을 보내지 못했습니다.');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    // 201 Created = 새 대기 요청, 200 OK = 상대의 기존 요청을 즉시 수락(FriendResponse).
    if (res.statusCode == 200) {
      return FriendRequestAutoAccepted(Friend.fromJson(json));
    }
    return FriendRequestSent(FriendRequest.fromJson(json));
  }

  /// GET /friends/requests는 내가 받은(incoming) 요청과 보낸(outgoing) 요청을
  /// 한 응답에 함께 돌려주지만, 현재 화면은 받은 요청만 보여준다.
  Future<List<FriendRequest>> getIncomingRequests() async {
    final res = await _client.get('/friends/requests');
    ApiClient.ensureOk(res, '친구 요청 목록을 불러오지 못했습니다.');
    final json = jsonDecode(res.body);
    return (json['incoming'] as List)
        .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Friend> acceptRequest(int requestId) async {
    final res = await _client.post('/friends/requests/$requestId/accept');
    ApiClient.ensureOk(res, '친구 요청 수락에 실패했습니다.');
    return Friend.fromJson(jsonDecode(res.body));
  }

  /// 받은 요청 거절, 보낸 요청 취소 둘 다 같은 DELETE 엔드포인트를 쓴다.
  Future<void> rejectRequest(int requestId) async {
    final res = await _client.delete('/friends/requests/$requestId');
    ApiClient.ensureOk(res, '친구 요청 처리에 실패했습니다.');
  }

  Future<void> deleteFriend(int friendUserId) async {
    final res = await _client.delete('/friends/$friendUserId');
    ApiClient.ensureOk(res, '친구 삭제에 실패했습니다.');
  }

  /// 친구 추가용 유저 검색. /users/search가 아니라 /friends/search를 쓴다.
  Future<List<Player>> searchCandidates(String query) async {
    final res = await _client.get('/friends/search', query: {'query': query});
    ApiClient.ensureOk(res, '유저 검색에 실패했습니다.');
    final json = jsonDecode(res.body);
    return (json['users'] as List)
        .map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
