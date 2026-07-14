// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendImpl _$$FriendImplFromJson(Map<String, dynamic> json) => _$FriendImpl(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      status: $enumDecodeNullable(_$FriendStatusEnumMap, json['status']) ??
          FriendStatus.offline,
    );

Map<String, dynamic> _$$FriendImplToJson(_$FriendImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'status': _$FriendStatusEnumMap[instance.status]!,
    };

const _$FriendStatusEnumMap = {
  FriendStatus.online: 'online',
  FriendStatus.offline: 'offline',
  FriendStatus.inGame: 'in_game',
  FriendStatus.away: 'away',
};
