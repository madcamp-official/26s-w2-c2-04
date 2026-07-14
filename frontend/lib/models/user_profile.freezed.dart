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
  int get playerCount => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  int get mmr => throw _privateConstructorUsedError;
  int get gamesPlayed => throw _privateConstructorUsedError;
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
  $Res call(
      {int playerCount, int rank, int mmr, int gamesPlayed, double avgPlace});
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
    Object? playerCount = null,
    Object? rank = null,
    Object? mmr = null,
    Object? gamesPlayed = null,
    Object? avgPlace = null,
  }) {
    return _then(_value.copyWith(
      playerCount: null == playerCount
          ? _value.playerCount
          : playerCount // ignore: cast_nullable_to_non_nullable
              as int,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      mmr: null == mmr
          ? _value.mmr
          : mmr // ignore: cast_nullable_to_non_nullable
              as int,
      gamesPlayed: null == gamesPlayed
          ? _value.gamesPlayed
          : gamesPlayed // ignore: cast_nullable_to_non_nullable
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
  $Res call(
      {int playerCount, int rank, int mmr, int gamesPlayed, double avgPlace});
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
    Object? playerCount = null,
    Object? rank = null,
    Object? mmr = null,
    Object? gamesPlayed = null,
    Object? avgPlace = null,
  }) {
    return _then(_$RankingSummaryImpl(
      playerCount: null == playerCount
          ? _value.playerCount
          : playerCount // ignore: cast_nullable_to_non_nullable
              as int,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      mmr: null == mmr
          ? _value.mmr
          : mmr // ignore: cast_nullable_to_non_nullable
              as int,
      gamesPlayed: null == gamesPlayed
          ? _value.gamesPlayed
          : gamesPlayed // ignore: cast_nullable_to_non_nullable
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
      {required this.playerCount,
      required this.rank,
      required this.mmr,
      required this.gamesPlayed,
      required this.avgPlace});

  factory _$RankingSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RankingSummaryImplFromJson(json);

  @override
  final int playerCount;
  @override
  final int rank;
  @override
  final int mmr;
  @override
  final int gamesPlayed;
  @override
  final double avgPlace;

  @override
  String toString() {
    return 'RankingSummary(playerCount: $playerCount, rank: $rank, mmr: $mmr, gamesPlayed: $gamesPlayed, avgPlace: $avgPlace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingSummaryImpl &&
            (identical(other.playerCount, playerCount) ||
                other.playerCount == playerCount) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.mmr, mmr) || other.mmr == mmr) &&
            (identical(other.gamesPlayed, gamesPlayed) ||
                other.gamesPlayed == gamesPlayed) &&
            (identical(other.avgPlace, avgPlace) ||
                other.avgPlace == avgPlace));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, playerCount, rank, mmr, gamesPlayed, avgPlace);

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
      {required final int playerCount,
      required final int rank,
      required final int mmr,
      required final int gamesPlayed,
      required final double avgPlace}) = _$RankingSummaryImpl;

  factory _RankingSummary.fromJson(Map<String, dynamic> json) =
      _$RankingSummaryImpl.fromJson;

  @override
  int get playerCount;
  @override
  int get rank;
  @override
  int get mmr;
  @override
  int get gamesPlayed;
  @override
  double get avgPlace;

  /// Create a copy of RankingSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingSummaryImplCopyWith<_$RankingSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentMatch _$RecentMatchFromJson(Map<String, dynamic> json) {
  return _RecentMatch.fromJson(json);
}

/// @nodoc
mixin _$RecentMatch {
  int get gameId => throw _privateConstructorUsedError;
  int get playerCount => throw _privateConstructorUsedError;
  int get place => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  bool get isRanked => throw _privateConstructorUsedError;
  DateTime get playedAt => throw _privateConstructorUsedError;

  /// Serializes this RecentMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentMatchCopyWith<RecentMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentMatchCopyWith<$Res> {
  factory $RecentMatchCopyWith(
          RecentMatch value, $Res Function(RecentMatch) then) =
      _$RecentMatchCopyWithImpl<$Res, RecentMatch>;
  @useResult
  $Res call(
      {int gameId,
      int playerCount,
      int place,
      int score,
      bool isRanked,
      DateTime playedAt});
}

