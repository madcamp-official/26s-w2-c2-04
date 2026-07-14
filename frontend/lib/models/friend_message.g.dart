// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendMessageImpl _$$FriendMessageImplFromJson(Map<String, dynamic> json) =>
    _$FriendMessageImpl(
      messageId: (json['messageId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      receiverId: (json['receiverId'] as num).toInt(),
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FriendMessageImplToJson(_$FriendMessageImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'body': instance.body,
      'createdAt': instance.createdAt.toIso8601String(),
    };
