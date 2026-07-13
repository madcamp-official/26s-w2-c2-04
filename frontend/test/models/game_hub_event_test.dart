import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/game_hub_event.dart';

void main() {
  group('parseGameHubEvent', () {
    test('StateSync(full)를 파싱한다', () {
      final event = parseGameHubEvent('StateSync', [
        {
          'type': 'full',
          'state': {
            'gameId': 9911,
            'phase': 'Playing',
            'currentPlayerId': 1024,
            'sequence': 1,
          },
          'patch': null,
          'sequence': 1,
        }
      ]);

      expect(event, isA<GameHubStateSync>());
      final sync = event as GameHubStateSync;
      expect(sync.state?.gameId, 9911);
      expect(sync.patch, isNull);
      expect(sync.sequence, 1);
    });

    test('StateSync(delta)를 파싱한다', () {
      final event = parseGameHubEvent('StateSync', [
        {
          'type': 'delta',
          'state': null,
          'patch': [
            {'op': 'replace', 'path': '/players/1024/tokens/diamond', 'value': 2},
          ],
          'sequence': 129,
        }
      ]);

      final sync = event as GameHubStateSync;
      expect(sync.state, isNull);
      expect(sync.patch!.single['path'], '/players/1024/tokens/diamond');
      expect(sync.sequence, 129);
    });

    test('TurnChanged를 파싱한다', () {
      final event = parseGameHubEvent('TurnChanged', [
        {'currentPlayerId': 2048, 'turnNumber': 4},
      ]);
      final turn = event as GameHubTurnChanged;
      expect(turn.currentPlayerId, 2048);
      expect(turn.turnNumber, 4);
    });

    test('NobleChoiceRequired를 파싱한다', () {
      final event = parseGameHubEvent('NobleChoiceRequired', [
        {
          'playerId': 1024,
          'candidateNobleIds': ['n_04', 'n_07'],
        }
      ]);
      final choice = event as GameHubNobleChoiceRequired;
      expect(choice.candidateNobleIds, ['n_04', 'n_07']);
    });

    test('GameOver를 파싱한다', () {
      final event = parseGameHubEvent('GameOver', [
        {
          'winnerId': 1024,
          'finalScores': [
            {'userId': 1024, 'score': 16},
            {'userId': 2048, 'score': 13},
          ],
          'tieBreakReason': null,
        }
      ]);
      final gameOver = event as GameHubGameOver;
      expect(gameOver.winnerId, 1024);
      expect(gameOver.finalScores, hasLength(2));
      expect(gameOver.finalScores.first.score, 16);
    });

    test('ChatMessage를 파싱한다', () {
      final event = parseGameHubEvent('ChatMessage', [
        {'playerId': 2048, 'text': '안녕하세요!', 'ts': '2026-07-10T09:21:00Z'},
      ]);
      final chat = event as GameHubChatMessage;
      expect(chat.text, '안녕하세요!');
      expect(chat.ts, DateTime.parse('2026-07-10T09:21:00Z'));
    });

    test('ErrorOccurred를 파싱한다', () {
      final event = parseGameHubEvent('ErrorOccurred', [
        {'code': 'NOT_YOUR_TURN', 'message': '현재 당신의 턴이 아닙니다.'},
      ]);
      final error = event as GameHubErrorOccurred;
      expect(error.code, 'NOT_YOUR_TURN');
    });

    test('알 수 없는 이벤트는 errorOccurred(UNKNOWN_EVENT)로 대체된다', () {
      final event = parseGameHubEvent('SomeFutureEvent', [{}]);
      final error = event as GameHubErrorOccurred;
      expect(error.code, 'UNKNOWN_EVENT');
    });
  });
}
