// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomListUpdatedImpl _$$RoomListUpdatedImplFromJson(
        Map<String, dynamic> json) =>
    _$RoomListUpdatedImpl(
      rooms: (json['rooms'] as List<dynamic>)
          .map((e) => GameRoom.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$RoomListUpdatedImplToJson(
        _$RoomListUpdatedImpl instance) =>
    <String, dynamic>{
      'rooms': instance.rooms,
      'runtimeType': instance.$type,
    };

_$RoomUpdatedImpl _$$RoomUpdatedImplFromJson(Map<String, dynamic> json) =>
    _$RoomUpdatedImpl(
      room: GameRoom.fromJson(json['room'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$RoomUpdatedImplToJson(_$RoomUpdatedImpl instance) =>
    <String, dynamic>{
      'room': instance.room,
      'runtimeType': instance.$type,
    };

_$JoinRoomImpl _$$JoinRoomImplFromJson(Map<String, dynamic> json) =>
    _$JoinRoomImpl(
      roomId: json['roomId'] as String,
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$JoinRoomImplToJson(_$JoinRoomImpl instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'player': instance.player,
      'runtimeType': instance.$type,
    };

_$ToggleReadyImpl _$$ToggleReadyImplFromJson(Map<String, dynamic> json) =>
    _$ToggleReadyImpl(
      roomId: json['roomId'] as String,
      playerId: json['playerId'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ToggleReadyImplToJson(_$ToggleReadyImpl instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'playerId': instance.playerId,
      'runtimeType': instance.$type,
    };

_$GameEventErrorImpl _$$GameEventErrorImplFromJson(Map<String, dynamic> json) =>
    _$GameEventErrorImpl(
      message: json['message'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$GameEventErrorImplToJson(
        _$GameEventErrorImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'runtimeType': instance.$type,
    };
