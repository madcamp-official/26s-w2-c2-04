// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomListResponseImpl _$$RoomListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RoomListResponseImpl(
      rooms: (json['rooms'] as List<dynamic>?)
              ?.map((e) => GameRoom.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$RoomListResponseImplToJson(
        _$RoomListResponseImpl instance) =>
    <String, dynamic>{
      'rooms': instance.rooms,
      'total': instance.total,
      'page': instance.page,
    };
