import 'package:flutter_test/flutter_test.dart';
import 'package:json_patch/json_patch.dart';
import 'package:splendor_multiplayer/models/game_state.dart';

void main() {
  // 실제 백엔드(backend/Backend/Game/GameState.cs, GameHub.BuildFullSync)가 내려주는
  // StateSync(full)의 state 필드 구조를 그대로 반영한 샘플입니다.
  final sampleJson = {
    'gameId': 9911,
    'playerOrder': [1024, 2048],
    'phase': 'Playing',
    'currentPlayerId': 1024,
    'currentPlayerIndex': 0,
    'sequence': 42,
    'turnNumber': 5,
    'lastTurnPlayerId': null,
    'players': {
      '1024': {
        'userId': 1024,
        'points': 3,
        'totalTokens': 2,
        'tokens': {'Diamond': 1, 'Gold': 1},
        'bonuses': {'Diamond': 2},
        'reservedCards': [],
        'purchasedCards': [
          {
            'id': 'c_301',
            'tier': 1,
            'points': 0,
            'bonus': 'Diamond',
            'cost': {'Diamond': 1, 'Sapphire': 1},
          },
        ],
        'nobles': [],
      },
    },
    'board': {
      '1': [
        {
          'id': 'c_302',
          'tier': 1,
          'points': 1,
          'bonus': 'Ruby',
          'cost': {'Ruby': 3},
        },
      ],
    },
    'decks': {
      '1': List.generate(
        29,
        (i) => {
          'id': 'c_deck_$i',
          'tier': 1,
          'points': 0,
          'bonus': 'Ruby',
          'cost': {'Ruby': 1},
        },
      ),
    },
    'tokenBank': {'Diamond': 4, 'Sapphire': 4, 'Gold': 5},
    'boardNobles': [
      {
        'id': 'n_04',
        'points': 3,
        'requirement': {'Diamond': 3, 'Sapphire': 3},
      },
    ],
  };

  test('GameState.fromJson이 실제 백엔드 StateSync 구조를 파싱한다', () {
    final state = GameState.fromJson(sampleJson);

    expect(state.gameId, 9911);
    expect(state.phase, GamePhase.playing);
    expect(state.currentPlayerId, 1024);
    expect(state.sequence, 42);
    expect(state.players['1024']?.points, 3);
    expect(state.players['1024']?.tokens['Diamond'], 1);
    expect(state.players['1024']?.purchasedCards.single.id, 'c_301');
    expect(state.boardTiers.first.visibleCards.single.bonus, 'Ruby');
    expect(state.boardTiers.first.deckRemaining, 29);
    expect(state.boardNobles.single.requirement['Sapphire'], 3);
    expect(state.playerById(1024)?.points, 3);
    expect(state.playerById(999999), isNull);
    expect(state.playersInOrder.single.userId, 1024);
  });

  test('Playing/FinalRound/Finished phase가 올바르게 매핑된다', () {
    for (final entry in {
      'Playing': GamePhase.playing,
      'FinalRound': GamePhase.finalRound,
      'Finished': GamePhase.finished,
    }.entries) {
      final json = {...sampleJson, 'phase': entry.key};
      expect(GameState.fromJson(json).phase, entry.value);
    }
  });

  test('StateSync delta(JSON Patch)를 적용하면 해당 필드만 바뀐다', () {
    final state = GameState.fromJson(sampleJson);
    final raw = state.toJson();

    final patch = [
      {'op': 'replace', 'path': '/players/1024/tokens/Diamond', 'value': 2},
      {'op': 'replace', 'path': '/players/1024/points', 'value': 5},
      {'op': 'replace', 'path': '/sequence', 'value': 43},
    ];

    final patched =
        JsonPatch.apply(raw, patch, strict: false) as Map<String, dynamic>;
    final newState = GameState.fromJson(patched);

    expect(newState.players['1024']?.tokens['Diamond'], 2);
    expect(newState.players['1024']?.points, 5);
    expect(newState.sequence, 43);
    // 패치와 무관한 필드는 그대로 유지됩니다.
    expect(newState.gameId, 9911);
    expect(newState.boardTiers.first.deckRemaining, 29);
  });
}
