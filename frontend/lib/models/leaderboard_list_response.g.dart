// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardListResponseImpl _$$LeaderboardListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardListResponseImpl(
      playerCount: (json['playerCount'] as num).toInt(),
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      myRank: json['myRank'] == null
          ? null
          : LeaderboardEntry.fromJson(json['myRank'] as Map<String, dynamic>),
      query: json['query'] as String?,
    );

Map<String, dynamic> _$$LeaderboardListResponseImplToJson(
        _$LeaderboardListResponseImpl instance) =>
    <String, dynamic>{
      'playerCount': instance.playerCount,
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'entries': instance.entries,
      'myRank': instance.myRank,
      'query': instance.query,
    };
