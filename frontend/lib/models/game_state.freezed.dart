// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BoardTier _$BoardTierFromJson(Map<String, dynamic> json) {
  return _BoardTier.fromJson(json);
}

/// @nodoc
mixin _$BoardTier {
  int get tier => throw _privateConstructorUsedError;
  List<SplendorCard> get visibleCards => throw _privateConstructorUsedError;
  int get deckRemaining => throw _privateConstructorUsedError;

  /// Serializes this BoardTier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoardTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoardTierCopyWith<BoardTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoardTierCopyWith<$Res> {
  factory $BoardTierCopyWith(BoardTier value, $Res Function(BoardTier) then) =
      _$BoardTierCopyWithImpl<$Res, BoardTier>;
  @useResult
  $Res call({int tier, List<SplendorCard> visibleCards, int deckRemaining});
}

/// @nodoc
class _$BoardTierCopyWithImpl<$Res, $Val extends BoardTier>
    implements $BoardTierCopyWith<$Res> {
  _$BoardTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoardTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? visibleCards = null,
    Object? deckRemaining = null,
  }) {
    return _then(_value.copyWith(
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      visibleCards: null == visibleCards
          ? _value.visibleCards
          : visibleCards // ignore: cast_nullable_to_non_nullable
              as List<SplendorCard>,
      deckRemaining: null == deckRemaining
          ? _value.deckRemaining
          : deckRemaining // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoardTierImplCopyWith<$Res>
    implements $BoardTierCopyWith<$Res> {
  factory _$$BoardTierImplCopyWith(
          _$BoardTierImpl value, $Res Function(_$BoardTierImpl) then) =
      __$$BoardTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int tier, List<SplendorCard> visibleCards, int deckRemaining});
}

/// @nodoc
class __$$BoardTierImplCopyWithImpl<$Res>
    extends _$BoardTierCopyWithImpl<$Res, _$BoardTierImpl>
    implements _$$BoardTierImplCopyWith<$Res> {
  __$$BoardTierImplCopyWithImpl(
      _$BoardTierImpl _value, $Res Function(_$BoardTierImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoardTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? visibleCards = null,
    Object? deckRemaining = null,
  }) {
    return _then(_$BoardTierImpl(
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      visibleCards: null == visibleCards
          ? _value._visibleCards
          : visibleCards // ignore: cast_nullable_to_non_nullable
              as List<SplendorCard>,
      deckRemaining: null == deckRemaining
          ? _value.deckRemaining
          : deckRemaining // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoardTierImpl implements _BoardTier {
  const _$BoardTierImpl(
      {required this.tier,
      final List<SplendorCard> visibleCards = const [],
      this.deckRemaining = 0})
      : _visibleCards = visibleCards;

  factory _$BoardTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoardTierImplFromJson(json);

  @override
  final int tier;
  final List<SplendorCard> _visibleCards;
  @override
  @JsonKey()
  List<SplendorCard> get visibleCards {
    if (_visibleCards is EqualUnmodifiableListView) return _visibleCards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visibleCards);
  }

  @override
  @JsonKey()
  final int deckRemaining;

  @override
  String toString() {
    return 'BoardTier(tier: $tier, visibleCards: $visibleCards, deckRemaining: $deckRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoardTierImpl &&
            (identical(other.tier, tier) || other.tier == tier) &&
            const DeepCollectionEquality()
                .equals(other._visibleCards, _visibleCards) &&
            (identical(other.deckRemaining, deckRemaining) ||
                other.deckRemaining == deckRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tier,
      const DeepCollectionEquality().hash(_visibleCards), deckRemaining);

  /// Create a copy of BoardTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoardTierImplCopyWith<_$BoardTierImpl> get copyWith =>
      __$$BoardTierImplCopyWithImpl<_$BoardTierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoardTierImplToJson(
      this,
    );
  }
}

abstract class _BoardTier implements BoardTier {
  const factory _BoardTier(
      {required final int tier,
      final List<SplendorCard> visibleCards,
      final int deckRemaining}) = _$BoardTierImpl;

  factory _BoardTier.fromJson(Map<String, dynamic> json) =
      _$BoardTierImpl.fromJson;

  @override
  int get tier;
  @override
  List<SplendorCard> get visibleCards;
  @override
  int get deckRemaining;

  /// Create a copy of BoardTier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoardTierImplCopyWith<_$BoardTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GamePlayerState _$GamePlayerStateFromJson(Map<String, dynamic> json) {
  return _GamePlayerState.fromJson(json);
}

/// @nodoc
mixin _$GamePlayerState {
  int get userId => throw _privateConstructorUsedError;
  Map<String, int> get tokens =>
      throw _privateConstructorUsedError; // 보유 토큰 (색상 -> 개수, Gold 포함)
  Map<String, int> get bonuses =>
      throw _privateConstructorUsedError; // 구매한 카드로 얻은 할인 (색상 -> 개수)
  List<SplendorCard> get reservedCards => throw _privateConstructorUsedError;
  List<SplendorCard> get purchasedCards => throw _privateConstructorUsedError;
  List<String> get nobles => throw _privateConstructorUsedError; // 획득한 귀족 id 목록
  int get points => throw _privateConstructorUsedError;
  int get totalTokens => throw _privateConstructorUsedError;

  /// Serializes this GamePlayerState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GamePlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamePlayerStateCopyWith<GamePlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamePlayerStateCopyWith<$Res> {
  factory $GamePlayerStateCopyWith(
          GamePlayerState value, $Res Function(GamePlayerState) then) =
      _$GamePlayerStateCopyWithImpl<$Res, GamePlayerState>;
  @useResult
  $Res call(
      {int userId,
      Map<String, int> tokens,
      Map<String, int> bonuses,
      List<SplendorCard> reservedCards,
      List<SplendorCard> purchasedCards,
      List<String> nobles,
      int points,
      int totalTokens});
}

/// @nodoc
class _$GamePlayerStateCopyWithImpl<$Res, $Val extends GamePlayerState>
    implements $GamePlayerStateCopyWith<$Res> {
  _$GamePlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamePlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? tokens = null,
    Object? bonuses = null,
    Object? reservedCards = null,
    Object? purchasedCards = null,
    Object? nobles = null,
    Object? points = null,
    Object? totalTokens = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      bonuses: null == bonuses
          ? _value.bonuses
          : bonuses // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      reservedCards: null == reservedCards
          ? _value.reservedCards
          : reservedCards // ignore: cast_nullable_to_non_nullable
              as List<SplendorCard>,
      purchasedCards: null == purchasedCards
          ? _value.purchasedCards
          : purchasedCards // ignore: cast_nullable_to_non_nullable
              as List<SplendorCard>,
      nobles: null == nobles
          ? _value.nobles
          : nobles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GamePlayerStateImplCopyWith<$Res>
    implements $GamePlayerStateCopyWith<$Res> {
  factory _$$GamePlayerStateImplCopyWith(_$GamePlayerStateImpl value,
          $Res Function(_$GamePlayerStateImpl) then) =
      __$$GamePlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int userId,
      Map<String, int> tokens,
      Map<String, int> bonuses,
      List<SplendorCard> reservedCards,
      List<SplendorCard> purchasedCards,
      List<String> nobles,
      int points,
      int totalTokens});
}

/// @nodoc
class __$$GamePlayerStateImplCopyWithImpl<$Res>
    extends _$GamePlayerStateCopyWithImpl<$Res, _$GamePlayerStateImpl>
    implements _$$GamePlayerStateImplCopyWith<$Res> {
  __$$GamePlayerStateImplCopyWithImpl(
      _$GamePlayerStateImpl _value, $Res Function(_$GamePlayerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GamePlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? tokens = null,
    Object? bonuses = null,
    Object? reservedCards = null,
    Object? purchasedCards = null,
    Object? nobles = null,
    Object? points = null,
    Object? totalTokens = null,
  }) {
    return _then(_$GamePlayerStateImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      tokens: null == tokens
          ? _value._tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      bonuses: null == bonuses
          ? _value._bonuses
          : bonuses // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      reservedCards: null == reservedCards
          ? _value._reservedCards
          : reservedCards // ignore: cast_nullable_to_non_nullable
              as List<SplendorCard>,
      purchasedCards: null == purchasedCards
          ? _value._purchasedCards
          : purchasedCards // ignore: cast_nullable_to_non_nullable
              as List<SplendorCard>,
      nobles: null == nobles
          ? _value._nobles
          : nobles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GamePlayerStateImpl implements _GamePlayerState {
  const _$GamePlayerStateImpl(
      {required this.userId,
      final Map<String, int> tokens = const {},
      final Map<String, int> bonuses = const {},
      final List<SplendorCard> reservedCards = const [],
      final List<SplendorCard> purchasedCards = const [],
      final List<String> nobles = const [],
      this.points = 0,
      this.totalTokens = 0})
      : _tokens = tokens,
        _bonuses = bonuses,
        _reservedCards = reservedCards,
        _purchasedCards = purchasedCards,
        _nobles = nobles;

  factory _$GamePlayerStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GamePlayerStateImplFromJson(json);

  @override
  final int userId;
  final Map<String, int> _tokens;
  @override
  @JsonKey()
  Map<String, int> get tokens {
    if (_tokens is EqualUnmodifiableMapView) return _tokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tokens);
  }

// 보유 토큰 (색상 -> 개수, Gold 포함)
  final Map<String, int> _bonuses;
// 보유 토큰 (색상 -> 개수, Gold 포함)
  @override
  @JsonKey()
  Map<String, int> get bonuses {
    if (_bonuses is EqualUnmodifiableMapView) return _bonuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bonuses);
  }

// 구매한 카드로 얻은 할인 (색상 -> 개수)
  final List<SplendorCard> _reservedCards;
// 구매한 카드로 얻은 할인 (색상 -> 개수)
  @override
  @JsonKey()
  List<SplendorCard> get reservedCards {
    if (_reservedCards is EqualUnmodifiableListView) return _reservedCards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reservedCards);
  }

  final List<SplendorCard> _purchasedCards;
  @override
  @JsonKey()
  List<SplendorCard> get purchasedCards {
    if (_purchasedCards is EqualUnmodifiableListView) return _purchasedCards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_purchasedCards);
  }

  final List<String> _nobles;
  @override
  @JsonKey()
  List<String> get nobles {
    if (_nobles is EqualUnmodifiableListView) return _nobles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nobles);
  }

// 획득한 귀족 id 목록
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final int totalTokens;

  @override
  String toString() {
    return 'GamePlayerState(userId: $userId, tokens: $tokens, bonuses: $bonuses, reservedCards: $reservedCards, purchasedCards: $purchasedCards, nobles: $nobles, points: $points, totalTokens: $totalTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamePlayerStateImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._tokens, _tokens) &&
            const DeepCollectionEquality().equals(other._bonuses, _bonuses) &&
            const DeepCollectionEquality()
                .equals(other._reservedCards, _reservedCards) &&
            const DeepCollectionEquality()
                .equals(other._purchasedCards, _purchasedCards) &&
            const DeepCollectionEquality().equals(other._nobles, _nobles) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      const DeepCollectionEquality().hash(_tokens),
      const DeepCollectionEquality().hash(_bonuses),
      const DeepCollectionEquality().hash(_reservedCards),
      const DeepCollectionEquality().hash(_purchasedCards),
      const DeepCollectionEquality().hash(_nobles),
      points,
      totalTokens);

  /// Create a copy of GamePlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamePlayerStateImplCopyWith<_$GamePlayerStateImpl> get copyWith =>
      __$$GamePlayerStateImplCopyWithImpl<_$GamePlayerStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GamePlayerStateImplToJson(
      this,
    );
  }
}

