// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'noble.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Noble _$NobleFromJson(Map<String, dynamic> json) {
  return _Noble.fromJson(json);
}

/// @nodoc
mixin _$Noble {
  String get id => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  Map<String, int> get requirement => throw _privateConstructorUsedError;

  /// Serializes this Noble to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Noble
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NobleCopyWith<Noble> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NobleCopyWith<$Res> {
  factory $NobleCopyWith(Noble value, $Res Function(Noble) then) =
      _$NobleCopyWithImpl<$Res, Noble>;
  @useResult
  $Res call({String id, int points, Map<String, int> requirement});
}

/// @nodoc
class _$NobleCopyWithImpl<$Res, $Val extends Noble>
    implements $NobleCopyWith<$Res> {
  _$NobleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Noble
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? points = null,
    Object? requirement = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requirement: null == requirement
          ? _value.requirement
          : requirement // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NobleImplCopyWith<$Res> implements $NobleCopyWith<$Res> {
  factory _$$NobleImplCopyWith(
          _$NobleImpl value, $Res Function(_$NobleImpl) then) =
      __$$NobleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int points, Map<String, int> requirement});
}

/// @nodoc
class __$$NobleImplCopyWithImpl<$Res>
    extends _$NobleCopyWithImpl<$Res, _$NobleImpl>
    implements _$$NobleImplCopyWith<$Res> {
  __$$NobleImplCopyWithImpl(
      _$NobleImpl _value, $Res Function(_$NobleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Noble
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? points = null,
    Object? requirement = null,
  }) {
    return _then(_$NobleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requirement: null == requirement
          ? _value._requirement
          : requirement // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NobleImpl implements _Noble {
  const _$NobleImpl(
      {required this.id,
      this.points = 3,
      final Map<String, int> requirement = const {}})
      : _requirement = requirement;

  factory _$NobleImpl.fromJson(Map<String, dynamic> json) =>
      _$$NobleImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final int points;
  final Map<String, int> _requirement;
  @override
  @JsonKey()
  Map<String, int> get requirement {
    if (_requirement is EqualUnmodifiableMapView) return _requirement;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_requirement);
  }

  @override
  String toString() {
    return 'Noble(id: $id, points: $points, requirement: $requirement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NobleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.points, points) || other.points == points) &&
            const DeepCollectionEquality()
                .equals(other._requirement, _requirement));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, points,
      const DeepCollectionEquality().hash(_requirement));

  /// Create a copy of Noble
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NobleImplCopyWith<_$NobleImpl> get copyWith =>
      __$$NobleImplCopyWithImpl<_$NobleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NobleImplToJson(
      this,
    );
  }
}

abstract class _Noble implements Noble {
  const factory _Noble(
      {required final String id,
      final int points,
      final Map<String, int> requirement}) = _$NobleImpl;

  factory _Noble.fromJson(Map<String, dynamic> json) = _$NobleImpl.fromJson;

  @override
  String get id;
  @override
  int get points;
  @override
  Map<String, int> get requirement;

  /// Create a copy of Noble
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NobleImplCopyWith<_$NobleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
