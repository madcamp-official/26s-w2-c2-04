// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendRequestImpl _$$FriendRequestImplFromJson(Map<String, dynamic> json) =>
    _$FriendRequestImpl(
      requestId: (json['requestId'] as num).toInt(),
      fromUserId: (json['fromUserId'] as num).toInt(),
      toUserId: (json['toUserId'] as num?)?.toInt(),
      fromNickname: json['fromNickname'] as String?,
      status:
          $enumDecodeNullable(_$FriendRequestStatusEnumMap, json['status']) ??
              FriendRequestStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FriendRequestImplToJson(_$FriendRequestImpl instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'fromNickname': instance.fromNickname,
      'status': _$FriendRequestStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$FriendRequestStatusEnumMap = {
  FriendRequestStatus.pending: 'PENDING',
  FriendRequestStatus.accepted: 'ACCEPTED',
  FriendRequestStatus.rejected: 'REJECTED',
};
