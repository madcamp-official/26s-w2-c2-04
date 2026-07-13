// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameEvent _$GameEventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'roomListUpdated':
      return RoomListUpdated.fromJson(json);
    case 'roomUpdated':
      return RoomUpdated.fromJson(json);
    case 'joinRoom':
      return JoinRoom.fromJson(json);
    case 'toggleReady':
      return ToggleReady.fromJson(json);
    case 'error':
      return GameEventError.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'GameEvent',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$GameEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<GameRoom> rooms) roomListUpdated,
    required TResult Function(GameRoom room) roomUpdated,
    required TResult Function(String roomId, Player player) joinRoom,
    required TResult Function(String roomId, String playerId) toggleReady,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<GameRoom> rooms)? roomListUpdated,
    TResult? Function(GameRoom room)? roomUpdated,
    TResult? Function(String roomId, Player player)? joinRoom,
    TResult? Function(String roomId, String playerId)? toggleReady,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<GameRoom> rooms)? roomListUpdated,
    TResult Function(GameRoom room)? roomUpdated,
    TResult Function(String roomId, Player player)? joinRoom,
    TResult Function(String roomId, String playerId)? toggleReady,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomListUpdated value) roomListUpdated,
    required TResult Function(RoomUpdated value) roomUpdated,
    required TResult Function(JoinRoom value) joinRoom,
    required TResult Function(ToggleReady value) toggleReady,
    required TResult Function(GameEventError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomListUpdated value)? roomListUpdated,
    TResult? Function(RoomUpdated value)? roomUpdated,
    TResult? Function(JoinRoom value)? joinRoom,
    TResult? Function(ToggleReady value)? toggleReady,
    TResult? Function(GameEventError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomListUpdated value)? roomListUpdated,
    TResult Function(RoomUpdated value)? roomUpdated,
    TResult Function(JoinRoom value)? joinRoom,
    TResult Function(ToggleReady value)? toggleReady,
    TResult Function(GameEventError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this GameEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameEventCopyWith<$Res> {
  factory $GameEventCopyWith(GameEvent value, $Res Function(GameEvent) then) =
      _$GameEventCopyWithImpl<$Res, GameEvent>;
}

/// @nodoc
class _$GameEventCopyWithImpl<$Res, $Val extends GameEvent>
    implements $GameEventCopyWith<$Res> {
  _$GameEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RoomListUpdatedImplCopyWith<$Res> {
  factory _$$RoomListUpdatedImplCopyWith(_$RoomListUpdatedImpl value,
          $Res Function(_$RoomListUpdatedImpl) then) =
      __$$RoomListUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<GameRoom> rooms});
}