abstract class _GamePlayerState implements GamePlayerState {
  const factory _GamePlayerState(
      {required final int userId,
      final Map<String, int> tokens,
      final Map<String, int> bonuses,
      final List<SplendorCard> reservedCards,
      final List<SplendorCard> purchasedCards,
      final List<String> nobles,
      final int points,
      final int totalTokens}) = _$GamePlayerStateImpl;

  factory _GamePlayerState.fromJson(Map<String, dynamic> json) =
      _$GamePlayerStateImpl.fromJson;

  @override
  int get userId;
  @override
  Map<String, int> get tokens; // 보유 토큰 (색상 -> 개수, Gold 포함)
  @override
  Map<String, int> get bonuses; // 구매한 카드로 얻은 할인 (색상 -> 개수)
  @override
  List<SplendorCard> get reservedCards;
  @override
  List<SplendorCard> get purchasedCards;
  @override
  List<String> get nobles; // 획득한 귀족 id 목록
  @override
  int get points;
  @override
  int get totalTokens;

  /// Create a copy of GamePlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamePlayerStateImplCopyWith<_$GamePlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return _GameState.fromJson(json);
}

/// @nodoc
mixin _$GameState {
  int get gameId => throw _privateConstructorUsedError;
  List<int> get playerOrder => throw _privateConstructorUsedError;
  Map<String, GamePlayerState> get players =>
      throw _privateConstructorUsedError; // key: userId(문자열)
  Map<String, int> get tokenBank =>
      throw _privateConstructorUsedError; // 보드에 남은 토큰 풀 (색상 -> 개수, Gold 포함)
  Map<String, List<SplendorCard>> get board =>
      throw _privateConstructorUsedError; // key: tier("1"|"2"|"3")
  Map<String, List<SplendorCard>> get decks =>
      throw _privateConstructorUsedError; // key: tier, 남은 카드 전체
  List<Noble> get boardNobles =>
      throw _privateConstructorUsedError; // 보드에 남아있는(아직 획득되지 않은) 귀족
  int get currentPlayerIndex => throw _privateConstructorUsedError;
  int get turnNumber => throw _privateConstructorUsedError;
  GamePhase get phase => throw _privateConstructorUsedError;
  int? get lastTurnPlayerId => throw _privateConstructorUsedError;
  int get sequence =>
      throw _privateConstructorUsedError; // StateSync 델타 적용 순서 검증 및 RequestResync에 사용
  int? get currentPlayerId =>
      throw _privateConstructorUsedError; // 피셔 룰 턴 제한시간(backend/Backend/Game/GameEngine.cs). key: userId(문자열),
// value: 그 유저의 남은 시간뱅크(초, 최대 30). turnDeadlineUtc는 현재 턴이
// 끝나는 UTC 시각이며 게임 종료 시 null.
  Map<String, int> get timeBankSeconds => throw _privateConstructorUsedError;
  DateTime? get turnDeadlineUtc => throw _privateConstructorUsedError;

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call(
      {int gameId,
      List<int> playerOrder,
      Map<String, GamePlayerState> players,
      Map<String, int> tokenBank,
      Map<String, List<SplendorCard>> board,
      Map<String, List<SplendorCard>> decks,
      List<Noble> boardNobles,
      int currentPlayerIndex,
      int turnNumber,
      GamePhase phase,
      int? lastTurnPlayerId,
      int sequence,
      int? currentPlayerId,
      Map<String, int> timeBankSeconds,
      DateTime? turnDeadlineUtc});
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerOrder = null,
    Object? players = null,
    Object? tokenBank = null,
    Object? board = null,
    Object? decks = null,
    Object? boardNobles = null,
    Object? currentPlayerIndex = null,
    Object? turnNumber = null,
    Object? phase = null,
    Object? lastTurnPlayerId = freezed,
    Object? sequence = null,
    Object? currentPlayerId = freezed,
    Object? timeBankSeconds = null,
    Object? turnDeadlineUtc = freezed,
  }) {
    return _then(_value.copyWith(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as int,
      playerOrder: null == playerOrder
          ? _value.playerOrder
          : playerOrder // ignore: cast_nullable_to_non_nullable
              as List<int>,
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as Map<String, GamePlayerState>,
      tokenBank: null == tokenBank
          ? _value.tokenBank
          : tokenBank // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      board: null == board
          ? _value.board
          : board // ignore: cast_nullable_to_non_nullable
              as Map<String, List<SplendorCard>>,
      decks: null == decks
          ? _value.decks
          : decks // ignore: cast_nullable_to_non_nullable
              as Map<String, List<SplendorCard>>,
      boardNobles: null == boardNobles
          ? _value.boardNobles
          : boardNobles // ignore: cast_nullable_to_non_nullable
              as List<Noble>,
      currentPlayerIndex: null == currentPlayerIndex
          ? _value.currentPlayerIndex
          : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
              as int,
      turnNumber: null == turnNumber
          ? _value.turnNumber
          : turnNumber // ignore: cast_nullable_to_non_nullable
              as int,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as GamePhase,
      lastTurnPlayerId: freezed == lastTurnPlayerId
          ? _value.lastTurnPlayerId
          : lastTurnPlayerId // ignore: cast_nullable_to_non_nullable
              as int?,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      currentPlayerId: freezed == currentPlayerId
          ? _value.currentPlayerId
          : currentPlayerId // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBankSeconds: null == timeBankSeconds
          ? _value.timeBankSeconds
          : timeBankSeconds // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      turnDeadlineUtc: freezed == turnDeadlineUtc
          ? _value.turnDeadlineUtc
          : turnDeadlineUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
          _$GameStateImpl value, $Res Function(_$GameStateImpl) then) =
      __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int gameId,
      List<int> playerOrder,
      Map<String, GamePlayerState> players,
      Map<String, int> tokenBank,
      Map<String, List<SplendorCard>> board,
      Map<String, List<SplendorCard>> decks,
      List<Noble> boardNobles,
      int currentPlayerIndex,
      int turnNumber,
      GamePhase phase,
      int? lastTurnPlayerId,
      int sequence,
      int? currentPlayerId,
      Map<String, int> timeBankSeconds,
      DateTime? turnDeadlineUtc});
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
      _$GameStateImpl _value, $Res Function(_$GameStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerOrder = null,
    Object? players = null,
    Object? tokenBank = null,
    Object? board = null,
    Object? decks = null,
    Object? boardNobles = null,
    Object? currentPlayerIndex = null,
    Object? turnNumber = null,
    Object? phase = null,
    Object? lastTurnPlayerId = freezed,
    Object? sequence = null,
    Object? currentPlayerId = freezed,
    Object? timeBankSeconds = null,
    Object? turnDeadlineUtc = freezed,
  }) {
    return _then(_$GameStateImpl(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as int,
      playerOrder: null == playerOrder
          ? _value._playerOrder
          : playerOrder // ignore: cast_nullable_to_non_nullable
              as List<int>,
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as Map<String, GamePlayerState>,
      tokenBank: null == tokenBank
          ? _value._tokenBank
          : tokenBank // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      board: null == board
          ? _value._board
          : board // ignore: cast_nullable_to_non_nullable
              as Map<String, List<SplendorCard>>,
      decks: null == decks
          ? _value._decks
          : decks // ignore: cast_nullable_to_non_nullable
              as Map<String, List<SplendorCard>>,
      boardNobles: null == boardNobles
          ? _value._boardNobles
          : boardNobles // ignore: cast_nullable_to_non_nullable
              as List<Noble>,
      currentPlayerIndex: null == currentPlayerIndex
          ? _value.currentPlayerIndex
          : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
              as int,
      turnNumber: null == turnNumber
          ? _value.turnNumber
          : turnNumber // ignore: cast_nullable_to_non_nullable
              as int,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as GamePhase,
      lastTurnPlayerId: freezed == lastTurnPlayerId
          ? _value.lastTurnPlayerId
          : lastTurnPlayerId // ignore: cast_nullable_to_non_nullable
              as int?,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      currentPlayerId: freezed == currentPlayerId
          ? _value.currentPlayerId
          : currentPlayerId // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBankSeconds: null == timeBankSeconds
          ? _value._timeBankSeconds
          : timeBankSeconds // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      turnDeadlineUtc: freezed == turnDeadlineUtc
          ? _value.turnDeadlineUtc
          : turnDeadlineUtc // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateImpl extends _GameState {
  const _$GameStateImpl(
      {required this.gameId,
      final List<int> playerOrder = const [],
      final Map<String, GamePlayerState> players = const {},
      final Map<String, int> tokenBank = const {},
      final Map<String, List<SplendorCard>> board = const {},
      final Map<String, List<SplendorCard>> decks = const {},
      final List<Noble> boardNobles = const [],
      this.currentPlayerIndex = 0,
      this.turnNumber = 1,
      required this.phase,
      this.lastTurnPlayerId,
      required this.sequence,
      this.currentPlayerId,
      final Map<String, int> timeBankSeconds = const {},
      this.turnDeadlineUtc})
      : _playerOrder = playerOrder,
        _players = players,
        _tokenBank = tokenBank,
        _board = board,
        _decks = decks,
        _boardNobles = boardNobles,
        _timeBankSeconds = timeBankSeconds,
        super._();

  factory _$GameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateImplFromJson(json);

  @override
  final int gameId;
  final List<int> _playerOrder;
  @override
  @JsonKey()
  List<int> get playerOrder {
    if (_playerOrder is EqualUnmodifiableListView) return _playerOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerOrder);
  }

  final Map<String, GamePlayerState> _players;
  @override
  @JsonKey()
  Map<String, GamePlayerState> get players {
    if (_players is EqualUnmodifiableMapView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_players);
  }

// key: userId(문자열)
  final Map<String, int> _tokenBank;
// key: userId(문자열)
  @override
  @JsonKey()
  Map<String, int> get tokenBank {
    if (_tokenBank is EqualUnmodifiableMapView) return _tokenBank;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tokenBank);
  }

// 보드에 남은 토큰 풀 (색상 -> 개수, Gold 포함)
  final Map<String, List<SplendorCard>> _board;
// 보드에 남은 토큰 풀 (색상 -> 개수, Gold 포함)
  @override
  @JsonKey()
  Map<String, List<SplendorCard>> get board {
    if (_board is EqualUnmodifiableMapView) return _board;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_board);
  }

