// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoardTierImpl _$$BoardTierImplFromJson(Map<String, dynamic> json) =>
    _$BoardTierImpl(
      tier: (json['tier'] as num).toInt(),
      visibleCards: (json['visibleCards'] as List<dynamic>?)
              ?.map((e) => SplendorCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      deckRemaining: (json['deckRemaining'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BoardTierImplToJson(_$BoardTierImpl instance) =>
    <String, dynamic>{
      'tier': instance.tier,
      'visibleCards': instance.visibleCards,
      'deckRemaining': instance.deckRemaining,
    };

_$GamePlayerStateImpl _$$GamePlayerStateImplFromJson(
        Map<String, dynamic> json) =>
    _$GamePlayerStateImpl(
      userId: (json['userId'] as num).toInt(),
      tokens: (json['tokens'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      bonuses: (json['bonuses'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      reservedCards: (json['reservedCards'] as List<dynamic>?)
              ?.map((e) => SplendorCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      purchasedCards: (json['purchasedCards'] as List<dynamic>?)
              ?.map((e) => SplendorCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nobles: (json['nobles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      points: (json['points'] as num?)?.toInt() ?? 0,
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$GamePlayerStateImplToJson(
        _$GamePlayerStateImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'tokens': instance.tokens,
      'bonuses': instance.bonuses,
      'reservedCards': instance.reservedCards,
      'purchasedCards': instance.purchasedCards,
      'nobles': instance.nobles,
      'points': instance.points,
      'totalTokens': instance.totalTokens,
    };

_$GameStateImpl _$$GameStateImplFromJson(Map<String, dynamic> json) =>
    _$GameStateImpl(
      gameId: (json['gameId'] as num).toInt(),
      playerOrder: (json['playerOrder'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      players: (json['players'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, GamePlayerState.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      tokenBank: (json['tokenBank'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      board: (json['board'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map(
                        (e) => SplendorCard.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      decks: (json['decks'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map(
                        (e) => SplendorCard.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      boardNobles: (json['boardNobles'] as List<dynamic>?)
              ?.map((e) => Noble.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
      turnNumber: (json['turnNumber'] as num?)?.toInt() ?? 1,
      phase: $enumDecode(_$GamePhaseEnumMap, json['phase']),
      lastTurnPlayerId: (json['lastTurnPlayerId'] as num?)?.toInt(),
      sequence: (json['sequence'] as num).toInt(),
      currentPlayerId: (json['currentPlayerId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GameStateImplToJson(_$GameStateImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'playerOrder': instance.playerOrder,
      'players': instance.players,
      'tokenBank': instance.tokenBank,
      'board': instance.board,
      'decks': instance.decks,
      'boardNobles': instance.boardNobles,
      'currentPlayerIndex': instance.currentPlayerIndex,
      'turnNumber': instance.turnNumber,
      'phase': _$GamePhaseEnumMap[instance.phase]!,
      'lastTurnPlayerId': instance.lastTurnPlayerId,
      'sequence': instance.sequence,
      'currentPlayerId': instance.currentPlayerId,
    };

const _$GamePhaseEnumMap = {
  GamePhase.playing: 'Playing',
  GamePhase.finalRound: 'FinalRound',
  GamePhase.finished: 'Finished',
};