/// @nodoc
class __$$RoomListUpdatedImplCopyWithImpl<$Res>
    extends _$GameEventCopyWithImpl<$Res, _$RoomListUpdatedImpl>
    implements _$$RoomListUpdatedImplCopyWith<$Res> {
  __$$RoomListUpdatedImplCopyWithImpl(
      _$RoomListUpdatedImpl _value, $Res Function(_$RoomListUpdatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rooms = null,
  }) {
    return _then(_$RoomListUpdatedImpl(
      rooms: null == rooms
          ? _value._rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as List<GameRoom>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomListUpdatedImpl implements RoomListUpdated {
  const _$RoomListUpdatedImpl(
      {required final List<GameRoom> rooms, final String? $type})
      : _rooms = rooms,
        $type = $type ?? 'roomListUpdated';

  factory _$RoomListUpdatedImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomListUpdatedImplFromJson(json);

  final List<GameRoom> _rooms;
  @override
  List<GameRoom> get rooms {
    if (_rooms is EqualUnmodifiableListView) return _rooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rooms);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'GameEvent.roomListUpdated(rooms: $rooms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomListUpdatedImpl &&
            const DeepCollectionEquality().equals(other._rooms, _rooms));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_rooms));

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomListUpdatedImplCopyWith<_$RoomListUpdatedImpl> get copyWith =>
      __$$RoomListUpdatedImplCopyWithImpl<_$RoomListUpdatedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<GameRoom> rooms) roomListUpdated,
    required TResult Function(GameRoom room) roomUpdated,
    required TResult Function(String roomId, Player player) joinRoom,
    required TResult Function(String roomId, String playerId) toggleReady,
    required TResult Function(String message) error,
  }) {
    return roomListUpdated(rooms);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<GameRoom> rooms)? roomListUpdated,
    TResult? Function(GameRoom room)? roomUpdated,
    TResult? Function(String roomId, Player player)? joinRoom,
    TResult? Function(String roomId, String playerId)? toggleReady,
    TResult? Function(String message)? error,
  }) {
    return roomListUpdated?.call(rooms);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<GameRoom> rooms)? roomListUpdated,
    TResult Function(GameRoom room)? roomUpdated,
    TResult Function(String roomId, Player player)? joinRoom,
    TResult Function(String roomId, String playerId)? toggleReady,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (roomListUpdated != null) {
      return roomListUpdated(rooms);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomListUpdated value) roomListUpdated,
    required TResult Function(RoomUpdated value) roomUpdated,
    required TResult Function(JoinRoom value) joinRoom,
    required TResult Function(ToggleReady value) toggleReady,
    required TResult Function(GameEventError value) error,
  }) {
    return roomListUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomListUpdated value)? roomListUpdated,
    TResult? Function(RoomUpdated value)? roomUpdated,
    TResult? Function(JoinRoom value)? joinRoom,
    TResult? Function(ToggleReady value)? toggleReady,
    TResult? Function(GameEventError value)? error,
  }) {
    return roomListUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomListUpdated value)? roomListUpdated,
    TResult Function(RoomUpdated value)? roomUpdated,
    TResult Function(JoinRoom value)? joinRoom,
    TResult Function(ToggleReady value)? toggleReady,
    TResult Function(GameEventError value)? error,
    required TResult orElse(),
  }) {
    if (roomListUpdated != null) {
      return roomListUpdated(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomListUpdatedImplToJson(
      this,
    );
  }
}

abstract class RoomListUpdated implements GameEvent {
  const factory RoomListUpdated({required final List<GameRoom> rooms}) =
      _$RoomListUpdatedImpl;

  factory RoomListUpdated.fromJson(Map<String, dynamic> json) =
      _$RoomListUpdatedImpl.fromJson;

  List<GameRoom> get rooms;

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomListUpdatedImplCopyWith<_$RoomListUpdatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RoomUpdatedImplCopyWith<$Res> {
  factory _$$RoomUpdatedImplCopyWith(
          _$RoomUpdatedImpl value, $Res Function(_$RoomUpdatedImpl) then) =
      __$$RoomUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GameRoom room});

  $GameRoomCopyWith<$Res> get room;
}

