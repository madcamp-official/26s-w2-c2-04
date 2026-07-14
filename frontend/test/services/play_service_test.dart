import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/play_service.dart';
import '../helpers/fake_api_client.dart';

void main() {
  group('PlayService.getGameState', () {
    test('GET /games/{gameId}/state 를 GameState로 파싱한다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(path, '/games/9911/state');
        return http.Response(
          jsonEncode({
            'gameId': 9911,
            'phase': 'Playing',
            'currentPlayerId': 1024,
            'sequence': 42,
          }),
          200,
        );
      });

      final state = await PlayService(client: fake).getGameState(9911);

      expect(state.gameId, 9911);
      expect(state.sequence, 42);
    });
  });

  group('PlayService.getReplay', () {
    test('GET /replay/{gameId} 를 ReplayResponse로 파싱한다', () async {
      final fake = FakeApiClient((method, path, {query, body}) {
        expect(path, '/replay/9911');
        return http.Response(
          jsonEncode({
            'actions': [
              {
                'turnNumber': 3,
                'playerId': 1024,
                'actionType': 'TAKE_TOKENS',
                'actionPayload': {
                  'gems': ['diamond', 'sapphire', 'emerald'],
                },
              }
            ],
            'actionsTotal': 48,
          }),
          200,
        );
      });

      final replay = await PlayService(client: fake).getReplay(9911);

      expect(replay.actionsTotal, 48);
      expect(replay.actions.single.actionType, 'TAKE_TOKENS');
    });
  });
}
