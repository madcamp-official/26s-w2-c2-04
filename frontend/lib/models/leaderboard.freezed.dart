// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  int get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'userId')
  int get playerId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get mmr => throw _privateConstructorUsedError;
  double get avgPlace => throw _privateConstructorUsedError;
  int get gamesPlayedSeason => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
          LeaderboardEntry value, $Res Function(LeaderboardEntry) then) =
      _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call(
      {int rank,
      @JsonKey(name: 'userId') int playerId,
      String nickname,
      String? avatarUrl,
      int mmr,
      double avgPlace,
      int gamesPlayedSeason});
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? playerId = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? mmr = null,
    Object? avgPlace = null,
    Object? gamesPlayedSeason = null,
  }) {
    return _then(_value.copyWith(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mmr: null == mmr
          ? _value.mmr
          : mmr // ignore: cast_nullable_to_non_nullable
              as int,
      avgPlace: null == avgPlace
          ? _value.avgPlace
          : avgPlace // ignore: cast_nullable_to_non_nullable
              as double,
      gamesPlayedSeason: null == gamesPlayedSeason
          ? _value.gamesPlayedSeason
          : gamesPlayedSeason // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(_$LeaderboardEntryImpl value,
          $Res Function(_$LeaderboardEntryImpl) then) =
      __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int rank,
      @JsonKey(name: 'userId') int playerId,
      String nickname,
      String? avatarUrl,
      int mmr,
      double avgPlace,
      int gamesPlayedSeason});
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(_$LeaderboardEntryImpl _value,
      $Res Function(_$LeaderboardEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? playerId = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? mmr = null,
    Object? avgPlace = null,
    Object? gamesPlayedSeason = null,
  }) {
    return _then(_$LeaderboardEntryImpl(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mmr: null == mmr
          ? _value.mmr
          : mmr // ignore: cast_nullable_to_non_nullable
              as int,
      avgPlace: null == avgPlace
          ? _value.avgPlace
          : avgPlace // ignore: cast_nullable_to_non_nullable
              as double,
      gamesPlayedSeason: null == gamesPlayedSeason
          ? _value.gamesPlayedSeason
          : gamesPlayedSeason // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl extends _LeaderboardEntry {
  const _$LeaderboardEntryImpl(
      {required this.rank,
      @JsonKey(name: 'userId') required this.playerId,
      required this.nickname,
      this.avatarUrl,
      required this.mmr,
      required this.avgPlace,
      required this.gamesPlayedSeason})
      : super._();

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  @override
  final int rank;
  @override
  @JsonKey(name: 'userId')
  final int playerId;
  @override
  final String nickname;
  @override
  final String? avatarUrl;
  @override
  final int mmr;
  @override
  final double avgPlace;
  @override
  final int gamesPlayedSeason;

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, playerId: $playerId, nickname: $nickname, avatarUrl: $avatarUrl, mmr: $mmr, avgPlace: $avgPlace, gamesPlayedSeason: $gamesPlayedSeason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.mmr, mmr) || other.mmr == mmr) &&
            (identical(other.avgPlace, avgPlace) ||
                other.avgPlace == avgPlace) &&
            (identical(other.gamesPlayedSeason, gamesPlayedSeason) ||
                other.gamesPlayedSeason == gamesPlayedSeason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rank, playerId, nickname,
      avatarUrl, mmr, avgPlace, gamesPlayedSeason);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(
      this,
    );
  }
}

abstract class _LeaderboardEntry extends LeaderboardEntry {
  const factory _LeaderboardEntry(
      {required final int rank,
      @JsonKey(name: 'userId') required final int playerId,
      required final String nickname,
      final String? avatarUrl,
      required final int mmr,
      required final double avgPlace,
      required final int gamesPlayedSeason}) = _$LeaderboardEntryImpl;
  const _LeaderboardEntry._() : super._();

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override
  int get rank;
  @override
  @JsonKey(name: 'userId')
  int get playerId;
  @override
  String get nickname;
  @override
  String? get avatarUrl;
  @override
  int get mmr;
  @override
  double get avgPlace;
  @override
  int get gamesPlayedSeason;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
