import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/friend_message_service.dart';
import '../helpers/fake_api_client.dart';

void main() {
  test('getMessages는 GET /friends/{userId}/messages 응답을 파싱한다', () async {
    final fake = FakeApiClient((method, path, {query, body}) {
      expect(method, 'GET');
      expect(path, '/friends/2048/messages');
      return http.Response(
        jsonEncode({
          'messages': [
            {
              'messageId': 1,
              'senderId': 1024,
              'receiverId': 2048,
              'body': '안녕!',
              'createdAt': '2026-07-10T09:05:00Z',
            },
          ],
          'hasMore': false,
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final page = await FriendMessageService(client: fake).getMessages(2048);
    expect(page.messages.single.body, '안녕!');
    expect(page.hasMore, isFalse);
  });
}
