import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/friend_service.dart';
import '../helpers/fake_api_client.dart';

void main() {
  test('getFriends는 GET /friends 응답을 파싱한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(path, '/friends');
      return http.Response(
        jsonEncode({
          'friends': [
            {'userId': 2048, 'nickname': '김도현', 'status': 'online'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final friends = await FriendService(client: fake).getFriends();
    expect(friends.single.nickname, '김도현');
  });

  test('sendRequest는 POST /friends/requests에 targetUserId를 보내고, 201이면 새 요청으로 파싱한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'POST');
      expect(path, '/friends/requests');
      expect(body, {'targetUserId': 2048});
      return http.Response(
        jsonEncode({
          'requestId': 7788,
          'userId': 2048,
          'nickname': '김도현',
          'createdAt': '2026-07-10T09:05:00Z',
        }),
        201,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final result = await FriendService(client: fake).sendRequest(2048);
    expect(result, isA<FriendRequestSent>());
    expect((result as FriendRequestSent).request.requestId, 7788);
  });

  test('sendRequest는 상대가 이미 요청을 보내둔 상태(200)면 즉시 수락된 친구로 파싱한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      return http.Response(
        jsonEncode({'userId': 2048, 'nickname': '김도현', 'status': 'offline'}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final result = await FriendService(client: fake).sendRequest(2048);
    expect(result, isA<FriendRequestAutoAccepted>());
    expect((result as FriendRequestAutoAccepted).friend.userId, 2048);
  });

  test('acceptRequest는 POST /friends/requests/{id}/accept를 호출해 Friend를 반환한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(path, '/friends/requests/7788/accept');
      return http.Response(
        jsonEncode({'userId': 2048, 'nickname': '김도현', 'status': 'online'}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final friend = await FriendService(client: fake).acceptRequest(7788);
    expect(friend.userId, 2048);
  });

  test('rejectRequest는 DELETE /friends/requests/{id}를 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'DELETE');
      expect(path, '/friends/requests/7788');
      return http.Response('', 204);
    });

    await FriendService(client: fake).rejectRequest(7788);
  });

  test('deleteFriend는 DELETE /friends/{friendUserId}를 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'DELETE');
      expect(path, '/friends/2048');
      return http.Response('', 204);
    });

    await FriendService(client: fake).deleteFriend(2048);
  });

  test('searchCandidates는 GET /friends/search를 query 쿼리와 함께 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(path, '/friends/search');
      expect(query, {'query': '스플랜더'});
      return http.Response(
        jsonEncode({
          'users': [
            {'userId': 2048, 'nickname': '스플랜더고수'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final results = await FriendService(client: fake).searchCandidates('스플랜더');
    expect(results.single.nickname, '스플랜더고수');
  });
}