/// @nodoc
class __$$RoomUpdatedImplCopyWithImpl<$Res>
    extends _$GameEventCopyWithImpl<$Res, _$RoomUpdatedImpl>
    implements _$$RoomUpdatedImplCopyWith<$Res> {
  __$$RoomUpdatedImplCopyWithImpl(
      _$RoomUpdatedImpl _value, $Res Function(_$RoomUpdatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = null,
  }) {
    return _then(_$RoomUpdatedImpl(
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as GameRoom,
    ));
  }

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameRoomCopyWith<$Res> get room {
    return $GameRoomCopyWith<$Res>(_value.room, (value) {
      return _then(_value.copyWith(room: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomUpdatedImpl implements RoomUpdated {
  const _$RoomUpdatedImpl({required this.room, final String? $type})
      : $type = $type ?? 'roomUpdated';

  factory _$RoomUpdatedImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomUpdatedImplFromJson(json);

  @override
  final GameRoom room;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'GameEvent.roomUpdated(room: $room)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomUpdatedImpl &&
            (identical(other.room, room) || other.room == room));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, room);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomUpdatedImplCopyWith<_$RoomUpdatedImpl> get copyWith =>
      __$$RoomUpdatedImplCopyWithImpl<_$RoomUpdatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<GameRoom> rooms) roomListUpdated,
    required TResult Function(GameRoom room) roomUpdated,
    required TResult Function(String roomId, Player player) joinRoom,
    required TResult Function(String roomId, String playerId) toggleReady,
    required TResult Function(String message) error,
  }) {
    return roomUpdated(room);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<GameRoom> rooms)? roomListUpdated,
    TResult? Function(GameRoom room)? roomUpdated,
    TResult? Function(String roomId, Player player)? joinRoom,
    TResult? Function(String roomId, String playerId)? toggleReady,
    TResult? Function(String message)? error,
  }) {
    return roomUpdated?.call(room);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<GameRoom> rooms)? roomListUpdated,
    TResult Function(GameRoom room)? roomUpdated,
    TResult Function(String roomId, Player player)? joinRoom,
    TResult Function(String roomId, String playerId)? toggleReady,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (roomUpdated != null) {
      return roomUpdated(room);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomListUpdated value) roomListUpdated,
    required TResult Function(RoomUpdated value) roomUpdated,
    required TResult Function(JoinRoom value) joinRoom,
    required TResult Function(ToggleReady value) toggleReady,
    required TResult Function(GameEventError value) error,
  }) {
    return roomUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomListUpdated value)? roomListUpdated,
    TResult? Function(RoomUpdated value)? roomUpdated,
    TResult? Function(JoinRoom value)? joinRoom,
    TResult? Function(ToggleReady value)? toggleReady,
    TResult? Function(GameEventError value)? error,
  }) {
    return roomUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomListUpdated value)? roomListUpdated,
    TResult Function(RoomUpdated value)? roomUpdated,
    TResult Function(JoinRoom value)? joinRoom,
    TResult Function(ToggleReady value)? toggleReady,
    TResult Function(GameEventError value)? error,
    required TResult orElse(),
  }) {
    if (roomUpdated != null) {
      return roomUpdated(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomUpdatedImplToJson(
      this,
    );
  }
}

abstract class RoomUpdated implements GameEvent {
  const factory RoomUpdated({required final GameRoom room}) = _$RoomUpdatedImpl;

  factory RoomUpdated.fromJson(Map<String, dynamic> json) =
      _$RoomUpdatedImpl.fromJson;

  GameRoom get room;

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomUpdatedImplCopyWith<_$RoomUpdatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$JoinRoomImplCopyWith<$Res> {
  factory _$$JoinRoomImplCopyWith(
          _$JoinRoomImpl value, $Res Function(_$JoinRoomImpl) then) =
      __$$JoinRoomImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String roomId, Player player});

  $PlayerCopyWith<$Res> get player;
}

/// @nodoc
class __$$JoinRoomImplCopyWithImpl<$Res>
    extends _$GameEventCopyWithImpl<$Res, _$JoinRoomImpl>
    implements _$$JoinRoomImplCopyWith<$Res> {
  __$$JoinRoomImplCopyWithImpl(
      _$JoinRoomImpl _value, $Res Function(_$JoinRoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? player = null,
  }) {
    return _then(_$JoinRoomImpl(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      player: null == player
          ? _value.player
          : player // ignore: cast_nullable_to_non_nullable
              as Player,
    ));
  }

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerCopyWith<$Res> get player {
    return $PlayerCopyWith<$Res>(_value.player, (value) {
      return _then(_value.copyWith(player: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$JoinRoomImpl implements JoinRoom {
  const _$JoinRoomImpl(
      {required this.roomId, required this.player, final String? $type})
      : $type = $type ?? 'joinRoom';

  factory _$JoinRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$JoinRoomImplFromJson(json);

  @override
  final String roomId;
  @override
  final Player player;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'GameEvent.joinRoom(roomId: $roomId, player: $player)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinRoomImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.player, player) || other.player == player));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, roomId, player);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinRoomImplCopyWith<_$JoinRoomImpl> get copyWith =>
      __$$JoinRoomImplCopyWithImpl<_$JoinRoomImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<GameRoom> rooms) roomListUpdated,
    required TResult Function(GameRoom room) roomUpdated,
    required TResult Function(String roomId, Player player) joinRoom,
    required TResult Function(String roomId, String playerId) toggleReady,
    required TResult Function(String message) error,
  }) {
    return joinRoom(roomId, player);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<GameRoom> rooms)? roomListUpdated,
    TResult? Function(GameRoom room)? roomUpdated,
    TResult? Function(String roomId, Player player)? joinRoom,
    TResult? Function(String roomId, String playerId)? toggleReady,
    TResult? Function(String message)? error,
  }) {
    return joinRoom?.call(roomId, player);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<GameRoom> rooms)? roomListUpdated,
    TResult Function(GameRoom room)? roomUpdated,
    TResult Function(String roomId, Player player)? joinRoom,
    TResult Function(String roomId, String playerId)? toggleReady,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (joinRoom != null) {
      return joinRoom(roomId, player);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomListUpdated value) roomListUpdated,
    required TResult Function(RoomUpdated value) roomUpdated,
    required TResult Function(JoinRoom value) joinRoom,
    required TResult Function(ToggleReady value) toggleReady,
    required TResult Function(GameEventError value) error,
  }) {
    return joinRoom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomListUpdated value)? roomListUpdated,
    TResult? Function(RoomUpdated value)? roomUpdated,
    TResult? Function(JoinRoom value)? joinRoom,
    TResult? Function(ToggleReady value)? toggleReady,
    TResult? Function(GameEventError value)? error,
  }) {
    return joinRoom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomListUpdated value)? roomListUpdated,
    TResult Function(RoomUpdated value)? roomUpdated,
    TResult Function(JoinRoom value)? joinRoom,
    TResult Function(ToggleReady value)? toggleReady,
    TResult Function(GameEventError value)? error,
    required TResult orElse(),
  }) {
    if (joinRoom != null) {
      return joinRoom(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$JoinRoomImplToJson(
      this,
    );
  }
}

abstract class JoinRoom implements GameEvent {
  const factory JoinRoom(
      {required final String roomId,
      required final Player player}) = _$JoinRoomImpl;

  factory JoinRoom.fromJson(Map<String, dynamic> json) =
      _$JoinRoomImpl.fromJson;

  String get roomId;
  Player get player;

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinRoomImplCopyWith<_$JoinRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ToggleReadyImplCopyWith<$Res> {
  factory _$$ToggleReadyImplCopyWith(
          _$ToggleReadyImpl value, $Res Function(_$ToggleReadyImpl) then) =
      __$$ToggleReadyImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String roomId, String playerId});
}

