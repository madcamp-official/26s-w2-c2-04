// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      rank: (json['rank'] as num).toInt(),
      playerId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      mmr: (json['mmr'] as num).toInt(),
      avgPlace: (json['avgPlace'] as num).toDouble(),
      gamesPlayedSeason: (json['gamesPlayedSeason'] as num).toInt(),
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'userId': instance.playerId,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'mmr': instance.mmr,
      'avgPlace': instance.avgPlace,
      'gamesPlayedSeason': instance.gamesPlayedSeason,
    };
