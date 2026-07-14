import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/room_list_response.dart';

void main() {
  test('GET /rooms 응답을 파싱한다', () {
    final json = {
      'rooms': [
        {
          'roomId': 5566,
          'hostId': 1024,
          'maxPlayers': 4,
          'players': [
            {'userId': 1024, 'nickname': '스플랜더왕'},
          ],
          'createdAt': '2026-07-10T09:10:00Z',
        }
      ],
      'total': 1,
      'page': 1,
    };

    final res = RoomListResponse.fromJson(json);

    expect(res.total, 1);
    expect(res.page, 1);
    expect(res.rooms.single.roomId, 5566);
    // 목록 응답에는 status가 없으므로 기본값(waiting)으로 채워져야 합니다.
    expect(res.rooms.single.status.name, 'waiting');
  });
}