// key: tier("1"|"2"|"3")
  final Map<String, List<SplendorCard>> _decks;
// key: tier("1"|"2"|"3")
  @override
  @JsonKey()
  Map<String, List<SplendorCard>> get decks {
    if (_decks is EqualUnmodifiableMapView) return _decks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_decks);
  }

// key: tier, 남은 카드 전체
  final List<Noble> _boardNobles;
// key: tier, 남은 카드 전체
  @override
  @JsonKey()
  List<Noble> get boardNobles {
    if (_boardNobles is EqualUnmodifiableListView) return _boardNobles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boardNobles);
  }

// 보드에 남아있는(아직 획득되지 않은) 귀족
  @override
  @JsonKey()
  final int currentPlayerIndex;
  @override
  @JsonKey()
  final int turnNumber;
  @override
  final GamePhase phase;
  @override
  final int? lastTurnPlayerId;
  @override
  final int sequence;
// StateSync 델타 적용 순서 검증 및 RequestResync에 사용
  @override
  final int? currentPlayerId;
// 피셔 룰 턴 제한시간(backend/Backend/Game/GameEngine.cs). key: userId(문자열),
// value: 그 유저의 남은 시간뱅크(초, 최대 30). turnDeadlineUtc는 현재 턴이
// 끝나는 UTC 시각이며 게임 종료 시 null.
  final Map<String, int> _timeBankSeconds;
