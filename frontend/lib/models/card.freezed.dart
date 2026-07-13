// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SplendorCard _$SplendorCardFromJson(Map<String, dynamic> json) {
  return _SplendorCard.fromJson(json);
}

/// @nodoc
mixin _$SplendorCard {
  String get id => throw _privateConstructorUsedError;
  int get tier => throw _privateConstructorUsedError; // 1 | 2 | 3
  int get points => throw _privateConstructorUsedError;
  String get bonus =>
      throw _privateConstructorUsedError; // 이 카드를 구매하면 얻는 할인 보석 색상 (Gem.name)
  Map<String, int> get cost => throw _privateConstructorUsedError;

  /// Serializes this SplendorCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SplendorCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SplendorCardCopyWith<SplendorCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplendorCardCopyWith<$Res> {
  factory $SplendorCardCopyWith(
          SplendorCard value, $Res Function(SplendorCard) then) =
      _$SplendorCardCopyWithImpl<$Res, SplendorCard>;
  @useResult
  $Res call(
      {String id, int tier, int points, String bonus, Map<String, int> cost});
}

/// @nodoc
class _$SplendorCardCopyWithImpl<$Res, $Val extends SplendorCard>
    implements $SplendorCardCopyWith<$Res> {
  _$SplendorCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SplendorCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tier = null,
    Object? points = null,
    Object? bonus = null,
    Object? cost = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      bonus: null == bonus
          ? _value.bonus
          : bonus // ignore: cast_nullable_to_non_nullable
              as String,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SplendorCardImplCopyWith<$Res>
    implements $SplendorCardCopyWith<$Res> {
  factory _$$SplendorCardImplCopyWith(
          _$SplendorCardImpl value, $Res Function(_$SplendorCardImpl) then) =
      __$$SplendorCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, int tier, int points, String bonus, Map<String, int> cost});
}

/// @nodoc
class __$$SplendorCardImplCopyWithImpl<$Res>
    extends _$SplendorCardCopyWithImpl<$Res, _$SplendorCardImpl>
    implements _$$SplendorCardImplCopyWith<$Res> {
  __$$SplendorCardImplCopyWithImpl(
      _$SplendorCardImpl _value, $Res Function(_$SplendorCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of SplendorCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tier = null,
    Object? points = null,
    Object? bonus = null,
    Object? cost = null,
  }) {
    return _then(_$SplendorCardImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      bonus: null == bonus
          ? _value.bonus
          : bonus // ignore: cast_nullable_to_non_nullable
              as String,
      cost: null == cost
          ? _value._cost
          : cost // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SplendorCardImpl implements _SplendorCard {
  const _$SplendorCardImpl(
      {required this.id,
      required this.tier,
      this.points = 0,
      required this.bonus,
      final Map<String, int> cost = const {}})
      : _cost = cost;

  factory _$SplendorCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$SplendorCardImplFromJson(json);

  @override
  final String id;
  @override
  final int tier;
// 1 | 2 | 3
  @override
  @JsonKey()
  final int points;
  @override
  final String bonus;
// 이 카드를 구매하면 얻는 할인 보석 색상 (Gem.name)
  final Map<String, int> _cost;
// 이 카드를 구매하면 얻는 할인 보석 색상 (Gem.name)
  @override
  @JsonKey()
  Map<String, int> get cost {
    if (_cost is EqualUnmodifiableMapView) return _cost;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cost);
  }

  @override
  String toString() {
    return 'SplendorCard(id: $id, tier: $tier, points: $points, bonus: $bonus, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplendorCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.bonus, bonus) || other.bonus == bonus) &&
            const DeepCollectionEquality().equals(other._cost, _cost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tier, points, bonus,
      const DeepCollectionEquality().hash(_cost));

  /// Create a copy of SplendorCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SplendorCardImplCopyWith<_$SplendorCardImpl> get copyWith =>
      __$$SplendorCardImplCopyWithImpl<_$SplendorCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SplendorCardImplToJson(
      this,
    );
  }
}

abstract class _SplendorCard implements SplendorCard {
  const factory _SplendorCard(
      {required final String id,
      required final int tier,
      final int points,
      required final String bonus,
      final Map<String, int> cost}) = _$SplendorCardImpl;

  factory _SplendorCard.fromJson(Map<String, dynamic> json) =
      _$SplendorCardImpl.fromJson;

  @override
  String get id;
  @override
  int get tier; // 1 | 2 | 3
  @override
  int get points;
  @override
  String get bonus; // 이 카드를 구매하면 얻는 할인 보석 색상 (Gem.name)
  @override
  Map<String, int> get cost;

  /// Create a copy of SplendorCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SplendorCardImplCopyWith<_$SplendorCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
