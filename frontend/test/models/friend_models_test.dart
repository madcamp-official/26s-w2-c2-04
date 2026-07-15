import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/friend.dart';
import 'package:splendor_multiplayer/models/friend_request.dart';

void main() {
  group('Friend', () {
    test('status 문자열을 FriendStatus로 매핑한다', () {
      expect(
        Friend.fromJson({'userId': 1, 'nickname': 'a', 'status': 'online'}).status,
        FriendStatus.online,
      );
      expect(
        Friend.fromJson({'userId': 2, 'nickname': 'b', 'status': 'in_game'}).status,
        FriendStatus.inGame,
      );
      expect(
        Friend.fromJson({'userId': 3, 'nickname': 'c', 'status': 'away'}).status,
        FriendStatus.away,
      );
    });
  });

  group('FriendRequest', () {
    test('GET/POST /friends/requests 응답(FriendRequestResponse)을 파싱한다', () {
      final request = FriendRequest.fromJson({
        'requestId': 7788,
        'userId': 1024,
        'nickname': '은빛상인',
        'createdAt': '2026-07-10T09:05:00Z',
      });

      expect(request.requestId, 7788);
      expect(request.userId, 1024);
      expect(request.nickname, '은빛상인');
    });
  });
}
