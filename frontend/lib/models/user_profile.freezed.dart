// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RankingSummary _$RankingSummaryFromJson(Map<String, dynamic> json) {
  return _RankingSummary.fromJson(json);
}

/// @nodoc
mixin _$RankingSummary {
  int get rank => throw _privateConstructorUsedError;
  int get mmr => throw _privateConstructorUsedError;
  int get gamesPlayedSeason => throw _privateConstructorUsedError;
  double get avgPlace => throw _privateConstructorUsedError;

  /// Serializes this RankingSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RankingSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingSummaryCopyWith<RankingSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingSummaryCopyWith<$Res> {
  factory $RankingSummaryCopyWith(
          RankingSummary value, $Res Function(RankingSummary) then) =
      _$RankingSummaryCopyWithImpl<$Res, RankingSummary>;
  @useResult
  $Res call({int rank, int mmr, int gamesPlayedSeason, double avgPlace});
}

/// @nodoc
class _$RankingSummaryCopyWithImpl<$Res, $Val extends RankingSummary>
    implements $RankingSummaryCopyWith<$Res> {
  _$RankingSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? mmr = null,
    Object? gamesPlayedSeason = null,
    Object? avgPlace = null,
  }) {
    return _then(_value.copyWith(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      mmr: null == mmr
          ? _value.mmr
          : mmr // ignore: cast_nullable_to_non_nullable
              as int,
      gamesPlayedSeason: null == gamesPlayedSeason
          ? _value.gamesPlayedSeason
          : gamesPlayedSeason // ignore: cast_nullable_to_non_nullable
              as int,
      avgPlace: null == avgPlace
          ? _value.avgPlace
          : avgPlace // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RankingSummaryImplCopyWith<$Res>
    implements $RankingSummaryCopyWith<$Res> {
  factory _$$RankingSummaryImplCopyWith(_$RankingSummaryImpl value,
          $Res Function(_$RankingSummaryImpl) then) =
      __$$RankingSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rank, int mmr, int gamesPlayedSeason, double avgPlace});
}

/// @nodoc
class __$$RankingSummaryImplCopyWithImpl<$Res>
    extends _$RankingSummaryCopyWithImpl<$Res, _$RankingSummaryImpl>
    implements _$$RankingSummaryImplCopyWith<$Res> {
  __$$RankingSummaryImplCopyWithImpl(
      _$RankingSummaryImpl _value, $Res Function(_$RankingSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of RankingSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? mmr = null,
    Object? gamesPlayedSeason = null,
    Object? avgPlace = null,
  }) {
    return _then(_$RankingSummaryImpl(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      mmr: null == mmr
          ? _value.mmr
          : mmr // ignore: cast_nullable_to_non_nullable
              as int,
      gamesPlayedSeason: null == gamesPlayedSeason
          ? _value.gamesPlayedSeason
          : gamesPlayedSeason // ignore: cast_nullable_to_non_nullable
              as int,
      avgPlace: null == avgPlace
          ? _value.avgPlace
          : avgPlace // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RankingSummaryImpl implements _RankingSummary {
  const _$RankingSummaryImpl(
      {required this.rank,
      required this.mmr,
      required this.gamesPlayedSeason,
      required this.avgPlace});

  factory _$RankingSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RankingSummaryImplFromJson(json);

  @override
  final int rank;
  @override
  final int mmr;
  @override
  final int gamesPlayedSeason;
  @override
  final double avgPlace;

  @override
  String toString() {
    return 'RankingSummary(rank: $rank, mmr: $mmr, gamesPlayedSeason: $gamesPlayedSeason, avgPlace: $avgPlace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingSummaryImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.mmr, mmr) || other.mmr == mmr) &&
            (identical(other.gamesPlayedSeason, gamesPlayedSeason) ||
                other.gamesPlayedSeason == gamesPlayedSeason) &&
            (identical(other.avgPlace, avgPlace) ||
                other.avgPlace == avgPlace));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rank, mmr, gamesPlayedSeason, avgPlace);

  /// Create a copy of RankingSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingSummaryImplCopyWith<_$RankingSummaryImpl> get copyWith =>
      __$$RankingSummaryImplCopyWithImpl<_$RankingSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RankingSummaryImplToJson(
      this,
    );
  }
}

abstract class _RankingSummary implements RankingSummary {
  const factory _RankingSummary(
      {required final int rank,
      required final int mmr,
      required final int gamesPlayedSeason,
      required final double avgPlace}) = _$RankingSummaryImpl;

  factory _RankingSummary.fromJson(Map<String, dynamic> json) =
      _$RankingSummaryImpl.fromJson;

  @override
  int get rank;
  @override
  int get mmr;
  @override
  int get gamesPlayedSeason;
  @override
  double get avgPlace;

  /// Create a copy of RankingSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingSummaryImplCopyWith<_$RankingSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentGame _$RecentGameFromJson(Map<String, dynamic> json) {
  return _RecentGame.fromJson(json);
}

/// @nodoc
mixin _$RecentGame {
  int get gameId => throw _privateConstructorUsedError;
  int get playersNumber => throw _privateConstructorUsedError;
  String get gameType =>
      throw _privateConstructorUsedError; // "Ranked" | "Unranked"
  int get place => throw _privateConstructorUsedError;

  /// Serializes this RecentGame to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentGame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentGameCopyWith<RecentGame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentGameCopyWith<$Res> {
  factory $RecentGameCopyWith(
          RecentGame value, $Res Function(RecentGame) then) =
      _$RecentGameCopyWithImpl<$Res, RecentGame>;
  @useResult
  $Res call({int gameId, int playersNumber, String gameType, int place});
}

/// @nodoc
class _$RecentGameCopyWithImpl<$Res, $Val extends RecentGame>
    implements $RecentGameCopyWith<$Res> {
  _$RecentGameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentGame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playersNumber = null,
    Object? gameType = null,
    Object? place = null,
  }) {
    return _then(_value.copyWith(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as int,
      playersNumber: null == playersNumber
          ? _value.playersNumber
          : playersNumber // ignore: cast_nullable_to_non_nullable
              as int,
      gameType: null == gameType
          ? _value.gameType
          : gameType // ignore: cast_nullable_to_non_nullable
              as String,
      place: null == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentGameImplCopyWith<$Res>
    implements $RecentGameCopyWith<$Res> {
  factory _$$RecentGameImplCopyWith(
          _$RecentGameImpl value, $Res Function(_$RecentGameImpl) then) =
      __$$RecentGameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int gameId, int playersNumber, String gameType, int place});
}

/// @nodoc
class __$$RecentGameImplCopyWithImpl<$Res>
    extends _$RecentGameCopyWithImpl<$Res, _$RecentGameImpl>
    implements _$$RecentGameImplCopyWith<$Res> {
  __$$RecentGameImplCopyWithImpl(
      _$RecentGameImpl _value, $Res Function(_$RecentGameImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecentGame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playersNumber = null,
    Object? gameType = null,
    Object? place = null,
  }) {
    return _then(_$RecentGameImpl(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as int,
      playersNumber: null == playersNumber
          ? _value.playersNumber
          : playersNumber // ignore: cast_nullable_to_non_nullable
              as int,
      gameType: null == gameType
          ? _value.gameType
          : gameType // ignore: cast_nullable_to_non_nullable
              as String,
      place: null == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentGameImpl implements _RecentGame {
  const _$RecentGameImpl(
      {required this.gameId,
      required this.playersNumber,
      required this.gameType,
      required this.place});

  factory _$RecentGameImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentGameImplFromJson(json);

  @override
  final int gameId;
  @override
  final int playersNumber;
  @override
  final String gameType;
// "Ranked" | "Unranked"
  @override
  final int place;

  @override
  String toString() {
    return 'RecentGame(gameId: $gameId, playersNumber: $playersNumber, gameType: $gameType, place: $place)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentGameImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.playersNumber, playersNumber) ||
                other.playersNumber == playersNumber) &&
            (identical(other.gameType, gameType) ||
                other.gameType == gameType) &&
            (identical(other.place, place) || other.place == place));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, gameId, playersNumber, gameType, place);

  /// Create a copy of RecentGame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentGameImplCopyWith<_$RecentGameImpl> get copyWith =>
      __$$RecentGameImplCopyWithImpl<_$RecentGameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentGameImplToJson(
      this,
    );
  }
}

abstract class _RecentGame implements RecentGame {
  const factory _RecentGame(
      {required final int gameId,
      required final int playersNumber,
      required final String gameType,
      required final int place}) = _$RecentGameImpl;

  factory _RecentGame.fromJson(Map<String, dynamic> json) =
      _$RecentGameImpl.fromJson;

  @override
  int get gameId;
  @override
  int get playersNumber;
  @override
  String get gameType; // "Ranked" | "Unranked"
  @override
  int get place;

  /// Create a copy of RecentGame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentGameImplCopyWith<_$RecentGameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  int get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<RecentGame> get recentGames =>
      throw _privateConstructorUsedError; // key: 인원수 문자열("2"|"3"|"4")
  Map<String, RankingSummary> get rankings =>
      throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {int userId,
      String nickname,
      String? avatarUrl,
      DateTime createdAt,
      List<RecentGame> recentGames,
      Map<String, RankingSummary> rankings});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? recentGames = null,
    Object? rankings = null,
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recentGames: null == recentGames
          ? _value.recentGames
          : recentGames // ignore: cast_nullable_to_non_nullable
              as List<RecentGame>,
      rankings: null == rankings
          ? _value.rankings
          : rankings // ignore: cast_nullable_to_non_nullable
              as Map<String, RankingSummary>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int userId,
      String nickname,
      String? avatarUrl,
      DateTime createdAt,
      List<RecentGame> recentGames,
      Map<String, RankingSummary> rankings});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? recentGames = null,
    Object? rankings = null,
  }) {
    return _then(_$UserProfileImpl(
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recentGames: null == recentGames
          ? _value._recentGames
          : recentGames // ignore: cast_nullable_to_non_nullable
              as List<RecentGame>,
      rankings: null == rankings
          ? _value._rankings
          : rankings // ignore: cast_nullable_to_non_nullable
              as Map<String, RankingSummary>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.userId,
      required this.nickname,
      this.avatarUrl,
      required this.createdAt,
      final List<RecentGame> recentGames = const [],
      final Map<String, RankingSummary> rankings = const {}})
      : _recentGames = recentGames,
        _rankings = rankings;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final int userId;
  @override
  final String nickname;
  @override
  final String? avatarUrl;
  @override
  final DateTime createdAt;
  final List<RecentGame> _recentGames;
  @override
  @JsonKey()
  List<RecentGame> get recentGames {
    if (_recentGames is EqualUnmodifiableListView) return _recentGames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentGames);
  }

// key: 인원수 문자열("2"|"3"|"4")
  final Map<String, RankingSummary> _rankings;
// key: 인원수 문자열("2"|"3"|"4")
  @override
  @JsonKey()
  Map<String, RankingSummary> get rankings {
    if (_rankings is EqualUnmodifiableMapView) return _rankings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rankings);
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, nickname: $nickname, avatarUrl: $avatarUrl, createdAt: $createdAt, recentGames: $recentGames, rankings: $rankings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._recentGames, _recentGames) &&
            const DeepCollectionEquality().equals(other._rankings, _rankings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      nickname,
      avatarUrl,
      createdAt,
      const DeepCollectionEquality().hash(_recentGames),
      const DeepCollectionEquality().hash(_rankings));

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final int userId,
      required final String nickname,
      final String? avatarUrl,
      required final DateTime createdAt,
      final List<RecentGame> recentGames,
      final Map<String, RankingSummary> rankings}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  int get userId;
  @override
  String get nickname;
  @override
  String? get avatarUrl;
  @override
  DateTime get createdAt;
  @override
  List<RecentGame> get recentGames; // key: 인원수 문자열("2"|"3"|"4")
  @override
  Map<String, RankingSummary> get rankings;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
