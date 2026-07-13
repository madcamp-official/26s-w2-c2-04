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

  test('sendRequest는 POST /friends/requests에 targetUserId를 보낸다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'POST');
      expect(path, '/friends/requests');
      expect(body, {'targetUserId': 2048});
      return http.Response(
        jsonEncode({
          'requestId': 7788,
          'fromUserId': 1024,
          'status': 'PENDING',
          'createdAt': '2026-07-10T09:05:00Z',
        }),
        201,
      );
    });

    final request = await FriendService(client: fake).sendRequest(2048);
    expect(request.requestId, 7788);
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

  test('deleteFriend는 DELETE /friends/{friendUserId}를 호출한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'DELETE');
      expect(path, '/friends/2048');
      return http.Response('', 204);
    });

    await FriendService(client: fake).deleteFriend(2048);
  });
}
