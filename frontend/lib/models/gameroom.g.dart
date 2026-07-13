// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gameroom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameRoomImpl _$$GameRoomImplFromJson(Map<String, dynamic> json) =>
    _$GameRoomImpl(
      roomId: (json['roomId'] as num).toInt(),
      hostId: (json['hostId'] as num).toInt(),
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 4,
      status: $enumDecodeNullable(_$RoomStatusEnumMap, json['status']) ??
          RoomStatus.waiting,
      isPrivate: json['isPrivate'] as bool? ?? false,
    );

Map<String, dynamic> _$$GameRoomImplToJson(_$GameRoomImpl instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'hostId': instance.hostId,
      'players': instance.players,
      'createdAt': instance.createdAt.toIso8601String(),
      'maxPlayers': instance.maxPlayers,
      'status': _$RoomStatusEnumMap[instance.status]!,
      'isPrivate': instance.isPrivate,
    };

const _$RoomStatusEnumMap = {
  RoomStatus.waiting: 'WAITING',
  RoomStatus.playing: 'PLAYING',
};
