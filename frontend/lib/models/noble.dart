// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'noble.freezed.dart';
part 'noble.g.dart';

/// 귀족 타일. 조건(requirement)을 만족하면 자동으로 획득합니다.
@freezed
class Noble with _$Noble {
  const factory Noble({
    required String id,
    @Default(3) int points,
    @Default({}) Map<String, int> requirement, // 색상 문자열 -> 필요 보너스 개수
  }) = _Noble;

  factory Noble.fromJson(Map<String, dynamic> json) => _$NobleFromJson(json);
}
