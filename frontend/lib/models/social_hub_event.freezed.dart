// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_hub_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SocialHubEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int requestId, int fromUserId, String fromNickname)
        friendRequestReceived,
    required TResult Function(int friendUserId, String friendNickname)
        friendRequestAccepted,
    required TResult Function(int friendUserId, FriendStatus status)
        friendStatusChanged,
    required TResult Function(int fromUserId, String text, DateTime ts)
        friendMessageReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult? Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult? Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult? Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SocialHubFriendRequestReceived value)
        friendRequestReceived,
    required TResult Function(SocialHubFriendRequestAccepted value)
        friendRequestAccepted,
    required TResult Function(SocialHubFriendStatusChanged value)
        friendStatusChanged,
    required TResult Function(SocialHubFriendMessageReceived value)
        friendMessageReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult? Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult? Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult? Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialHubEventCopyWith<$Res> {
  factory $SocialHubEventCopyWith(
          SocialHubEvent value, $Res Function(SocialHubEvent) then) =
      _$SocialHubEventCopyWithImpl<$Res, SocialHubEvent>;
}

/// @nodoc
class _$SocialHubEventCopyWithImpl<$Res, $Val extends SocialHubEvent>
    implements $SocialHubEventCopyWith<$Res> {
  _$SocialHubEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SocialHubFriendRequestReceivedImplCopyWith<$Res> {
  factory _$$SocialHubFriendRequestReceivedImplCopyWith(
          _$SocialHubFriendRequestReceivedImpl value,
          $Res Function(_$SocialHubFriendRequestReceivedImpl) then) =
      __$$SocialHubFriendRequestReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int requestId, int fromUserId, String fromNickname});
}

/// @nodoc
class __$$SocialHubFriendRequestReceivedImplCopyWithImpl<$Res>
    extends _$SocialHubEventCopyWithImpl<$Res,
        _$SocialHubFriendRequestReceivedImpl>
    implements _$$SocialHubFriendRequestReceivedImplCopyWith<$Res> {
  __$$SocialHubFriendRequestReceivedImplCopyWithImpl(
      _$SocialHubFriendRequestReceivedImpl _value,
      $Res Function(_$SocialHubFriendRequestReceivedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? fromUserId = null,
    Object? fromNickname = null,
  }) {
    return _then(_$SocialHubFriendRequestReceivedImpl(
      requestId: null == requestId
          ? _value.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as int,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as int,
      fromNickname: null == fromNickname
          ? _value.fromNickname
          : fromNickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SocialHubFriendRequestReceivedImpl
    implements SocialHubFriendRequestReceived {
  const _$SocialHubFriendRequestReceivedImpl(
      {required this.requestId,
      required this.fromUserId,
      required this.fromNickname});

  @override
  final int requestId;
  @override
  final int fromUserId;
  @override
  final String fromNickname;

  @override
  String toString() {
    return 'SocialHubEvent.friendRequestReceived(requestId: $requestId, fromUserId: $fromUserId, fromNickname: $fromNickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialHubFriendRequestReceivedImpl &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.fromNickname, fromNickname) ||
                other.fromNickname == fromNickname));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, requestId, fromUserId, fromNickname);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialHubFriendRequestReceivedImplCopyWith<
          _$SocialHubFriendRequestReceivedImpl>
      get copyWith => __$$SocialHubFriendRequestReceivedImplCopyWithImpl<
          _$SocialHubFriendRequestReceivedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int requestId, int fromUserId, String fromNickname)
        friendRequestReceived,
    required TResult Function(int friendUserId, String friendNickname)
        friendRequestAccepted,
    required TResult Function(int friendUserId, FriendStatus status)
        friendStatusChanged,
    required TResult Function(int fromUserId, String text, DateTime ts)
        friendMessageReceived,
  }) {
    return friendRequestReceived(requestId, fromUserId, fromNickname);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult? Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult? Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult? Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
  }) {
    return friendRequestReceived?.call(requestId, fromUserId, fromNickname);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendRequestReceived != null) {
      return friendRequestReceived(requestId, fromUserId, fromNickname);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SocialHubFriendRequestReceived value)
        friendRequestReceived,
    required TResult Function(SocialHubFriendRequestAccepted value)
        friendRequestAccepted,
    required TResult Function(SocialHubFriendStatusChanged value)
        friendStatusChanged,
    required TResult Function(SocialHubFriendMessageReceived value)
        friendMessageReceived,
  }) {
    return friendRequestReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult? Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult? Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult? Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
  }) {
    return friendRequestReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendRequestReceived != null) {
      return friendRequestReceived(this);
    }
    return orElse();
  }
}

