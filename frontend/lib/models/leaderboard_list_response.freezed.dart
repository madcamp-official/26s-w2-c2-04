// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LeaderboardListResponse _$LeaderboardListResponseFromJson(
    Map<String, dynamic> json) {
  return _LeaderboardListResponse.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardListResponse {
  int get playerCount => throw _privateConstructorUsedError;
  int? get page => throw _privateConstructorUsedError; // /search 응답에는 없음
  int? get limit => throw _privateConstructorUsedError; // /search 응답에는 없음
  int get total => throw _privateConstructorUsedError;
  List<LeaderboardEntry> get entries => throw _privateConstructorUsedError;
  LeaderboardEntry? get myRank =>
      throw _privateConstructorUsedError; // /search 응답에는 없음
  String? get query => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardListResponseCopyWith<LeaderboardListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardListResponseCopyWith<$Res> {
  factory $LeaderboardListResponseCopyWith(LeaderboardListResponse value,
          $Res Function(LeaderboardListResponse) then) =
      _$LeaderboardListResponseCopyWithImpl<$Res, LeaderboardListResponse>;
  @useResult
  $Res call(
      {int playerCount,
      int? page,
      int? limit,
      int total,
      List<LeaderboardEntry> entries,
      LeaderboardEntry? myRank,
      String? query});

  $LeaderboardEntryCopyWith<$Res>? get myRank;
}

/// @nodoc
class _$LeaderboardListResponseCopyWithImpl<$Res,
        $Val extends LeaderboardListResponse>
    implements $LeaderboardListResponseCopyWith<$Res> {
  _$LeaderboardListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerCount = null,
    Object? page = freezed,
    Object? limit = freezed,
    Object? total = null,
    Object? entries = null,
    Object? myRank = freezed,
    Object? query = freezed,
  }) {
    return _then(_value.copyWith(
      playerCount: null == playerCount
          ? _value.playerCount
          : playerCount // ignore: cast_nullable_to_non_nullable
              as int,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<LeaderboardEntry>,
      myRank: freezed == myRank
          ? _value.myRank
          : myRank // ignore: cast_nullable_to_non_nullable
              as LeaderboardEntry?,
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of LeaderboardListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaderboardEntryCopyWith<$Res>? get myRank {
    if (_value.myRank == null) {
      return null;
    }

    return $LeaderboardEntryCopyWith<$Res>(_value.myRank!, (value) {
      return _then(_value.copyWith(myRank: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeaderboardListResponseImplCopyWith<$Res>
    implements $LeaderboardListResponseCopyWith<$Res> {
  factory _$$LeaderboardListResponseImplCopyWith(
          _$LeaderboardListResponseImpl value,
          $Res Function(_$LeaderboardListResponseImpl) then) =
      __$$LeaderboardListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int playerCount,
      int? page,
      int? limit,
      int total,
      List<LeaderboardEntry> entries,
      LeaderboardEntry? myRank,
      String? query});

  @override
  $LeaderboardEntryCopyWith<$Res>? get myRank;
}

/// @nodoc
class __$$LeaderboardListResponseImplCopyWithImpl<$Res>
    extends _$LeaderboardListResponseCopyWithImpl<$Res,
        _$LeaderboardListResponseImpl>
    implements _$$LeaderboardListResponseImplCopyWith<$Res> {
  __$$LeaderboardListResponseImplCopyWithImpl(
      _$LeaderboardListResponseImpl _value,
      $Res Function(_$LeaderboardListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaderboardListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerCount = null,
    Object? page = freezed,
    Object? limit = freezed,
    Object? total = null,
    Object? entries = null,
    Object? myRank = freezed,
    Object? query = freezed,
  }) {
    return _then(_$LeaderboardListResponseImpl(
      playerCount: null == playerCount
          ? _value.playerCount
          : playerCount // ignore: cast_nullable_to_non_nullable
              as int,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<LeaderboardEntry>,
      myRank: freezed == myRank
          ? _value.myRank
          : myRank // ignore: cast_nullable_to_non_nullable
              as LeaderboardEntry?,
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardListResponseImpl implements _LeaderboardListResponse {
  const _$LeaderboardListResponseImpl(
      {required this.playerCount,
      this.page,
      this.limit,
      this.total = 0,
      final List<LeaderboardEntry> entries = const [],
      this.myRank,
      this.query})
      : _entries = entries;

  factory _$LeaderboardListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardListResponseImplFromJson(json);

  @override
  final int playerCount;
  @override
  final int? page;
// /search 응답에는 없음
  @override
  final int? limit;
// /search 응답에는 없음
  @override
  @JsonKey()
  final int total;
  final List<LeaderboardEntry> _entries;
  @override
  @JsonKey()
  List<LeaderboardEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  final LeaderboardEntry? myRank;
// /search 응답에는 없음
  @override
  final String? query;

  @override
  String toString() {
    return 'LeaderboardListResponse(playerCount: $playerCount, page: $page, limit: $limit, total: $total, entries: $entries, myRank: $myRank, query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardListResponseImpl &&
            (identical(other.playerCount, playerCount) ||
                other.playerCount == playerCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.myRank, myRank) || other.myRank == myRank) &&
            (identical(other.query, query) || other.query == query));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, playerCount, page, limit, total,
      const DeepCollectionEquality().hash(_entries), myRank, query);

  /// Create a copy of LeaderboardListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardListResponseImplCopyWith<_$LeaderboardListResponseImpl>
      get copyWith => __$$LeaderboardListResponseImplCopyWithImpl<
          _$LeaderboardListResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardListResponseImplToJson(
      this,
    );
  }
}

abstract class _LeaderboardListResponse implements LeaderboardListResponse {
  const factory _LeaderboardListResponse(
      {required final int playerCount,
      final int? page,
      final int? limit,
      final int total,
      final List<LeaderboardEntry> entries,
      final LeaderboardEntry? myRank,
      final String? query}) = _$LeaderboardListResponseImpl;

  factory _LeaderboardListResponse.fromJson(Map<String, dynamic> json) =
      _$LeaderboardListResponseImpl.fromJson;

  @override
  int get playerCount;
  @override
  int? get page; // /search 응답에는 없음
  @override
  int? get limit; // /search 응답에는 없음
  @override
  int get total;
  @override
  List<LeaderboardEntry> get entries;
  @override
  LeaderboardEntry? get myRank; // /search 응답에는 없음
  @override
  String? get query;

  /// Create a copy of LeaderboardListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardListResponseImplCopyWith<_$LeaderboardListResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
