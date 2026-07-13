// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noble.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NobleImpl _$$NobleImplFromJson(Map<String, dynamic> json) => _$NobleImpl(
      id: json['id'] as String,
      points: (json['points'] as num?)?.toInt() ?? 3,
      requirement: (json['requirement'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$NobleImplToJson(_$NobleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'points': instance.points,
      'requirement': instance.requirement,
    };