abstract class SocialHubFriendRequestReceived implements SocialHubEvent {
  const factory SocialHubFriendRequestReceived(
          {required final int requestId,
          required final int fromUserId,
          required final String fromNickname}) =
      _$SocialHubFriendRequestReceivedImpl;

  int get requestId;
  int get fromUserId;
  String get fromNickname;

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialHubFriendRequestReceivedImplCopyWith<
          _$SocialHubFriendRequestReceivedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SocialHubFriendRequestAcceptedImplCopyWith<$Res> {
  factory _$$SocialHubFriendRequestAcceptedImplCopyWith(
          _$SocialHubFriendRequestAcceptedImpl value,
          $Res Function(_$SocialHubFriendRequestAcceptedImpl) then) =
      __$$SocialHubFriendRequestAcceptedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int friendUserId, String friendNickname});
}

/// @nodoc
class __$$SocialHubFriendRequestAcceptedImplCopyWithImpl<$Res>
    extends _$SocialHubEventCopyWithImpl<$Res,
        _$SocialHubFriendRequestAcceptedImpl>
    implements _$$SocialHubFriendRequestAcceptedImplCopyWith<$Res> {
  __$$SocialHubFriendRequestAcceptedImplCopyWithImpl(
      _$SocialHubFriendRequestAcceptedImpl _value,
      $Res Function(_$SocialHubFriendRequestAcceptedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friendUserId = null,
    Object? friendNickname = null,
  }) {
    return _then(_$SocialHubFriendRequestAcceptedImpl(
      friendUserId: null == friendUserId
          ? _value.friendUserId
          : friendUserId // ignore: cast_nullable_to_non_nullable
              as int,
      friendNickname: null == friendNickname
          ? _value.friendNickname
          : friendNickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SocialHubFriendRequestAcceptedImpl
    implements SocialHubFriendRequestAccepted {
  const _$SocialHubFriendRequestAcceptedImpl(
      {required this.friendUserId, required this.friendNickname});

  @override
  final int friendUserId;
  @override
  final String friendNickname;

  @override
  String toString() {
    return 'SocialHubEvent.friendRequestAccepted(friendUserId: $friendUserId, friendNickname: $friendNickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialHubFriendRequestAcceptedImpl &&
            (identical(other.friendUserId, friendUserId) ||
                other.friendUserId == friendUserId) &&
            (identical(other.friendNickname, friendNickname) ||
                other.friendNickname == friendNickname));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendUserId, friendNickname);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialHubFriendRequestAcceptedImplCopyWith<
          _$SocialHubFriendRequestAcceptedImpl>
      get copyWith => __$$SocialHubFriendRequestAcceptedImplCopyWithImpl<
          _$SocialHubFriendRequestAcceptedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int requestId, int fromUserId, String fromNickname)
        friendRequestReceived,
    required TResult Function(int friendUserId, String friendNickname)
        friendRequestAccepted,
    required TResult Function(int friendUserId, FriendStatus status)
        friendStatusChanged,
    required TResult Function(int fromUserId, String text, DateTime ts)
        friendMessageReceived,
  }) {
    return friendRequestAccepted(friendUserId, friendNickname);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult? Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult? Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult? Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
  }) {
    return friendRequestAccepted?.call(friendUserId, friendNickname);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendRequestAccepted != null) {
      return friendRequestAccepted(friendUserId, friendNickname);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SocialHubFriendRequestReceived value)
        friendRequestReceived,
    required TResult Function(SocialHubFriendRequestAccepted value)
        friendRequestAccepted,
    required TResult Function(SocialHubFriendStatusChanged value)
        friendStatusChanged,
    required TResult Function(SocialHubFriendMessageReceived value)
        friendMessageReceived,
  }) {
    return friendRequestAccepted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult? Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult? Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult? Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
  }) {
    return friendRequestAccepted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendRequestAccepted != null) {
      return friendRequestAccepted(this);
    }
    return orElse();
  }
}

