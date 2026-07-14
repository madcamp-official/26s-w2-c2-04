// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
      id: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String?,
      isReady: json['isReady'] as bool? ?? false,
      isHost: json['isHost'] as bool? ?? false,
    );

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'userId': instance.id,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'status': instance.status,
      'isReady': instance.isReady,
      'isHost': instance.isHost,
    };