// 피셔 룰 턴 제한시간(backend/Backend/Game/GameEngine.cs). key: userId(문자열),
// value: 그 유저의 남은 시간뱅크(초, 최대 30). turnDeadlineUtc는 현재 턴이
// 끝나는 UTC 시각이며 게임 종료 시 null.
  @override
  @JsonKey()
  Map<String, int> get timeBankSeconds {
    if (_timeBankSeconds is EqualUnmodifiableMapView) return _timeBankSeconds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_timeBankSeconds);
  }

  @override
  final DateTime? turnDeadlineUtc;

  @override
  String toString() {
    return 'GameState(gameId: $gameId, playerOrder: $playerOrder, players: $players, tokenBank: $tokenBank, board: $board, decks: $decks, boardNobles: $boardNobles, currentPlayerIndex: $currentPlayerIndex, turnNumber: $turnNumber, phase: $phase, lastTurnPlayerId: $lastTurnPlayerId, sequence: $sequence, currentPlayerId: $currentPlayerId, timeBankSeconds: $timeBankSeconds, turnDeadlineUtc: $turnDeadlineUtc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            const DeepCollectionEquality()
                .equals(other._playerOrder, _playerOrder) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            const DeepCollectionEquality()
                .equals(other._tokenBank, _tokenBank) &&
            const DeepCollectionEquality().equals(other._board, _board) &&
            const DeepCollectionEquality().equals(other._decks, _decks) &&
            const DeepCollectionEquality()
                .equals(other._boardNobles, _boardNobles) &&
            (identical(other.currentPlayerIndex, currentPlayerIndex) ||
                other.currentPlayerIndex == currentPlayerIndex) &&
            (identical(other.turnNumber, turnNumber) ||
                other.turnNumber == turnNumber) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.lastTurnPlayerId, lastTurnPlayerId) ||
                other.lastTurnPlayerId == lastTurnPlayerId) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.currentPlayerId, currentPlayerId) ||
                other.currentPlayerId == currentPlayerId) &&
            const DeepCollectionEquality()
                .equals(other._timeBankSeconds, _timeBankSeconds) &&
            (identical(other.turnDeadlineUtc, turnDeadlineUtc) ||
                other.turnDeadlineUtc == turnDeadlineUtc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      gameId,
      const DeepCollectionEquality().hash(_playerOrder),
      const DeepCollectionEquality().hash(_players),
      const DeepCollectionEquality().hash(_tokenBank),
      const DeepCollectionEquality().hash(_board),
      const DeepCollectionEquality().hash(_decks),
      const DeepCollectionEquality().hash(_boardNobles),
      currentPlayerIndex,
      turnNumber,
      phase,
      lastTurnPlayerId,
      sequence,
      currentPlayerId,
      const DeepCollectionEquality().hash(_timeBankSeconds),
      turnDeadlineUtc);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateImplToJson(
      this,
    );
  }
}