abstract class SocialHubFriendRequestAccepted implements SocialHubEvent {
  const factory SocialHubFriendRequestAccepted(
          {required final int friendUserId,
          required final String friendNickname}) =
      _$SocialHubFriendRequestAcceptedImpl;

  int get friendUserId;
  String get friendNickname;

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialHubFriendRequestAcceptedImplCopyWith<
          _$SocialHubFriendRequestAcceptedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SocialHubFriendStatusChangedImplCopyWith<$Res> {
  factory _$$SocialHubFriendStatusChangedImplCopyWith(
          _$SocialHubFriendStatusChangedImpl value,
          $Res Function(_$SocialHubFriendStatusChangedImpl) then) =
      __$$SocialHubFriendStatusChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int friendUserId, FriendStatus status});
}

/// @nodoc
class __$$SocialHubFriendStatusChangedImplCopyWithImpl<$Res>
    extends _$SocialHubEventCopyWithImpl<$Res,
        _$SocialHubFriendStatusChangedImpl>
    implements _$$SocialHubFriendStatusChangedImplCopyWith<$Res> {
  __$$SocialHubFriendStatusChangedImplCopyWithImpl(
      _$SocialHubFriendStatusChangedImpl _value,
      $Res Function(_$SocialHubFriendStatusChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friendUserId = null,
    Object? status = null,
  }) {
    return _then(_$SocialHubFriendStatusChangedImpl(
      friendUserId: null == friendUserId
          ? _value.friendUserId
          : friendUserId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FriendStatus,
    ));
  }
}

/// @nodoc

class _$SocialHubFriendStatusChangedImpl
    implements SocialHubFriendStatusChanged {
  const _$SocialHubFriendStatusChangedImpl(
      {required this.friendUserId, required this.status});

  @override
  final int friendUserId;
  @override
  final FriendStatus status;

  @override
  String toString() {
    return 'SocialHubEvent.friendStatusChanged(friendUserId: $friendUserId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialHubFriendStatusChangedImpl &&
            (identical(other.friendUserId, friendUserId) ||
                other.friendUserId == friendUserId) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendUserId, status);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialHubFriendStatusChangedImplCopyWith<
          _$SocialHubFriendStatusChangedImpl>
      get copyWith => __$$SocialHubFriendStatusChangedImplCopyWithImpl<
          _$SocialHubFriendStatusChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int requestId, int fromUserId, String fromNickname)
        friendRequestReceived,
    required TResult Function(int friendUserId, String friendNickname)
        friendRequestAccepted,
    required TResult Function(int friendUserId, FriendStatus status)
        friendStatusChanged,
    required TResult Function(int fromUserId, String text, DateTime ts)
        friendMessageReceived,
  }) {
    return friendStatusChanged(friendUserId, status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult? Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult? Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult? Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
  }) {
    return friendStatusChanged?.call(friendUserId, status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendStatusChanged != null) {
      return friendStatusChanged(friendUserId, status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SocialHubFriendRequestReceived value)
        friendRequestReceived,
    required TResult Function(SocialHubFriendRequestAccepted value)
        friendRequestAccepted,
    required TResult Function(SocialHubFriendStatusChanged value)
        friendStatusChanged,
    required TResult Function(SocialHubFriendMessageReceived value)
        friendMessageReceived,
  }) {
    return friendStatusChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult? Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult? Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult? Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
  }) {
    return friendStatusChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendStatusChanged != null) {
      return friendStatusChanged(this);
    }
    return orElse();
  }
}

abstract class SocialHubFriendStatusChanged implements SocialHubEvent {
  const factory SocialHubFriendStatusChanged(
      {required final int friendUserId,
      required final FriendStatus status}) = _$SocialHubFriendStatusChangedImpl;

