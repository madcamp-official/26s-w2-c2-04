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

  group('RoomService.rankedMatch', () {
    // 백엔드 POST /matchmaking/{playerCount}/ranked는 방을 바로 돌려주지 않고
    // MatchmakingStatusResponse(QUEUED/MATCHED/NOT_QUEUED, roomId는 MATCHED일 때만
    // 채워짐)를 돌려준다. 예전 구현은 이 응답을 곧바로 GameRoom으로 파싱하려다
    // roomId가 null이라 "type 'Null' is not a subtype of type 'num'"으로 항상
    // 실패했다 — 이 테스트는 큐 등록 -> 폴링 -> 매칭 성사 -> 방 조회 흐름을 검증한다.
    test('QUEUED로 폴링하다 MATCHED가 되면 해당 방을 조회해 돌려준다', () async {
      var statusCalls = 0;
      final fake = FakeApiClient((method, path, {query, body}) {
        if (method == 'POST' && path == '/matchmaking/4/ranked') {
          return http.Response(
            jsonEncode({
              'status': 'QUEUED',
              'playerCount': 4,
              'mmr': 1500,
              'searchRange': 100,
              'roomId': null,
            }),
            200,
          );
        }
        if (method == 'GET' && path == '/matchmaking/4/status') {
          statusCalls++;
          final matched = statusCalls >= 2;
          return http.Response(
            jsonEncode({
              'status': matched ? 'MATCHED' : 'QUEUED',
              'playerCount': 4,
              'mmr': matched ? null : 1500,
              'searchRange': matched ? null : 100,
              'roomId': matched ? 777 : null,
            }),
            200,
          );
        }
        if (method == 'GET' && path == '/rooms/777') {
          return http.Response(
            jsonEncode({
              'roomId': 777,
              'hostId': 1024,
              'status': 'PLAYING',
              'maxPlayers': 4,
              'players': [
                {'userId': 1024, 'nickname': '스플랜더왕'}
              ],
              'createdAt': '2026-07-10T09:10:00Z',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        throw StateError('예상치 못한 호출: $method $path');
      });

      final room = await RoomService(client: fake)
          .rankedMatch(4, pollInterval: Duration.zero);

      expect(room.roomId, 777);
      expect(statusCalls, 2);
    });

    test('isCancelled가 true를 반환하면 폴링을 멈추고 예외를 던진다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        if (method == 'POST') {
          return http.Response(
            jsonEncode({
              'status': 'QUEUED',
              'playerCount': 2,
              'mmr': 1500,
              'searchRange': 100,
              'roomId': null,
            }),
            200,
          );
        }
        // 취소 이후에는 status를 다시 조회하지 않아야 한다.
        throw StateError('취소 후에는 status를 호출하면 안 됨: $method $path');
      });

      expect(
        () => RoomService(client: fake).rankedMatch(
          2,
          pollInterval: Duration.zero,
          isCancelled: () => true,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('RoomService.cancelRankedMatch', () {
    test('DELETE /matchmaking/{playerCount}/ranked를 호출한다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(method, 'DELETE');
        expect(path, '/matchmaking/3/ranked');
        return http.Response('', 204);
      });

      await RoomService(client: fake).cancelRankedMatch(3);
    });
  });
}
