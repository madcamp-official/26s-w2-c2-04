// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SplendorCardImpl _$$SplendorCardImplFromJson(Map<String, dynamic> json) =>
    _$SplendorCardImpl(
      id: json['id'] as String,
      tier: (json['tier'] as num).toInt(),
      points: (json['points'] as num?)?.toInt() ?? 0,
      bonus: json['bonus'] as String,
      cost: (json['cost'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$SplendorCardImplToJson(_$SplendorCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tier': instance.tier,
      'points': instance.points,
      'bonus': instance.bonus,
      'cost': instance.cost,
    };