abstract class _GameState extends GameState {
  const factory _GameState(
      {required final int gameId,
      final List<int> playerOrder,
      final Map<String, GamePlayerState> players,
      final Map<String, int> tokenBank,
      final Map<String, List<SplendorCard>> board,
      final Map<String, List<SplendorCard>> decks,
      final List<Noble> boardNobles,
      final int currentPlayerIndex,
      final int turnNumber,
      required final GamePhase phase,
      final int? lastTurnPlayerId,
      required final int sequence,
      final int? currentPlayerId,
      final Map<String, int> timeBankSeconds,
      final DateTime? turnDeadlineUtc}) = _$GameStateImpl;
  const _GameState._() : super._();

  factory _GameState.fromJson(Map<String, dynamic> json) =
      _$GameStateImpl.fromJson;

  @override
  int get gameId;
  @override
  List<int> get playerOrder;
  @override
  Map<String, GamePlayerState> get players; // key: userId(문자열)
  @override
  Map<String, int> get tokenBank; // 보드에 남은 토큰 풀 (색상 -> 개수, Gold 포함)
  @override
  Map<String, List<SplendorCard>> get board; // key: tier("1"|"2"|"3")
  @override
  Map<String, List<SplendorCard>> get decks; // key: tier, 남은 카드 전체
  @override
  List<Noble> get boardNobles; // 보드에 남아있는(아직 획득되지 않은) 귀족
  @override
  int get currentPlayerIndex;
  @override
  int get turnNumber;
  @override
  GamePhase get phase;
  @override
  int? get lastTurnPlayerId;
  @override
  int get sequence; // StateSync 델타 적용 순서 검증 및 RequestResync에 사용
  @override
  int?
      get currentPlayerId; // 피셔 룰 턴 제한시간(backend/Backend/Game/GameEngine.cs). key: userId(문자열),
// value: 그 유저의 남은 시간뱅크(초, 최대 30). turnDeadlineUtc는 현재 턴이
// 끝나는 UTC 시각이며 게임 종료 시 null.
  @override
  Map<String, int> get timeBankSeconds;
  @override
  DateTime? get turnDeadlineUtc;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
