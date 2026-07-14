// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_hub_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FinalScore {
  int get userId => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Create a copy of FinalScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinalScoreCopyWith<FinalScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinalScoreCopyWith<$Res> {
  factory $FinalScoreCopyWith(
          FinalScore value, $Res Function(FinalScore) then) =
      _$FinalScoreCopyWithImpl<$Res, FinalScore>;
  @useResult
  $Res call({int userId, int score});
}

/// @nodoc
class _$FinalScoreCopyWithImpl<$Res, $Val extends FinalScore>
    implements $FinalScoreCopyWith<$Res> {
  _$FinalScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinalScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinalScoreImplCopyWith<$Res>
    implements $FinalScoreCopyWith<$Res> {
  factory _$$FinalScoreImplCopyWith(
          _$FinalScoreImpl value, $Res Function(_$FinalScoreImpl) then) =
      __$$FinalScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, int score});
}

/// @nodoc
class __$$FinalScoreImplCopyWithImpl<$Res>
    extends _$FinalScoreCopyWithImpl<$Res, _$FinalScoreImpl>
    implements _$$FinalScoreImplCopyWith<$Res> {
  __$$FinalScoreImplCopyWithImpl(
      _$FinalScoreImpl _value, $Res Function(_$FinalScoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of FinalScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? score = null,
  }) {
    return _then(_$FinalScoreImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FinalScoreImpl implements _FinalScore {
  const _$FinalScoreImpl({required this.userId, required this.score});

  @override
  final int userId;
  @override
  final int score;

  @override
  String toString() {
    return 'FinalScore(userId: $userId, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinalScoreImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.score, score) || other.score == score));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, score);

  /// Create a copy of FinalScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinalScoreImplCopyWith<_$FinalScoreImpl> get copyWith =>
      __$$FinalScoreImplCopyWithImpl<_$FinalScoreImpl>(this, _$identity);
}

abstract class _FinalScore implements FinalScore {
  const factory _FinalScore(
      {required final int userId, required final int score}) = _$FinalScoreImpl;

  @override
  int get userId;
  @override
  int get score;

  /// Create a copy of FinalScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinalScoreImplCopyWith<_$FinalScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GameHubEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameHubEventCopyWith<$Res> {
  factory $GameHubEventCopyWith(
          GameHubEvent value, $Res Function(GameHubEvent) then) =
      _$GameHubEventCopyWithImpl<$Res, GameHubEvent>;
}

/// @nodoc
class _$GameHubEventCopyWithImpl<$Res, $Val extends GameHubEvent>
    implements $GameHubEventCopyWith<$Res> {
  _$GameHubEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GameHubStateSyncImplCopyWith<$Res> {
  factory _$$GameHubStateSyncImplCopyWith(_$GameHubStateSyncImpl value,
          $Res Function(_$GameHubStateSyncImpl) then) =
      __$$GameHubStateSyncImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {GameState? state, List<Map<String, dynamic>>? patch, int sequence});

  $GameStateCopyWith<$Res>? get state;
}

/// @nodoc
class __$$GameHubStateSyncImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubStateSyncImpl>
    implements _$$GameHubStateSyncImplCopyWith<$Res> {
  __$$GameHubStateSyncImplCopyWithImpl(_$GameHubStateSyncImpl _value,
      $Res Function(_$GameHubStateSyncImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = freezed,
    Object? patch = freezed,
    Object? sequence = null,
  }) {
    return _then(_$GameHubStateSyncImpl(
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as GameState?,
      patch: freezed == patch
          ? _value._patch
          : patch // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameStateCopyWith<$Res>? get state {
    if (_value.state == null) {
      return null;
    }

    return $GameStateCopyWith<$Res>(_value.state!, (value) {
      return _then(_value.copyWith(state: value));
    });
  }
}

/// @nodoc

class _$GameHubStateSyncImpl implements GameHubStateSync {
  const _$GameHubStateSyncImpl(
      {this.state,
      final List<Map<String, dynamic>>? patch,
      required this.sequence})
      : _patch = patch;

  @override
  final GameState? state;
  final List<Map<String, dynamic>>? _patch;
  @override
  List<Map<String, dynamic>>? get patch {
    final value = _patch;
    if (value == null) return null;
    if (_patch is EqualUnmodifiableListView) return _patch;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int sequence;

  @override
  String toString() {
    return 'GameHubEvent.stateSync(state: $state, patch: $patch, sequence: $sequence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubStateSyncImpl &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality().equals(other._patch, _patch) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence));
  }

  @override
  int get hashCode => Object.hash(runtimeType, state,
      const DeepCollectionEquality().hash(_patch), sequence);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubStateSyncImplCopyWith<_$GameHubStateSyncImpl> get copyWith =>
      __$$GameHubStateSyncImplCopyWithImpl<_$GameHubStateSyncImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return stateSync(state, patch, sequence);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return stateSync?.call(state, patch, sequence);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (stateSync != null) {
      return stateSync(state, patch, sequence);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return stateSync(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return stateSync?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (stateSync != null) {
      return stateSync(this);
    }
    return orElse();
  }
}

abstract class GameHubStateSync implements GameHubEvent {
  const factory GameHubStateSync(
      {final GameState? state,
      final List<Map<String, dynamic>>? patch,
      required final int sequence}) = _$GameHubStateSyncImpl;

  GameState? get state;
  List<Map<String, dynamic>>? get patch;
  int get sequence;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubStateSyncImplCopyWith<_$GameHubStateSyncImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubActionResultImplCopyWith<$Res> {
  factory _$$GameHubActionResultImplCopyWith(_$GameHubActionResultImpl value,
          $Res Function(_$GameHubActionResultImpl) then) =
      __$$GameHubActionResultImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool success, String? error, List<Map<String, dynamic>>? patch});
}

/// @nodoc
class __$$GameHubActionResultImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubActionResultImpl>
    implements _$$GameHubActionResultImplCopyWith<$Res> {
  __$$GameHubActionResultImplCopyWithImpl(_$GameHubActionResultImpl _value,
      $Res Function(_$GameHubActionResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? error = freezed,
    Object? patch = freezed,
  }) {
    return _then(_$GameHubActionResultImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      patch: freezed == patch
          ? _value._patch
          : patch // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
    ));
  }
}

/// @nodoc

class _$GameHubActionResultImpl implements GameHubActionResult {
  const _$GameHubActionResultImpl(
      {required this.success,
      this.error,
      final List<Map<String, dynamic>>? patch})
      : _patch = patch;

  @override
  final bool success;
  @override
  final String? error;
  final List<Map<String, dynamic>>? _patch;
  @override
  List<Map<String, dynamic>>? get patch {
    final value = _patch;
    if (value == null) return null;
    if (_patch is EqualUnmodifiableListView) return _patch;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'GameHubEvent.actionResult(success: $success, error: $error, patch: $patch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubActionResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._patch, _patch));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, success, error, const DeepCollectionEquality().hash(_patch));

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubActionResultImplCopyWith<_$GameHubActionResultImpl> get copyWith =>
      __$$GameHubActionResultImplCopyWithImpl<_$GameHubActionResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return actionResult(success, error, patch);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return actionResult?.call(success, error, patch);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (actionResult != null) {
      return actionResult(success, error, patch);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return actionResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return actionResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (actionResult != null) {
      return actionResult(this);
    }
    return orElse();
  }
}

abstract class GameHubActionResult implements GameHubEvent {
  const factory GameHubActionResult(
      {required final bool success,
      final String? error,
      final List<Map<String, dynamic>>? patch}) = _$GameHubActionResultImpl;

  bool get success;
  String? get error;
  List<Map<String, dynamic>>? get patch;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubActionResultImplCopyWith<_$GameHubActionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubTurnChangedImplCopyWith<$Res> {
  factory _$$GameHubTurnChangedImplCopyWith(_$GameHubTurnChangedImpl value,
          $Res Function(_$GameHubTurnChangedImpl) then) =
      __$$GameHubTurnChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int currentPlayerId, int turnNumber});
}

/// @nodoc
class __$$GameHubTurnChangedImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubTurnChangedImpl>
    implements _$$GameHubTurnChangedImplCopyWith<$Res> {
  __$$GameHubTurnChangedImplCopyWithImpl(_$GameHubTurnChangedImpl _value,
      $Res Function(_$GameHubTurnChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPlayerId = null,
    Object? turnNumber = null,
  }) {
    return _then(_$GameHubTurnChangedImpl(
      currentPlayerId: null == currentPlayerId
          ? _value.currentPlayerId
          : currentPlayerId // ignore: cast_nullable_to_non_nullable
              as int,
      turnNumber: null == turnNumber
          ? _value.turnNumber
          : turnNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$GameHubTurnChangedImpl implements GameHubTurnChanged {
  const _$GameHubTurnChangedImpl(
      {required this.currentPlayerId, required this.turnNumber});

  @override
  final int currentPlayerId;
  @override
  final int turnNumber;

  @override
  String toString() {
    return 'GameHubEvent.turnChanged(currentPlayerId: $currentPlayerId, turnNumber: $turnNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubTurnChangedImpl &&
            (identical(other.currentPlayerId, currentPlayerId) ||
                other.currentPlayerId == currentPlayerId) &&
            (identical(other.turnNumber, turnNumber) ||
                other.turnNumber == turnNumber));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentPlayerId, turnNumber);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubTurnChangedImplCopyWith<_$GameHubTurnChangedImpl> get copyWith =>
      __$$GameHubTurnChangedImplCopyWithImpl<_$GameHubTurnChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return turnChanged(currentPlayerId, turnNumber);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return turnChanged?.call(currentPlayerId, turnNumber);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (turnChanged != null) {
      return turnChanged(currentPlayerId, turnNumber);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return turnChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return turnChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (turnChanged != null) {
      return turnChanged(this);
    }
    return orElse();
  }
}

abstract class GameHubTurnChanged implements GameHubEvent {
  const factory GameHubTurnChanged(
      {required final int currentPlayerId,
      required final int turnNumber}) = _$GameHubTurnChangedImpl;

  int get currentPlayerId;
  int get turnNumber;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubTurnChangedImplCopyWith<_$GameHubTurnChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubNobleAwardedImplCopyWith<$Res> {
  factory _$$GameHubNobleAwardedImplCopyWith(_$GameHubNobleAwardedImpl value,
          $Res Function(_$GameHubNobleAwardedImpl) then) =
      __$$GameHubNobleAwardedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int playerId, String nobleId});
}

/// @nodoc
class __$$GameHubNobleAwardedImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubNobleAwardedImpl>
    implements _$$GameHubNobleAwardedImplCopyWith<$Res> {
  __$$GameHubNobleAwardedImplCopyWithImpl(_$GameHubNobleAwardedImpl _value,
      $Res Function(_$GameHubNobleAwardedImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? nobleId = null,
  }) {
    return _then(_$GameHubNobleAwardedImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as int,
      nobleId: null == nobleId
          ? _value.nobleId
          : nobleId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GameHubNobleAwardedImpl implements GameHubNobleAwarded {
  const _$GameHubNobleAwardedImpl(
      {required this.playerId, required this.nobleId});

  @override
  final int playerId;
  @override
  final String nobleId;

  @override
  String toString() {
    return 'GameHubEvent.nobleAwarded(playerId: $playerId, nobleId: $nobleId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubNobleAwardedImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.nobleId, nobleId) || other.nobleId == nobleId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, playerId, nobleId);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubNobleAwardedImplCopyWith<_$GameHubNobleAwardedImpl> get copyWith =>
      __$$GameHubNobleAwardedImplCopyWithImpl<_$GameHubNobleAwardedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return nobleAwarded(playerId, nobleId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return nobleAwarded?.call(playerId, nobleId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (nobleAwarded != null) {
      return nobleAwarded(playerId, nobleId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return nobleAwarded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return nobleAwarded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (nobleAwarded != null) {
      return nobleAwarded(this);
    }
    return orElse();
  }
}

abstract class GameHubNobleAwarded implements GameHubEvent {
  const factory GameHubNobleAwarded(
      {required final int playerId,
      required final String nobleId}) = _$GameHubNobleAwardedImpl;

  int get playerId;
  String get nobleId;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubNobleAwardedImplCopyWith<_$GameHubNobleAwardedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubNobleChoiceRequiredImplCopyWith<$Res> {
  factory _$$GameHubNobleChoiceRequiredImplCopyWith(
          _$GameHubNobleChoiceRequiredImpl value,
          $Res Function(_$GameHubNobleChoiceRequiredImpl) then) =
      __$$GameHubNobleChoiceRequiredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int playerId, List<String> candidateNobleIds});
}

/// @nodoc
class __$$GameHubNobleChoiceRequiredImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubNobleChoiceRequiredImpl>
    implements _$$GameHubNobleChoiceRequiredImplCopyWith<$Res> {
  __$$GameHubNobleChoiceRequiredImplCopyWithImpl(
      _$GameHubNobleChoiceRequiredImpl _value,
      $Res Function(_$GameHubNobleChoiceRequiredImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? candidateNobleIds = null,
  }) {
    return _then(_$GameHubNobleChoiceRequiredImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as int,
      candidateNobleIds: null == candidateNobleIds
          ? _value._candidateNobleIds
          : candidateNobleIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$GameHubNobleChoiceRequiredImpl implements GameHubNobleChoiceRequired {
  const _$GameHubNobleChoiceRequiredImpl(
      {required this.playerId, required final List<String> candidateNobleIds})
      : _candidateNobleIds = candidateNobleIds;

  @override
  final int playerId;
  final List<String> _candidateNobleIds;
  @override
  List<String> get candidateNobleIds {
    if (_candidateNobleIds is EqualUnmodifiableListView)
      return _candidateNobleIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_candidateNobleIds);
  }

  @override
  String toString() {
    return 'GameHubEvent.nobleChoiceRequired(playerId: $playerId, candidateNobleIds: $candidateNobleIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubNobleChoiceRequiredImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            const DeepCollectionEquality()
                .equals(other._candidateNobleIds, _candidateNobleIds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, playerId,
      const DeepCollectionEquality().hash(_candidateNobleIds));

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubNobleChoiceRequiredImplCopyWith<_$GameHubNobleChoiceRequiredImpl>
      get copyWith => __$$GameHubNobleChoiceRequiredImplCopyWithImpl<
          _$GameHubNobleChoiceRequiredImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return nobleChoiceRequired(playerId, candidateNobleIds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return nobleChoiceRequired?.call(playerId, candidateNobleIds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (nobleChoiceRequired != null) {
      return nobleChoiceRequired(playerId, candidateNobleIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return nobleChoiceRequired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return nobleChoiceRequired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (nobleChoiceRequired != null) {
      return nobleChoiceRequired(this);
    }
    return orElse();
  }
}

abstract class GameHubNobleChoiceRequired implements GameHubEvent {
  const factory GameHubNobleChoiceRequired(
          {required final int playerId,
          required final List<String> candidateNobleIds}) =
      _$GameHubNobleChoiceRequiredImpl;

  int get playerId;
  List<String> get candidateNobleIds;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubNobleChoiceRequiredImplCopyWith<_$GameHubNobleChoiceRequiredImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubPlayerJoinedImplCopyWith<$Res> {
  factory _$$GameHubPlayerJoinedImplCopyWith(_$GameHubPlayerJoinedImpl value,
          $Res Function(_$GameHubPlayerJoinedImpl) then) =
      __$$GameHubPlayerJoinedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int userId, String nickname});
}

/// @nodoc
class __$$GameHubPlayerJoinedImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubPlayerJoinedImpl>
    implements _$$GameHubPlayerJoinedImplCopyWith<$Res> {
  __$$GameHubPlayerJoinedImplCopyWithImpl(_$GameHubPlayerJoinedImpl _value,
      $Res Function(_$GameHubPlayerJoinedImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
  }) {
    return _then(_$GameHubPlayerJoinedImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GameHubPlayerJoinedImpl implements GameHubPlayerJoined {
  const _$GameHubPlayerJoinedImpl(
      {required this.userId, required this.nickname});

  @override
  final int userId;
  @override
  final String nickname;

  @override
  String toString() {
    return 'GameHubEvent.playerJoined(userId: $userId, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubPlayerJoinedImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, nickname);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubPlayerJoinedImplCopyWith<_$GameHubPlayerJoinedImpl> get copyWith =>
      __$$GameHubPlayerJoinedImplCopyWithImpl<_$GameHubPlayerJoinedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return playerJoined(userId, nickname);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return playerJoined?.call(userId, nickname);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (playerJoined != null) {
      return playerJoined(userId, nickname);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return playerJoined(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return playerJoined?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (playerJoined != null) {
      return playerJoined(this);
    }
    return orElse();
  }
}

abstract class GameHubPlayerJoined implements GameHubEvent {
  const factory GameHubPlayerJoined(
      {required final int userId,
      required final String nickname}) = _$GameHubPlayerJoinedImpl;

  int get userId;
  String get nickname;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubPlayerJoinedImplCopyWith<_$GameHubPlayerJoinedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubPlayerLeftImplCopyWith<$Res> {
  factory _$$GameHubPlayerLeftImplCopyWith(_$GameHubPlayerLeftImpl value,
          $Res Function(_$GameHubPlayerLeftImpl) then) =
      __$$GameHubPlayerLeftImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int userId, String nickname});
}

/// @nodoc
class __$$GameHubPlayerLeftImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubPlayerLeftImpl>
    implements _$$GameHubPlayerLeftImplCopyWith<$Res> {
  __$$GameHubPlayerLeftImplCopyWithImpl(_$GameHubPlayerLeftImpl _value,
      $Res Function(_$GameHubPlayerLeftImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
  }) {
    return _then(_$GameHubPlayerLeftImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GameHubPlayerLeftImpl implements GameHubPlayerLeft {
  const _$GameHubPlayerLeftImpl({required this.userId, required this.nickname});

  @override
  final int userId;
  @override
  final String nickname;

  @override
  String toString() {
    return 'GameHubEvent.playerLeft(userId: $userId, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubPlayerLeftImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, nickname);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubPlayerLeftImplCopyWith<_$GameHubPlayerLeftImpl> get copyWith =>
      __$$GameHubPlayerLeftImplCopyWithImpl<_$GameHubPlayerLeftImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return playerLeft(userId, nickname);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return playerLeft?.call(userId, nickname);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (playerLeft != null) {
      return playerLeft(userId, nickname);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return playerLeft(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return playerLeft?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (playerLeft != null) {
      return playerLeft(this);
    }
    return orElse();
  }
}

abstract class GameHubPlayerLeft implements GameHubEvent {
  const factory GameHubPlayerLeft(
      {required final int userId,
      required final String nickname}) = _$GameHubPlayerLeftImpl;

  int get userId;
  String get nickname;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubPlayerLeftImplCopyWith<_$GameHubPlayerLeftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubFinalRoundTriggeredImplCopyWith<$Res> {
  factory _$$GameHubFinalRoundTriggeredImplCopyWith(
          _$GameHubFinalRoundTriggeredImpl value,
          $Res Function(_$GameHubFinalRoundTriggeredImpl) then) =
      __$$GameHubFinalRoundTriggeredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int triggeredBy, int? lastTurnPlayerId});
}

/// @nodoc
class __$$GameHubFinalRoundTriggeredImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubFinalRoundTriggeredImpl>
    implements _$$GameHubFinalRoundTriggeredImplCopyWith<$Res> {
  __$$GameHubFinalRoundTriggeredImplCopyWithImpl(
      _$GameHubFinalRoundTriggeredImpl _value,
      $Res Function(_$GameHubFinalRoundTriggeredImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? triggeredBy = null,
    Object? lastTurnPlayerId = freezed,
  }) {
    return _then(_$GameHubFinalRoundTriggeredImpl(
      triggeredBy: null == triggeredBy
          ? _value.triggeredBy
          : triggeredBy // ignore: cast_nullable_to_non_nullable
              as int,
      lastTurnPlayerId: freezed == lastTurnPlayerId
          ? _value.lastTurnPlayerId
          : lastTurnPlayerId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$GameHubFinalRoundTriggeredImpl implements GameHubFinalRoundTriggered {
  const _$GameHubFinalRoundTriggeredImpl(
      {required this.triggeredBy, this.lastTurnPlayerId});

  @override
  final int triggeredBy;
  @override
  final int? lastTurnPlayerId;

  @override
  String toString() {
    return 'GameHubEvent.finalRoundTriggered(triggeredBy: $triggeredBy, lastTurnPlayerId: $lastTurnPlayerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubFinalRoundTriggeredImpl &&
            (identical(other.triggeredBy, triggeredBy) ||
                other.triggeredBy == triggeredBy) &&
            (identical(other.lastTurnPlayerId, lastTurnPlayerId) ||
                other.lastTurnPlayerId == lastTurnPlayerId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, triggeredBy, lastTurnPlayerId);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubFinalRoundTriggeredImplCopyWith<_$GameHubFinalRoundTriggeredImpl>
      get copyWith => __$$GameHubFinalRoundTriggeredImplCopyWithImpl<
          _$GameHubFinalRoundTriggeredImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return finalRoundTriggered(triggeredBy, lastTurnPlayerId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return finalRoundTriggered?.call(triggeredBy, lastTurnPlayerId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (finalRoundTriggered != null) {
      return finalRoundTriggered(triggeredBy, lastTurnPlayerId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return finalRoundTriggered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return finalRoundTriggered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (finalRoundTriggered != null) {
      return finalRoundTriggered(this);
    }
    return orElse();
  }
}

abstract class GameHubFinalRoundTriggered implements GameHubEvent {
  const factory GameHubFinalRoundTriggered(
      {required final int triggeredBy,
      final int? lastTurnPlayerId}) = _$GameHubFinalRoundTriggeredImpl;

  int get triggeredBy;
  int? get lastTurnPlayerId;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubFinalRoundTriggeredImplCopyWith<_$GameHubFinalRoundTriggeredImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubGameOverImplCopyWith<$Res> {
  factory _$$GameHubGameOverImplCopyWith(_$GameHubGameOverImpl value,
          $Res Function(_$GameHubGameOverImpl) then) =
      __$$GameHubGameOverImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {int winnerId, List<FinalScore> finalScores, String? tieBreakReason});
}

/// @nodoc
class __$$GameHubGameOverImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubGameOverImpl>
    implements _$$GameHubGameOverImplCopyWith<$Res> {
  __$$GameHubGameOverImplCopyWithImpl(
      _$GameHubGameOverImpl _value, $Res Function(_$GameHubGameOverImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? winnerId = null,
    Object? finalScores = null,
    Object? tieBreakReason = freezed,
  }) {
    return _then(_$GameHubGameOverImpl(
      winnerId: null == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as int,
      finalScores: null == finalScores
          ? _value._finalScores
          : finalScores // ignore: cast_nullable_to_non_nullable
              as List<FinalScore>,
      tieBreakReason: freezed == tieBreakReason
          ? _value.tieBreakReason
          : tieBreakReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GameHubGameOverImpl implements GameHubGameOver {
  const _$GameHubGameOverImpl(
      {required this.winnerId,
      required final List<FinalScore> finalScores,
      this.tieBreakReason})
      : _finalScores = finalScores;

  @override
  final int winnerId;
  final List<FinalScore> _finalScores;
  @override
  List<FinalScore> get finalScores {
    if (_finalScores is EqualUnmodifiableListView) return _finalScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_finalScores);
  }

  @override
  final String? tieBreakReason;

  @override
  String toString() {
    return 'GameHubEvent.gameOver(winnerId: $winnerId, finalScores: $finalScores, tieBreakReason: $tieBreakReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubGameOverImpl &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            const DeepCollectionEquality()
                .equals(other._finalScores, _finalScores) &&
            (identical(other.tieBreakReason, tieBreakReason) ||
                other.tieBreakReason == tieBreakReason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, winnerId,
      const DeepCollectionEquality().hash(_finalScores), tieBreakReason);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubGameOverImplCopyWith<_$GameHubGameOverImpl> get copyWith =>
      __$$GameHubGameOverImplCopyWithImpl<_$GameHubGameOverImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return gameOver(winnerId, finalScores, tieBreakReason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return gameOver?.call(winnerId, finalScores, tieBreakReason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (gameOver != null) {
      return gameOver(winnerId, finalScores, tieBreakReason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return gameOver(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return gameOver?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (gameOver != null) {
      return gameOver(this);
    }
    return orElse();
  }
}

abstract class GameHubGameOver implements GameHubEvent {
  const factory GameHubGameOver(
      {required final int winnerId,
      required final List<FinalScore> finalScores,
      final String? tieBreakReason}) = _$GameHubGameOverImpl;

  int get winnerId;
  List<FinalScore> get finalScores;
  String? get tieBreakReason;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubGameOverImplCopyWith<_$GameHubGameOverImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubChatMessageImplCopyWith<$Res> {
  factory _$$GameHubChatMessageImplCopyWith(_$GameHubChatMessageImpl value,
          $Res Function(_$GameHubChatMessageImpl) then) =
      __$$GameHubChatMessageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int playerId, String text, DateTime ts});
}

/// @nodoc
class __$$GameHubChatMessageImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubChatMessageImpl>
    implements _$$GameHubChatMessageImplCopyWith<$Res> {
  __$$GameHubChatMessageImplCopyWithImpl(_$GameHubChatMessageImpl _value,
      $Res Function(_$GameHubChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? text = null,
    Object? ts = null,
  }) {
    return _then(_$GameHubChatMessageImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
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

class _$GameHubChatMessageImpl implements GameHubChatMessage {
  const _$GameHubChatMessageImpl(
      {required this.playerId, required this.text, required this.ts});

  @override
  final int playerId;
  @override
  final String text;
  @override
  final DateTime ts;

  @override
  String toString() {
    return 'GameHubEvent.chatMessage(playerId: $playerId, text: $text, ts: $ts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubChatMessageImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.ts, ts) || other.ts == ts));
  }

  @override
  int get hashCode => Object.hash(runtimeType, playerId, text, ts);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubChatMessageImplCopyWith<_$GameHubChatMessageImpl> get copyWith =>
      __$$GameHubChatMessageImplCopyWithImpl<_$GameHubChatMessageImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return chatMessage(playerId, text, ts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return chatMessage?.call(playerId, text, ts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (chatMessage != null) {
      return chatMessage(playerId, text, ts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return chatMessage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return chatMessage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (chatMessage != null) {
      return chatMessage(this);
    }
    return orElse();
  }
}

abstract class GameHubChatMessage implements GameHubEvent {
  const factory GameHubChatMessage(
      {required final int playerId,
      required final String text,
      required final DateTime ts}) = _$GameHubChatMessageImpl;

  int get playerId;
  String get text;
  DateTime get ts;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubChatMessageImplCopyWith<_$GameHubChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubEmoteReceivedImplCopyWith<$Res> {
  factory _$$GameHubEmoteReceivedImplCopyWith(_$GameHubEmoteReceivedImpl value,
          $Res Function(_$GameHubEmoteReceivedImpl) then) =
      __$$GameHubEmoteReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int playerId, String emoteId, DateTime ts});
}

/// @nodoc
class __$$GameHubEmoteReceivedImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubEmoteReceivedImpl>
    implements _$$GameHubEmoteReceivedImplCopyWith<$Res> {
  __$$GameHubEmoteReceivedImplCopyWithImpl(_$GameHubEmoteReceivedImpl _value,
      $Res Function(_$GameHubEmoteReceivedImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? emoteId = null,
    Object? ts = null,
  }) {
    return _then(_$GameHubEmoteReceivedImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as int,
      emoteId: null == emoteId
          ? _value.emoteId
          : emoteId // ignore: cast_nullable_to_non_nullable
              as String,
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$GameHubEmoteReceivedImpl implements GameHubEmoteReceived {
  const _$GameHubEmoteReceivedImpl(
      {required this.playerId, required this.emoteId, required this.ts});

  @override
  final int playerId;
  @override
  final String emoteId;
  @override
  final DateTime ts;

  @override
  String toString() {
    return 'GameHubEvent.emoteReceived(playerId: $playerId, emoteId: $emoteId, ts: $ts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubEmoteReceivedImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.emoteId, emoteId) || other.emoteId == emoteId) &&
            (identical(other.ts, ts) || other.ts == ts));
  }

  @override
  int get hashCode => Object.hash(runtimeType, playerId, emoteId, ts);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubEmoteReceivedImplCopyWith<_$GameHubEmoteReceivedImpl>
      get copyWith =>
          __$$GameHubEmoteReceivedImplCopyWithImpl<_$GameHubEmoteReceivedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return emoteReceived(playerId, emoteId, ts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return emoteReceived?.call(playerId, emoteId, ts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (emoteReceived != null) {
      return emoteReceived(playerId, emoteId, ts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return emoteReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return emoteReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (emoteReceived != null) {
      return emoteReceived(this);
    }
    return orElse();
  }
}

abstract class GameHubEmoteReceived implements GameHubEvent {
  const factory GameHubEmoteReceived(
      {required final int playerId,
      required final String emoteId,
      required final DateTime ts}) = _$GameHubEmoteReceivedImpl;

  int get playerId;
  String get emoteId;
  DateTime get ts;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubEmoteReceivedImplCopyWith<_$GameHubEmoteReceivedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHubErrorOccurredImplCopyWith<$Res> {
  factory _$$GameHubErrorOccurredImplCopyWith(_$GameHubErrorOccurredImpl value,
          $Res Function(_$GameHubErrorOccurredImpl) then) =
      __$$GameHubErrorOccurredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String code, String message});
}

/// @nodoc
class __$$GameHubErrorOccurredImplCopyWithImpl<$Res>
    extends _$GameHubEventCopyWithImpl<$Res, _$GameHubErrorOccurredImpl>
    implements _$$GameHubErrorOccurredImplCopyWith<$Res> {
  __$$GameHubErrorOccurredImplCopyWithImpl(_$GameHubErrorOccurredImpl _value,
      $Res Function(_$GameHubErrorOccurredImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
  }) {
    return _then(_$GameHubErrorOccurredImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GameHubErrorOccurredImpl implements GameHubErrorOccurred {
  const _$GameHubErrorOccurredImpl({required this.code, required this.message});

  @override
  final String code;
  @override
  final String message;

  @override
  String toString() {
    return 'GameHubEvent.errorOccurred(code: $code, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHubErrorOccurredImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code, message);

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHubErrorOccurredImplCopyWith<_$GameHubErrorOccurredImpl>
      get copyWith =>
          __$$GameHubErrorOccurredImplCopyWithImpl<_$GameHubErrorOccurredImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)
        stateSync,
    required TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)
        actionResult,
    required TResult Function(int currentPlayerId, int turnNumber) turnChanged,
    required TResult Function(int playerId, String nobleId) nobleAwarded,
    required TResult Function(int playerId, List<String> candidateNobleIds)
        nobleChoiceRequired,
    required TResult Function(int userId, String nickname) playerJoined,
    required TResult Function(int userId, String nickname) playerLeft,
    required TResult Function(int triggeredBy, int? lastTurnPlayerId)
        finalRoundTriggered,
    required TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)
        gameOver,
    required TResult Function(int playerId, String text, DateTime ts)
        chatMessage,
    required TResult Function(int playerId, String emoteId, DateTime ts)
        emoteReceived,
    required TResult Function(String code, String message) errorOccurred,
  }) {
    return errorOccurred(code, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult? Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult? Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult? Function(int playerId, String nobleId)? nobleAwarded,
    TResult? Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult? Function(int userId, String nickname)? playerJoined,
    TResult? Function(int userId, String nickname)? playerLeft,
    TResult? Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult? Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult? Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult? Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult? Function(String code, String message)? errorOccurred,
  }) {
    return errorOccurred?.call(code, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            GameState? state, List<Map<String, dynamic>>? patch, int sequence)?
        stateSync,
    TResult Function(
            bool success, String? error, List<Map<String, dynamic>>? patch)?
        actionResult,
    TResult Function(int currentPlayerId, int turnNumber)? turnChanged,
    TResult Function(int playerId, String nobleId)? nobleAwarded,
    TResult Function(int playerId, List<String> candidateNobleIds)?
        nobleChoiceRequired,
    TResult Function(int userId, String nickname)? playerJoined,
    TResult Function(int userId, String nickname)? playerLeft,
    TResult Function(int triggeredBy, int? lastTurnPlayerId)?
        finalRoundTriggered,
    TResult Function(
            int winnerId, List<FinalScore> finalScores, String? tieBreakReason)?
        gameOver,
    TResult Function(int playerId, String text, DateTime ts)? chatMessage,
    TResult Function(int playerId, String emoteId, DateTime ts)? emoteReceived,
    TResult Function(String code, String message)? errorOccurred,
    required TResult orElse(),
  }) {
    if (errorOccurred != null) {
      return errorOccurred(code, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHubStateSync value) stateSync,
    required TResult Function(GameHubActionResult value) actionResult,
    required TResult Function(GameHubTurnChanged value) turnChanged,
    required TResult Function(GameHubNobleAwarded value) nobleAwarded,
    required TResult Function(GameHubNobleChoiceRequired value)
        nobleChoiceRequired,
    required TResult Function(GameHubPlayerJoined value) playerJoined,
    required TResult Function(GameHubPlayerLeft value) playerLeft,
    required TResult Function(GameHubFinalRoundTriggered value)
        finalRoundTriggered,
    required TResult Function(GameHubGameOver value) gameOver,
    required TResult Function(GameHubChatMessage value) chatMessage,
    required TResult Function(GameHubEmoteReceived value) emoteReceived,
    required TResult Function(GameHubErrorOccurred value) errorOccurred,
  }) {
    return errorOccurred(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHubStateSync value)? stateSync,
    TResult? Function(GameHubActionResult value)? actionResult,
    TResult? Function(GameHubTurnChanged value)? turnChanged,
    TResult? Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult? Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult? Function(GameHubPlayerJoined value)? playerJoined,
    TResult? Function(GameHubPlayerLeft value)? playerLeft,
    TResult? Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult? Function(GameHubGameOver value)? gameOver,
    TResult? Function(GameHubChatMessage value)? chatMessage,
    TResult? Function(GameHubEmoteReceived value)? emoteReceived,
    TResult? Function(GameHubErrorOccurred value)? errorOccurred,
  }) {
    return errorOccurred?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHubStateSync value)? stateSync,
    TResult Function(GameHubActionResult value)? actionResult,
    TResult Function(GameHubTurnChanged value)? turnChanged,
    TResult Function(GameHubNobleAwarded value)? nobleAwarded,
    TResult Function(GameHubNobleChoiceRequired value)? nobleChoiceRequired,
    TResult Function(GameHubPlayerJoined value)? playerJoined,
    TResult Function(GameHubPlayerLeft value)? playerLeft,
    TResult Function(GameHubFinalRoundTriggered value)? finalRoundTriggered,
    TResult Function(GameHubGameOver value)? gameOver,
    TResult Function(GameHubChatMessage value)? chatMessage,
    TResult Function(GameHubEmoteReceived value)? emoteReceived,
    TResult Function(GameHubErrorOccurred value)? errorOccurred,
    required TResult orElse(),
  }) {
    if (errorOccurred != null) {
      return errorOccurred(this);
    }
    return orElse();
  }
}

abstract class GameHubErrorOccurred implements GameHubEvent {
  const factory GameHubErrorOccurred(
      {required final String code,
      required final String message}) = _$GameHubErrorOccurredImpl;

  String get code;
  String get message;

  /// Create a copy of GameHubEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHubErrorOccurredImplCopyWith<_$GameHubErrorOccurredImpl>
      get copyWith => throw _privateConstructorUsedError;
}
