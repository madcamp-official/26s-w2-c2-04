// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FriendMessage _$FriendMessageFromJson(Map<String, dynamic> json) {
  return _FriendMessage.fromJson(json);
}

/// @nodoc
mixin _$FriendMessage {
  int get messageId => throw _privateConstructorUsedError;
  int get senderId => throw _privateConstructorUsedError;
  int get receiverId => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FriendMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendMessageCopyWith<FriendMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendMessageCopyWith<$Res> {
  factory $FriendMessageCopyWith(
          FriendMessage value, $Res Function(FriendMessage) then) =
      _$FriendMessageCopyWithImpl<$Res, FriendMessage>;
  @useResult
  $Res call(
      {int messageId,
      int senderId,
      int receiverId,
      String body,
      DateTime createdAt});
}

/// @nodoc
class _$FriendMessageCopyWithImpl<$Res, $Val extends FriendMessage>
    implements $FriendMessageCopyWith<$Res> {
  _$FriendMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? body = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendMessageImplCopyWith<$Res>
    implements $FriendMessageCopyWith<$Res> {
  factory _$$FriendMessageImplCopyWith(
          _$FriendMessageImpl value, $Res Function(_$FriendMessageImpl) then) =
      __$$FriendMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int messageId,
      int senderId,
      int receiverId,
      String body,
      DateTime createdAt});
}

/// @nodoc
class __$$FriendMessageImplCopyWithImpl<$Res>
    extends _$FriendMessageCopyWithImpl<$Res, _$FriendMessageImpl>
    implements _$$FriendMessageImplCopyWith<$Res> {
  __$$FriendMessageImplCopyWithImpl(
      _$FriendMessageImpl _value, $Res Function(_$FriendMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of FriendMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? body = null,
    Object? createdAt = null,
  }) {
    return _then(_$FriendMessageImpl(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendMessageImpl implements _FriendMessage {
  const _$FriendMessageImpl(
      {required this.messageId,
      required this.senderId,
      required this.receiverId,
      required this.body,
      required this.createdAt});

  factory _$FriendMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendMessageImplFromJson(json);

  @override
  final int messageId;
  @override
  final int senderId;
  @override
  final int receiverId;
  @override
  final String body;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FriendMessage(messageId: $messageId, senderId: $senderId, receiverId: $receiverId, body: $body, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendMessageImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, messageId, senderId, receiverId, body, createdAt);

  /// Create a copy of FriendMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendMessageImplCopyWith<_$FriendMessageImpl> get copyWith =>
      __$$FriendMessageImplCopyWithImpl<_$FriendMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendMessageImplToJson(
      this,
    );
  }
}

abstract class _FriendMessage implements FriendMessage {
  const factory _FriendMessage(
      {required final int messageId,
      required final int senderId,
      required final int receiverId,
      required final String body,
      required final DateTime createdAt}) = _$FriendMessageImpl;

  factory _FriendMessage.fromJson(Map<String, dynamic> json) =
      _$FriendMessageImpl.fromJson;

  @override
  int get messageId;
  @override
  int get senderId;
  @override
  int get receiverId;
  @override
  String get body;
  @override
  DateTime get createdAt;

  /// Create a copy of FriendMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendMessageImplCopyWith<_$FriendMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
