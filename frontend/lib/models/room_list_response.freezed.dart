// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoomListResponse _$RoomListResponseFromJson(Map<String, dynamic> json) {
  return _RoomListResponse.fromJson(json);
}

/// @nodoc
mixin _$RoomListResponse {
  List<GameRoom> get rooms => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;

  /// Serializes this RoomListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomListResponseCopyWith<RoomListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomListResponseCopyWith<$Res> {
  factory $RoomListResponseCopyWith(
          RoomListResponse value, $Res Function(RoomListResponse) then) =
      _$RoomListResponseCopyWithImpl<$Res, RoomListResponse>;
  @useResult
  $Res call({List<GameRoom> rooms, int total, int page});
}

/// @nodoc
class _$RoomListResponseCopyWithImpl<$Res, $Val extends RoomListResponse>
    implements $RoomListResponseCopyWith<$Res> {
  _$RoomListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rooms = null,
    Object? total = null,
    Object? page = null,
  }) {
    return _then(_value.copyWith(
      rooms: null == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as List<GameRoom>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomListResponseImplCopyWith<$Res>
    implements $RoomListResponseCopyWith<$Res> {
  factory _$$RoomListResponseImplCopyWith(_$RoomListResponseImpl value,
          $Res Function(_$RoomListResponseImpl) then) =
      __$$RoomListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<GameRoom> rooms, int total, int page});
}

/// @nodoc
class __$$RoomListResponseImplCopyWithImpl<$Res>
    extends _$RoomListResponseCopyWithImpl<$Res, _$RoomListResponseImpl>
    implements _$$RoomListResponseImplCopyWith<$Res> {
  __$$RoomListResponseImplCopyWithImpl(_$RoomListResponseImpl _value,
      $Res Function(_$RoomListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rooms = null,
    Object? total = null,
    Object? page = null,
  }) {
    return _then(_$RoomListResponseImpl(
      rooms: null == rooms
          ? _value._rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as List<GameRoom>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomListResponseImpl implements _RoomListResponse {
  const _$RoomListResponseImpl(
      {final List<GameRoom> rooms = const [], this.total = 0, this.page = 1})
      : _rooms = rooms;

  factory _$RoomListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomListResponseImplFromJson(json);

  final List<GameRoom> _rooms;
  @override
  @JsonKey()
  List<GameRoom> get rooms {
    if (_rooms is EqualUnmodifiableListView) return _rooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rooms);
  }

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int page;

  @override
  String toString() {
    return 'RoomListResponse(rooms: $rooms, total: $total, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomListResponseImpl &&
            const DeepCollectionEquality().equals(other._rooms, _rooms) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_rooms), total, page);

  /// Create a copy of RoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomListResponseImplCopyWith<_$RoomListResponseImpl> get copyWith =>
      __$$RoomListResponseImplCopyWithImpl<_$RoomListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomListResponseImplToJson(
      this,
    );
  }
}

abstract class _RoomListResponse implements RoomListResponse {
  const factory _RoomListResponse(
      {final List<GameRoom> rooms,
      final int total,
      final int page}) = _$RoomListResponseImpl;

  factory _RoomListResponse.fromJson(Map<String, dynamic> json) =
      _$RoomListResponseImpl.fromJson;

  @override
  List<GameRoom> get rooms;
  @override
  int get total;
  @override
  int get page;

  /// Create a copy of RoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomListResponseImplCopyWith<_$RoomListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
