/// 스플랜더 보석 색상. 토큰/카드 보너스/카드 비용/귀족 조건 등에서 공통으로 사용됩니다.
/// gold(황금)는 토큰으로만 존재하며 카드 보너스로는 나오지 않습니다.
/// 서버 응답의 보석 관련 Map(예: 카드 cost, 플레이어 gems)은 색상 문자열을 key로
/// 하는 Map<String, int>로 그대로 다루고, 이 enum은 GameHub invoke 페이로드
/// 구성이나 보석 선택 UI처럼 타입 안정성이 필요한 곳에서만 사용합니다.
enum Gem {
  diamond,
  sapphire,
  emerald,
  ruby,
  onyx,
  gold;

  String get wireValue => name;

  static Gem fromWireValue(String value) =>
      Gem.values.firstWhere((g) => g.name == value);
}
