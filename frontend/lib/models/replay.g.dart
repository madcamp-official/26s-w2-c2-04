// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReplayActionImpl _$$ReplayActionImplFromJson(Map<String, dynamic> json) =>
    _$ReplayActionImpl(
      turnNumber: (json['turnNumber'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      actionType: json['actionType'] as String,
      actionPayload: json['actionPayload'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ReplayActionImplToJson(_$ReplayActionImpl instance) =>
    <String, dynamic>{
      'turnNumber': instance.turnNumber,
      'playerId': instance.playerId,
      'actionType': instance.actionType,
      'actionPayload': instance.actionPayload,
    };

_$ReplayResponseImpl _$$ReplayResponseImplFromJson(Map<String, dynamic> json) =>
    _$ReplayResponseImpl(
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => ReplayAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      actionsTotal: (json['actionsTotal'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ReplayResponseImplToJson(
        _$ReplayResponseImpl instance) =>
    <String, dynamic>{
      'actions': instance.actions,
      'actionsTotal': instance.actionsTotal,
    };
