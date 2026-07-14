// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replay.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReplayAction _$ReplayActionFromJson(Map<String, dynamic> json) {
  return _ReplayAction.fromJson(json);
}

/// @nodoc
mixin _$ReplayAction {
  int get turnNumber => throw _privateConstructorUsedError;
  int get playerId => throw _privateConstructorUsedError;
  String get actionType =>
      throw _privateConstructorUsedError; // 예: TAKE_TOKENS, PURCHASE_CARD, RESERVE_CARD ...
  Map<String, dynamic> get actionPayload => throw _privateConstructorUsedError;

  /// Serializes this ReplayAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReplayAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplayActionCopyWith<ReplayAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplayActionCopyWith<$Res> {
  factory $ReplayActionCopyWith(
          ReplayAction value, $Res Function(ReplayAction) then) =
      _$ReplayActionCopyWithImpl<$Res, ReplayAction>;
  @useResult
  $Res call(
      {int turnNumber,
      int playerId,
      String actionType,
      Map<String, dynamic> actionPayload});
}

/// @nodoc
class _$ReplayActionCopyWithImpl<$Res, $Val extends ReplayAction>
    implements $ReplayActionCopyWith<$Res> {
  _$ReplayActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplayAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnNumber = null,
    Object? playerId = null,
    Object? actionType = null,
    Object? actionPayload = null,
  }) {
    return _then(_value.copyWith(
      turnNumber: null == turnNumber
          ? _value.turnNumber
          : turnNumber // ignore: cast_nullable_to_non_nullable
              as int,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as int,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      actionPayload: null == actionPayload
          ? _value.actionPayload
          : actionPayload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReplayActionImplCopyWith<$Res>
    implements $ReplayActionCopyWith<$Res> {
  factory _$$ReplayActionImplCopyWith(
          _$ReplayActionImpl value, $Res Function(_$ReplayActionImpl) then) =
      __$$ReplayActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int turnNumber,
      int playerId,
      String actionType,
      Map<String, dynamic> actionPayload});
}

/// @nodoc
class __$$ReplayActionImplCopyWithImpl<$Res>
    extends _$ReplayActionCopyWithImpl<$Res, _$ReplayActionImpl>
    implements _$$ReplayActionImplCopyWith<$Res> {
  __$$ReplayActionImplCopyWithImpl(
      _$ReplayActionImpl _value, $Res Function(_$ReplayActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReplayAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnNumber = null,
    Object? playerId = null,
    Object? actionType = null,
    Object? actionPayload = null,
  }) {
    return _then(_$ReplayActionImpl(
      turnNumber: null == turnNumber
          ? _value.turnNumber
          : turnNumber // ignore: cast_nullable_to_non_nullable
              as int,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as int,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      actionPayload: null == actionPayload
          ? _value._actionPayload
          : actionPayload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplayActionImpl implements _ReplayAction {
  const _$ReplayActionImpl(
      {required this.turnNumber,
      required this.playerId,
      required this.actionType,
      final Map<String, dynamic> actionPayload = const {}})
      : _actionPayload = actionPayload;

  factory _$ReplayActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplayActionImplFromJson(json);

  @override
  final int turnNumber;
  @override
  final int playerId;
  @override
  final String actionType;
// 예: TAKE_TOKENS, PURCHASE_CARD, RESERVE_CARD ...
  final Map<String, dynamic> _actionPayload;
// 예: TAKE_TOKENS, PURCHASE_CARD, RESERVE_CARD ...
  @override
  @JsonKey()
  Map<String, dynamic> get actionPayload {
    if (_actionPayload is EqualUnmodifiableMapView) return _actionPayload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_actionPayload);
  }

  @override
  String toString() {
    return 'ReplayAction(turnNumber: $turnNumber, playerId: $playerId, actionType: $actionType, actionPayload: $actionPayload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplayActionImpl &&
            (identical(other.turnNumber, turnNumber) ||
                other.turnNumber == turnNumber) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            const DeepCollectionEquality()
                .equals(other._actionPayload, _actionPayload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, turnNumber, playerId, actionType,
      const DeepCollectionEquality().hash(_actionPayload));

  /// Create a copy of ReplayAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplayActionImplCopyWith<_$ReplayActionImpl> get copyWith =>
      __$$ReplayActionImplCopyWithImpl<_$ReplayActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplayActionImplToJson(
      this,
    );
  }
}

abstract class _ReplayAction implements ReplayAction {
  const factory _ReplayAction(
      {required final int turnNumber,
      required final int playerId,
      required final String actionType,
      final Map<String, dynamic> actionPayload}) = _$ReplayActionImpl;

  factory _ReplayAction.fromJson(Map<String, dynamic> json) =
      _$ReplayActionImpl.fromJson;

  @override
  int get turnNumber;
  @override
  int get playerId;
  @override
  String get actionType; // 예: TAKE_TOKENS, PURCHASE_CARD, RESERVE_CARD ...
  @override
  Map<String, dynamic> get actionPayload;

  /// Create a copy of ReplayAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplayActionImplCopyWith<_$ReplayActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplayResponse _$ReplayResponseFromJson(Map<String, dynamic> json) {
  return _ReplayResponse.fromJson(json);
}

/// @nodoc
mixin _$ReplayResponse {
  List<ReplayAction> get actions => throw _privateConstructorUsedError;
  int get actionsTotal => throw _privateConstructorUsedError;

  /// Serializes this ReplayResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReplayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplayResponseCopyWith<ReplayResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplayResponseCopyWith<$Res> {
  factory $ReplayResponseCopyWith(
          ReplayResponse value, $Res Function(ReplayResponse) then) =
      _$ReplayResponseCopyWithImpl<$Res, ReplayResponse>;
  @useResult
  $Res call({List<ReplayAction> actions, int actionsTotal});
}

/// @nodoc
class _$ReplayResponseCopyWithImpl<$Res, $Val extends ReplayResponse>
    implements $ReplayResponseCopyWith<$Res> {
  _$ReplayResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actions = null,
    Object? actionsTotal = null,
  }) {
    return _then(_value.copyWith(
      actions: null == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<ReplayAction>,
      actionsTotal: null == actionsTotal
          ? _value.actionsTotal
          : actionsTotal // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReplayResponseImplCopyWith<$Res>
    implements $ReplayResponseCopyWith<$Res> {
  factory _$$ReplayResponseImplCopyWith(_$ReplayResponseImpl value,
          $Res Function(_$ReplayResponseImpl) then) =
      __$$ReplayResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ReplayAction> actions, int actionsTotal});
}

/// @nodoc
class __$$ReplayResponseImplCopyWithImpl<$Res>
    extends _$ReplayResponseCopyWithImpl<$Res, _$ReplayResponseImpl>
    implements _$$ReplayResponseImplCopyWith<$Res> {
  __$$ReplayResponseImplCopyWithImpl(
      _$ReplayResponseImpl _value, $Res Function(_$ReplayResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReplayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actions = null,
    Object? actionsTotal = null,
  }) {
    return _then(_$ReplayResponseImpl(
      actions: null == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<ReplayAction>,
      actionsTotal: null == actionsTotal
          ? _value.actionsTotal
          : actionsTotal // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplayResponseImpl implements _ReplayResponse {
  const _$ReplayResponseImpl(
      {final List<ReplayAction> actions = const [], this.actionsTotal = 0})
      : _actions = actions;

  factory _$ReplayResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplayResponseImplFromJson(json);

  final List<ReplayAction> _actions;
  @override
  @JsonKey()
  List<ReplayAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  @JsonKey()
  final int actionsTotal;

  @override
  String toString() {
    return 'ReplayResponse(actions: $actions, actionsTotal: $actionsTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplayResponseImpl &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.actionsTotal, actionsTotal) ||
                other.actionsTotal == actionsTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_actions), actionsTotal);

  /// Create a copy of ReplayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplayResponseImplCopyWith<_$ReplayResponseImpl> get copyWith =>
      __$$ReplayResponseImplCopyWithImpl<_$ReplayResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplayResponseImplToJson(
      this,
    );
  }
}

abstract class _ReplayResponse implements ReplayResponse {
  const factory _ReplayResponse(
      {final List<ReplayAction> actions,
      final int actionsTotal}) = _$ReplayResponseImpl;

  factory _ReplayResponse.fromJson(Map<String, dynamic> json) =
      _$ReplayResponseImpl.fromJson;

  @override
  List<ReplayAction> get actions;
  @override
  int get actionsTotal;

  /// Create a copy of ReplayResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplayResponseImplCopyWith<_$ReplayResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
