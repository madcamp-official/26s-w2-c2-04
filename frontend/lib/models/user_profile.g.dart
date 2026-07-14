// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RankingSummaryImpl _$$RankingSummaryImplFromJson(Map<String, dynamic> json) =>
    _$RankingSummaryImpl(
      playerCount: (json['playerCount'] as num).toInt(),
      rank: (json['rank'] as num).toInt(),
      mmr: (json['mmr'] as num).toInt(),
      gamesPlayed: (json['gamesPlayed'] as num).toInt(),
      avgPlace: (json['avgPlace'] as num).toDouble(),
    );

Map<String, dynamic> _$$RankingSummaryImplToJson(
        _$RankingSummaryImpl instance) =>
    <String, dynamic>{
      'playerCount': instance.playerCount,
      'rank': instance.rank,
      'mmr': instance.mmr,
      'gamesPlayed': instance.gamesPlayed,
      'avgPlace': instance.avgPlace,
    };

_$RecentMatchImpl _$$RecentMatchImplFromJson(Map<String, dynamic> json) =>
    _$RecentMatchImpl(
      gameId: (json['gameId'] as num).toInt(),
      playerCount: (json['playerCount'] as num).toInt(),
      place: (json['place'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      isRanked: json['isRanked'] as bool,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );

Map<String, dynamic> _$$RecentMatchImplToJson(_$RecentMatchImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'playerCount': instance.playerCount,
      'place': instance.place,
      'score': instance.score,
      'isRanked': instance.isRanked,
      'playedAt': instance.playedAt.toIso8601String(),
    };

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      totalGamesPlayed: (json['totalGamesPlayed'] as num?)?.toInt() ?? 0,
      overallAvgPlace: (json['overallAvgPlace'] as num?)?.toDouble() ?? 0,
      rankings: (json['rankings'] as List<dynamic>?)
              ?.map((e) => RankingSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentMatches: (json['recentMatches'] as List<dynamic>?)
              ?.map((e) => RecentMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'totalGamesPlayed': instance.totalGamesPlayed,
      'overallAvgPlace': instance.overallAvgPlace,
      'rankings': instance.rankings,
      'recentMatches': instance.recentMatches,
    };
