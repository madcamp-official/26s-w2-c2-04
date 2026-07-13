import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/friend.dart';
import 'package:splendor_multiplayer/models/social_hub_event.dart';

void main() {
  test('FriendRequestReceived을 파싱한다', () {
    final event = parseSocialHubEvent('FriendRequestReceived', [
      {'requestId': 7788, 'fromUserId': 2048, 'fromNickname': '김도현'},
    ]);
    final received = event as SocialHubFriendRequestReceived;
    expect(received.requestId, 7788);
    expect(received.fromNickname, '김도현');
  });

  test('FriendStatusChanged을 파싱한다', () {
    final event = parseSocialHubEvent('FriendStatusChanged', [
      {'friendUserId': 2048, 'status': 'in_game'},
    ]);
    final changed = event as SocialHubFriendStatusChanged;
    expect(changed.status, FriendStatus.inGame);
  });

  test('FriendMessageReceived을 파싱한다', () {
    final event = parseSocialHubEvent('FriendMessageReceived', [
      {'fromUserId': 2048, 'text': '오늘 한 판 할래?', 'ts': '2026-07-10T09:22:00Z'},
    ]);
    final message = event as SocialHubFriendMessageReceived;
    expect(message.text, '오늘 한 판 할래?');
  });

  test('알 수 없는 메서드는 null을 반환한다', () {
    expect(parseSocialHubEvent('SomeFutureEvent', [{}]), isNull);
  });
}
