// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      userId: (json['userId'] as num).toInt(),
      gamesPlayed: (json['gamesPlayed'] as num).toInt(),
      wins: (json['wins'] as num).toInt(),
      avgScore: (json['avgScore'] as num).toDouble(),
      avgTurns: (json['avgTurns'] as num).toDouble(),
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'gamesPlayed': instance.gamesPlayed,
      'wins': instance.wins,
      'avgScore': instance.avgScore,
      'avgTurns': instance.avgTurns,
    };
