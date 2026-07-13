import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/api_client.dart';
import 'package:splendor_multiplayer/services/room_service.dart';
import '../helpers/fake_api_client.dart';

void main() {
  group('RoomService.createRoom', () {
    test('POST /rooms 응답을 GameRoom으로 파싱한다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(method, 'POST');
        expect(path, '/rooms');
        expect(body, {'maxPlayers': 4, 'isPrivate': false, 'password': null});
        return http.Response(
          jsonEncode({
            'roomId': 5566,
            'hostId': 1024,
            'status': 'WAITING',
            'maxPlayers': 4,
            'players': [
              {'userId': 1024, 'nickname': '스플랜더왕'}
            ],
            'createdAt': '2026-07-10T09:10:00Z',
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final room = await RoomService(client: fake).createRoom();

      expect(room.roomId, 5566);
      expect(room.hostId, 1024);
      expect(room.players.single.nickname, '스플랜더왕');
    });
  });

  group('RoomService.listRooms', () {
    test('GET /rooms 를 page/limit 쿼리와 함께 호출한다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(method, 'GET');
        expect(path, '/rooms');
        expect(query, {'page': '2', 'limit': '10'});
        return http.Response(
          jsonEncode({'rooms': [], 'total': 0, 'page': 2}),
          200,
        );
      });

      final res = await RoomService(client: fake).listRooms(page: 2, limit: 10);

      expect(res.page, 2);
      expect(res.rooms, isEmpty);
    });
  });

  group('RoomService.startGame', () {
    test('POST /rooms/{roomId}/start 응답에서 gameId/phase를 뽑아낸다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(path, '/rooms/5566/start');
        return http.Response(
          jsonEncode({'gameId': 9911, 'phase': 'PLAYING'}),
          200,
        );
      });

      final result = await RoomService(client: fake).startGame(5566);

      expect(result.gameId, 9911);
      expect(result.phase, 'PLAYING');
    });
  });

  group('오류 처리', () {
    test('4xx/5xx 응답이면 ApiException을 던진다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        return http.Response(jsonEncode({'code': 'ROOM_NOT_FOUND'}), 404);
      });

      expect(
        () => RoomService(client: fake).getRoom(999999),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