  int get friendUserId;
  FriendStatus get status;

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialHubFriendStatusChangedImplCopyWith<
          _$SocialHubFriendStatusChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SocialHubFriendMessageReceivedImplCopyWith<$Res> {
  factory _$$SocialHubFriendMessageReceivedImplCopyWith(
          _$SocialHubFriendMessageReceivedImpl value,
          $Res Function(_$SocialHubFriendMessageReceivedImpl) then) =
      __$$SocialHubFriendMessageReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int fromUserId, String text, DateTime ts});
}

/// @nodoc
class __$$SocialHubFriendMessageReceivedImplCopyWithImpl<$Res>
    extends _$SocialHubEventCopyWithImpl<$Res,
        _$SocialHubFriendMessageReceivedImpl>
    implements _$$SocialHubFriendMessageReceivedImplCopyWith<$Res> {
  __$$SocialHubFriendMessageReceivedImplCopyWithImpl(
      _$SocialHubFriendMessageReceivedImpl _value,
      $Res Function(_$SocialHubFriendMessageReceivedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromUserId = null,
    Object? text = null,
    Object? ts = null,
  }) {
    return _then(_$SocialHubFriendMessageReceivedImpl(
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$SocialHubFriendMessageReceivedImpl
    implements SocialHubFriendMessageReceived {
  const _$SocialHubFriendMessageReceivedImpl(
      {required this.fromUserId, required this.text, required this.ts});

  @override
  final int fromUserId;
  @override
  final String text;
  @override
  final DateTime ts;

  @override
  String toString() {
    return 'SocialHubEvent.friendMessageReceived(fromUserId: $fromUserId, text: $text, ts: $ts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialHubFriendMessageReceivedImpl &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.ts, ts) || other.ts == ts));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fromUserId, text, ts);

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialHubFriendMessageReceivedImplCopyWith<
          _$SocialHubFriendMessageReceivedImpl>
      get copyWith => __$$SocialHubFriendMessageReceivedImplCopyWithImpl<
          _$SocialHubFriendMessageReceivedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int requestId, int fromUserId, String fromNickname)
        friendRequestReceived,
    required TResult Function(int friendUserId, String friendNickname)
        friendRequestAccepted,
    required TResult Function(int friendUserId, FriendStatus status)
        friendStatusChanged,
    required TResult Function(int fromUserId, String text, DateTime ts)
        friendMessageReceived,
  }) {
    return friendMessageReceived(fromUserId, text, ts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult? Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult? Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult? Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
  }) {
    return friendMessageReceived?.call(fromUserId, text, ts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int requestId, int fromUserId, String fromNickname)?
        friendRequestReceived,
    TResult Function(int friendUserId, String friendNickname)?
        friendRequestAccepted,
    TResult Function(int friendUserId, FriendStatus status)?
        friendStatusChanged,
    TResult Function(int fromUserId, String text, DateTime ts)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendMessageReceived != null) {
      return friendMessageReceived(fromUserId, text, ts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SocialHubFriendRequestReceived value)
        friendRequestReceived,
    required TResult Function(SocialHubFriendRequestAccepted value)
        friendRequestAccepted,
    required TResult Function(SocialHubFriendStatusChanged value)
        friendStatusChanged,
    required TResult Function(SocialHubFriendMessageReceived value)
        friendMessageReceived,
  }) {
    return friendMessageReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult? Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult? Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult? Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
  }) {
    return friendMessageReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SocialHubFriendRequestReceived value)?
        friendRequestReceived,
    TResult Function(SocialHubFriendRequestAccepted value)?
        friendRequestAccepted,
    TResult Function(SocialHubFriendStatusChanged value)? friendStatusChanged,
    TResult Function(SocialHubFriendMessageReceived value)?
        friendMessageReceived,
    required TResult orElse(),
  }) {
    if (friendMessageReceived != null) {
      return friendMessageReceived(this);
    }
    return orElse();
  }
}

abstract class SocialHubFriendMessageReceived implements SocialHubEvent {
  const factory SocialHubFriendMessageReceived(
      {required final int fromUserId,
      required final String text,
      required final DateTime ts}) = _$SocialHubFriendMessageReceivedImpl;

  int get fromUserId;
  String get text;
  DateTime get ts;

  /// Create a copy of SocialHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialHubFriendMessageReceivedImplCopyWith<
          _$SocialHubFriendMessageReceivedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