/// @nodoc
class __$$ToggleReadyImplCopyWithImpl<$Res>
    extends _$GameEventCopyWithImpl<$Res, _$ToggleReadyImpl>
    implements _$$ToggleReadyImplCopyWith<$Res> {
  __$$ToggleReadyImplCopyWithImpl(
      _$ToggleReadyImpl _value, $Res Function(_$ToggleReadyImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? playerId = null,
  }) {
    return _then(_$ToggleReadyImpl(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToggleReadyImpl implements ToggleReady {
  const _$ToggleReadyImpl(
      {required this.roomId, required this.playerId, final String? $type})
      : $type = $type ?? 'toggleReady';

  factory _$ToggleReadyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToggleReadyImplFromJson(json);

  @override
  final String roomId;
  @override
  final String playerId;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'GameEvent.toggleReady(roomId: $roomId, playerId: $playerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToggleReadyImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, roomId, playerId);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToggleReadyImplCopyWith<_$ToggleReadyImpl> get copyWith =>
      __$$ToggleReadyImplCopyWithImpl<_$ToggleReadyImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<GameRoom> rooms) roomListUpdated,
    required TResult Function(GameRoom room) roomUpdated,
    required TResult Function(String roomId, Player player) joinRoom,
    required TResult Function(String roomId, String playerId) toggleReady,
    required TResult Function(String message) error,
  }) {
    return toggleReady(roomId, playerId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<GameRoom> rooms)? roomListUpdated,
    TResult? Function(GameRoom room)? roomUpdated,
    TResult? Function(String roomId, Player player)? joinRoom,
    TResult? Function(String roomId, String playerId)? toggleReady,
    TResult? Function(String message)? error,
  }) {
    return toggleReady?.call(roomId, playerId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<GameRoom> rooms)? roomListUpdated,
    TResult Function(GameRoom room)? roomUpdated,
    TResult Function(String roomId, Player player)? joinRoom,
    TResult Function(String roomId, String playerId)? toggleReady,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (toggleReady != null) {
      return toggleReady(roomId, playerId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomListUpdated value) roomListUpdated,
    required TResult Function(RoomUpdated value) roomUpdated,
    required TResult Function(JoinRoom value) joinRoom,
    required TResult Function(ToggleReady value) toggleReady,
    required TResult Function(GameEventError value) error,
  }) {
    return toggleReady(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomListUpdated value)? roomListUpdated,
    TResult? Function(RoomUpdated value)? roomUpdated,
    TResult? Function(JoinRoom value)? joinRoom,
    TResult? Function(ToggleReady value)? toggleReady,
    TResult? Function(GameEventError value)? error,
  }) {
    return toggleReady?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomListUpdated value)? roomListUpdated,
    TResult Function(RoomUpdated value)? roomUpdated,
    TResult Function(JoinRoom value)? joinRoom,
    TResult Function(ToggleReady value)? toggleReady,
    TResult Function(GameEventError value)? error,
    required TResult orElse(),
  }) {
    if (toggleReady != null) {
      return toggleReady(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ToggleReadyImplToJson(
      this,
    );
  }
}

abstract class ToggleReady implements GameEvent {
  const factory ToggleReady(
      {required final String roomId,
      required final String playerId}) = _$ToggleReadyImpl;

  factory ToggleReady.fromJson(Map<String, dynamic> json) =
      _$ToggleReadyImpl.fromJson;

  String get roomId;
  String get playerId;

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToggleReadyImplCopyWith<_$ToggleReadyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameEventErrorImplCopyWith<$Res> {
  factory _$$GameEventErrorImplCopyWith(_$GameEventErrorImpl value,
          $Res Function(_$GameEventErrorImpl) then) =
      __$$GameEventErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$GameEventErrorImplCopyWithImpl<$Res>
    extends _$GameEventCopyWithImpl<$Res, _$GameEventErrorImpl>
    implements _$$GameEventErrorImplCopyWith<$Res> {
  __$$GameEventErrorImplCopyWithImpl(
      _$GameEventErrorImpl _value, $Res Function(_$GameEventErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$GameEventErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameEventErrorImpl implements GameEventError {
  const _$GameEventErrorImpl({required this.message, final String? $type})
      : $type = $type ?? 'error';

  factory _$GameEventErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameEventErrorImplFromJson(json);

  @override
  final String message;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'GameEvent.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameEventErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameEventErrorImplCopyWith<_$GameEventErrorImpl> get copyWith =>
      __$$GameEventErrorImplCopyWithImpl<_$GameEventErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<GameRoom> rooms) roomListUpdated,
    required TResult Function(GameRoom room) roomUpdated,
    required TResult Function(String roomId, Player player) joinRoom,
    required TResult Function(String roomId, String playerId) toggleReady,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<GameRoom> rooms)? roomListUpdated,
    TResult? Function(GameRoom room)? roomUpdated,
    TResult? Function(String roomId, Player player)? joinRoom,
    TResult? Function(String roomId, String playerId)? toggleReady,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<GameRoom> rooms)? roomListUpdated,
    TResult Function(GameRoom room)? roomUpdated,
    TResult Function(String roomId, Player player)? joinRoom,
    TResult Function(String roomId, String playerId)? toggleReady,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RoomListUpdated value) roomListUpdated,
    required TResult Function(RoomUpdated value) roomUpdated,
    required TResult Function(JoinRoom value) joinRoom,
    required TResult Function(ToggleReady value) toggleReady,
    required TResult Function(GameEventError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RoomListUpdated value)? roomListUpdated,
    TResult? Function(RoomUpdated value)? roomUpdated,
    TResult? Function(JoinRoom value)? joinRoom,
    TResult? Function(ToggleReady value)? toggleReady,
    TResult? Function(GameEventError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RoomListUpdated value)? roomListUpdated,
    TResult Function(RoomUpdated value)? roomUpdated,
    TResult Function(JoinRoom value)? joinRoom,
    TResult Function(ToggleReady value)? toggleReady,
    TResult Function(GameEventError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GameEventErrorImplToJson(
      this,
    );
  }
}

abstract class GameEventError implements GameEvent {
  const factory GameEventError({required final String message}) =
      _$GameEventErrorImpl;

  factory GameEventError.fromJson(Map<String, dynamic> json) =
      _$GameEventErrorImpl.fromJson;

  String get message;

  /// Create a copy of GameEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameEventErrorImplCopyWith<_$GameEventErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
