// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

/// 스플랜더 발전 카드 한 장.
/// GameState의 board(공개 카드)/players[].reservedCards/purchasedCards에서 공통으로 사용됩니다.
@freezed
class SplendorCard with _$SplendorCard {
  const factory SplendorCard({
    required String id,
    required int tier, // 1 | 2 | 3
    @Default(0) int points,
    required String bonus, // 이 카드를 구매하면 얻는 할인 보석 색상 (Gem.name)
    @Default({}) Map<String, int> cost, // 색상 문자열 -> 필요 개수
  }) = _SplendorCard;

  factory SplendorCard.fromJson(Map<String, dynamic> json) =>
      _$SplendorCardFromJson(json);
}
