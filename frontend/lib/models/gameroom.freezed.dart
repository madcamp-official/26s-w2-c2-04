// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gameroom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameRoom _$GameRoomFromJson(Map<String, dynamic> json) {
  return _GameRoom.fromJson(json);
}

/// @nodoc
mixin _$GameRoom {
  int get roomId => throw _privateConstructorUsedError;
  int get hostId =>
      throw _privateConstructorUsedError; // 방장 판별용, player.id와 비교해서 사용
  List<Player> get players => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get maxPlayers => throw _privateConstructorUsedError; // 스플렌더는 2~4인
  RoomStatus get status => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;

  /// Serializes this GameRoom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameRoomCopyWith<GameRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameRoomCopyWith<$Res> {
  factory $GameRoomCopyWith(GameRoom value, $Res Function(GameRoom) then) =
      _$GameRoomCopyWithImpl<$Res, GameRoom>;
  @useResult
  $Res call(
      {int roomId,
      int hostId,
      List<Player> players,
      DateTime createdAt,
      int maxPlayers,
      RoomStatus status,
      bool isPrivate});
}

/// @nodoc
class _$GameRoomCopyWithImpl<$Res, $Val extends GameRoom>
    implements $GameRoomCopyWith<$Res> {
  _$GameRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? hostId = null,
    Object? players = null,
    Object? createdAt = null,
    Object? maxPlayers = null,
    Object? status = null,
    Object? isPrivate = null,
  }) {
    return _then(_value.copyWith(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as int,
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameRoomImplCopyWith<$Res>
    implements $GameRoomCopyWith<$Res> {
  factory _$$GameRoomImplCopyWith(
          _$GameRoomImpl value, $Res Function(_$GameRoomImpl) then) =
      __$$GameRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int roomId,
      int hostId,
      List<Player> players,
      DateTime createdAt,
      int maxPlayers,
      RoomStatus status,
      bool isPrivate});
}

/// @nodoc
class __$$GameRoomImplCopyWithImpl<$Res>
    extends _$GameRoomCopyWithImpl<$Res, _$GameRoomImpl>
    implements _$$GameRoomImplCopyWith<$Res> {
  __$$GameRoomImplCopyWithImpl(
      _$GameRoomImpl _value, $Res Function(_$GameRoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? hostId = null,
    Object? players = null,
    Object? createdAt = null,
    Object? maxPlayers = null,
    Object? status = null,
    Object? isPrivate = null,
  }) {
    return _then(_$GameRoomImpl(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as int,
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameRoomImpl extends _GameRoom {
  const _$GameRoomImpl(
      {required this.roomId,
      required this.hostId,
      required final List<Player> players,
      required this.createdAt,
      this.maxPlayers = 4,
      this.status = RoomStatus.waiting,
      this.isPrivate = false})
      : _players = players,
        super._();

  factory _$GameRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameRoomImplFromJson(json);

  @override
  final int roomId;
  @override
  final int hostId;
// 방장 판별용, player.id와 비교해서 사용
  final List<Player> _players;
// 방장 판별용, player.id와 비교해서 사용
  @override
  List<Player> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int maxPlayers;
// 스플렌더는 2~4인
  @override
  @JsonKey()
  final RoomStatus status;
  @override
  @JsonKey()
  final bool isPrivate;

  @override
  String toString() {
    return 'GameRoom(roomId: $roomId, hostId: $hostId, players: $players, createdAt: $createdAt, maxPlayers: $maxPlayers, status: $status, isPrivate: $isPrivate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameRoomImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.hostId, hostId) || other.hostId == hostId) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      roomId,
      hostId,
      const DeepCollectionEquality().hash(_players),
      createdAt,
      maxPlayers,
      status,
      isPrivate);

  /// Create a copy of GameRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameRoomImplCopyWith<_$GameRoomImpl> get copyWith =>
      __$$GameRoomImplCopyWithImpl<_$GameRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameRoomImplToJson(
      this,
    );
  }
}

abstract class _GameRoom extends GameRoom {
  const factory _GameRoom(
      {required final int roomId,
      required final int hostId,
      required final List<Player> players,
      required final DateTime createdAt,
      final int maxPlayers,
      final RoomStatus status,
      final bool isPrivate}) = _$GameRoomImpl;
  const _GameRoom._() : super._();

  factory _GameRoom.fromJson(Map<String, dynamic> json) =
      _$GameRoomImpl.fromJson;

  @override
  int get roomId;
  @override
  int get hostId; // 방장 판별용, player.id와 비교해서 사용
  @override
  List<Player> get players;
  @override
  DateTime get createdAt;
  @override
  int get maxPlayers; // 스플렌더는 2~4인
  @override
  RoomStatus get status;
  @override
  bool get isPrivate;

  /// Create a copy of GameRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameRoomImplCopyWith<_$GameRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
