// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Friend _$FriendFromJson(Map<String, dynamic> json) {
  return _Friend.fromJson(json);
}

/// @nodoc
mixin _$Friend {
  int get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  FriendStatus get status => throw _privateConstructorUsedError;

  /// Serializes this Friend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendCopyWith<Friend> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendCopyWith<$Res> {
  factory $FriendCopyWith(Friend value, $Res Function(Friend) then) =
      _$FriendCopyWithImpl<$Res, Friend>;
  @useResult
  $Res call(
      {int userId, String nickname, String? avatarUrl, FriendStatus status});
}

/// @nodoc
class _$FriendCopyWithImpl<$Res, $Val extends Friend>
    implements $FriendCopyWith<$Res> {
  _$FriendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendImplCopyWith<$Res> implements $FriendCopyWith<$Res> {
  factory _$$FriendImplCopyWith(
          _$FriendImpl value, $Res Function(_$FriendImpl) then) =
      __$$FriendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int userId, String nickname, String? avatarUrl, FriendStatus status});
}

/// @nodoc
class __$$FriendImplCopyWithImpl<$Res>
    extends _$FriendCopyWithImpl<$Res, _$FriendImpl>
    implements _$$FriendImplCopyWith<$Res> {
  __$$FriendImplCopyWithImpl(
      _$FriendImpl _value, $Res Function(_$FriendImpl) _then)
      : super(_value, _then);

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? status = null,
  }) {
    return _then(_$FriendImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendImpl implements _Friend {
  const _$FriendImpl(
      {required this.userId,
      required this.nickname,
      this.avatarUrl,
      this.status = FriendStatus.offline});

  factory _$FriendImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendImplFromJson(json);

  @override
  final int userId;
  @override
  final String nickname;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final FriendStatus status;

  @override
  String toString() {
    return 'Friend(userId: $userId, nickname: $nickname, avatarUrl: $avatarUrl, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, nickname, avatarUrl, status);

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendImplCopyWith<_$FriendImpl> get copyWith =>
      __$$FriendImplCopyWithImpl<_$FriendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendImplToJson(
      this,
    );
  }
}

abstract class _Friend implements Friend {
  const factory _Friend(
      {required final int userId,
      required final String nickname,
      final String? avatarUrl,
      final FriendStatus status}) = _$FriendImpl;

  factory _Friend.fromJson(Map<String, dynamic> json) = _$FriendImpl.fromJson;

  @override
  int get userId;
  @override
  String get nickname;
  @override
  String? get avatarUrl;
  @override
  FriendStatus get status;

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendImplCopyWith<_$FriendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