/// @nodoc
class _$RecentMatchCopyWithImpl<$Res, $Val extends RecentMatch>
    implements $RecentMatchCopyWith<$Res> {
  _$RecentMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerCount = null,
    Object? place = null,
    Object? score = null,
    Object? isRanked = null,
    Object? playedAt = null,
  }) {
    return _then(_value.copyWith(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as int,
      playerCount: null == playerCount
          ? _value.playerCount
          : playerCount // ignore: cast_nullable_to_non_nullable
              as int,
      place: null == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      isRanked: null == isRanked
          ? _value.isRanked
          : isRanked // ignore: cast_nullable_to_non_nullable
              as bool,
      playedAt: null == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentMatchImplCopyWith<$Res>
    implements $RecentMatchCopyWith<$Res> {
  factory _$$RecentMatchImplCopyWith(
          _$RecentMatchImpl value, $Res Function(_$RecentMatchImpl) then) =
      __$$RecentMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int gameId,
      int playerCount,
      int place,
      int score,
      bool isRanked,
      DateTime playedAt});
}

/// @nodoc
class __$$RecentMatchImplCopyWithImpl<$Res>
    extends _$RecentMatchCopyWithImpl<$Res, _$RecentMatchImpl>
    implements _$$RecentMatchImplCopyWith<$Res> {
  __$$RecentMatchImplCopyWithImpl(
      _$RecentMatchImpl _value, $Res Function(_$RecentMatchImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecentMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerCount = null,
    Object? place = null,
    Object? score = null,
    Object? isRanked = null,
    Object? playedAt = null,
  }) {
    return _then(_$RecentMatchImpl(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as int,
      playerCount: null == playerCount
          ? _value.playerCount
          : playerCount // ignore: cast_nullable_to_non_nullable
              as int,
      place: null == place
          ? _value.place
          : place // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      isRanked: null == isRanked
          ? _value.isRanked
          : isRanked // ignore: cast_nullable_to_non_nullable
              as bool,
      playedAt: null == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentMatchImpl implements _RecentMatch {
  const _$RecentMatchImpl(
      {required this.gameId,
      required this.playerCount,
      required this.place,
      required this.score,
      required this.isRanked,
      required this.playedAt});

  factory _$RecentMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentMatchImplFromJson(json);

  @override
  final int gameId;
  @override
  final int playerCount;
  @override
  final int place;
  @override
  final int score;
  @override
  final bool isRanked;
  @override
  final DateTime playedAt;

  @override
  String toString() {
    return 'RecentMatch(gameId: $gameId, playerCount: $playerCount, place: $place, score: $score, isRanked: $isRanked, playedAt: $playedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentMatchImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.playerCount, playerCount) ||
                other.playerCount == playerCount) &&
            (identical(other.place, place) || other.place == place) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.isRanked, isRanked) ||
                other.isRanked == isRanked) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, gameId, playerCount, place, score, isRanked, playedAt);

  /// Create a copy of RecentMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentMatchImplCopyWith<_$RecentMatchImpl> get copyWith =>
      __$$RecentMatchImplCopyWithImpl<_$RecentMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentMatchImplToJson(
      this,
    );
  }
}

abstract class _RecentMatch implements RecentMatch {
  const factory _RecentMatch(
      {required final int gameId,
      required final int playerCount,
      required final int place,
      required final int score,
      required final bool isRanked,
      required final DateTime playedAt}) = _$RecentMatchImpl;

  factory _RecentMatch.fromJson(Map<String, dynamic> json) =
      _$RecentMatchImpl.fromJson;

  @override
  int get gameId;
  @override
  int get playerCount;
  @override
  int get place;
  @override
  int get score;
  @override
  bool get isRanked;
  @override
  DateTime get playedAt;

  /// Create a copy of RecentMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentMatchImplCopyWith<_$RecentMatchImpl> get copyWith =>
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
  int get totalGamesPlayed => throw _privateConstructorUsedError;
  double get overallAvgPlace => throw _privateConstructorUsedError;
  List<RankingSummary> get rankings => throw _privateConstructorUsedError;
  List<RecentMatch> get recentMatches => throw _privateConstructorUsedError;

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
      int totalGamesPlayed,
      double overallAvgPlace,
      List<RankingSummary> rankings,
      List<RecentMatch> recentMatches});
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
    Object? totalGamesPlayed = null,
    Object? overallAvgPlace = null,
    Object? rankings = null,
    Object? recentMatches = null,
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
      totalGamesPlayed: null == totalGamesPlayed
          ? _value.totalGamesPlayed
          : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      overallAvgPlace: null == overallAvgPlace
          ? _value.overallAvgPlace
          : overallAvgPlace // ignore: cast_nullable_to_non_nullable
              as double,
      rankings: null == rankings
          ? _value.rankings
          : rankings // ignore: cast_nullable_to_non_nullable
              as List<RankingSummary>,
      recentMatches: null == recentMatches
          ? _value.recentMatches
          : recentMatches // ignore: cast_nullable_to_non_nullable
              as List<RecentMatch>,
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
      int totalGamesPlayed,
      double overallAvgPlace,
      List<RankingSummary> rankings,
      List<RecentMatch> recentMatches});
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
    Object? totalGamesPlayed = null,
    Object? overallAvgPlace = null,
    Object? rankings = null,
    Object? recentMatches = null,
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
      totalGamesPlayed: null == totalGamesPlayed
          ? _value.totalGamesPlayed
          : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      overallAvgPlace: null == overallAvgPlace
          ? _value.overallAvgPlace
          : overallAvgPlace // ignore: cast_nullable_to_non_nullable
              as double,
      rankings: null == rankings
          ? _value._rankings
          : rankings // ignore: cast_nullable_to_non_nullable
              as List<RankingSummary>,
      recentMatches: null == recentMatches
          ? _value._recentMatches
          : recentMatches // ignore: cast_nullable_to_non_nullable
              as List<RecentMatch>,
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
      this.totalGamesPlayed = 0,
      this.overallAvgPlace = 0,
      final List<RankingSummary> rankings = const [],
      final List<RecentMatch> recentMatches = const []})
      : _rankings = rankings,
        _recentMatches = recentMatches;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final int userId;
  @override
  final String nickname;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final int totalGamesPlayed;
  @override
  @JsonKey()
  final double overallAvgPlace;
  final List<RankingSummary> _rankings;
  @override
  @JsonKey()
  List<RankingSummary> get rankings {
    if (_rankings is EqualUnmodifiableListView) return _rankings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rankings);
  }

  final List<RecentMatch> _recentMatches;
  @override
  @JsonKey()
  List<RecentMatch> get recentMatches {
    if (_recentMatches is EqualUnmodifiableListView) return _recentMatches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentMatches);
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, nickname: $nickname, avatarUrl: $avatarUrl, totalGamesPlayed: $totalGamesPlayed, overallAvgPlace: $overallAvgPlace, rankings: $rankings, recentMatches: $recentMatches)';
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
            (identical(other.totalGamesPlayed, totalGamesPlayed) ||
                other.totalGamesPlayed == totalGamesPlayed) &&
            (identical(other.overallAvgPlace, overallAvgPlace) ||
                other.overallAvgPlace == overallAvgPlace) &&
            const DeepCollectionEquality().equals(other._rankings, _rankings) &&
            const DeepCollectionEquality()
                .equals(other._recentMatches, _recentMatches));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      nickname,
      avatarUrl,
      totalGamesPlayed,
      overallAvgPlace,
      const DeepCollectionEquality().hash(_rankings),
      const DeepCollectionEquality().hash(_recentMatches));

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
      final int totalGamesPlayed,
      final double overallAvgPlace,
      final List<RankingSummary> rankings,
      final List<RecentMatch> recentMatches}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  int get userId;
  @override
  String get nickname;
  @override
  String? get avatarUrl;
  @override
  int get totalGamesPlayed;
  @override
  double get overallAvgPlace;
  @override
  List<RankingSummary> get rankings;
  @override
  List<RecentMatch> get recentMatches;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
