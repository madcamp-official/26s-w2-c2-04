// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RankingSummaryImpl _$$RankingSummaryImplFromJson(Map<String, dynamic> json) =>
    _$RankingSummaryImpl(
      rank: (json['rank'] as num).toInt(),
      mmr: (json['mmr'] as num).toInt(),
      gamesPlayedSeason: (json['gamesPlayedSeason'] as num).toInt(),
      avgPlace: (json['avgPlace'] as num).toDouble(),
    );

Map<String, dynamic> _$$RankingSummaryImplToJson(
        _$RankingSummaryImpl instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'mmr': instance.mmr,
      'gamesPlayedSeason': instance.gamesPlayedSeason,
      'avgPlace': instance.avgPlace,
    };

_$RecentGameImpl _$$RecentGameImplFromJson(Map<String, dynamic> json) =>
    _$RecentGameImpl(
      gameId: (json['gameId'] as num).toInt(),
      playersNumber: (json['playersNumber'] as num).toInt(),
      gameType: json['gameType'] as String,
      place: (json['place'] as num).toInt(),
    );

Map<String, dynamic> _$$RecentGameImplToJson(_$RecentGameImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'playersNumber': instance.playersNumber,
      'gameType': instance.gameType,
      'place': instance.place,
    };

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      recentGames: (json['recentGames'] as List<dynamic>?)
              ?.map((e) => RecentGame.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rankings: (json['rankings'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, RankingSummary.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'recentGames': instance.recentGames,
      'rankings': instance.rankings,
    };
