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

  /// GameHub invoke 페이로드/GameState 맵 키에 쓰이는 표기. 백엔드 GemType enum이
  /// PascalCase 문자열로 직렬화됩니다(naming policy 없는 JsonStringEnumConverter,
  /// backend/Backend/Program.cs:42,98) — "diamond"가 아니라 "Diamond".
  String get wireValue => name[0].toUpperCase() + name.substring(1);

  static Gem fromWireValue(String value) => Gem.values.firstWhere(
        (g) => g.wireValue == value,
        orElse: () => Gem.values.firstWhere((g) => g.name == value.toLowerCase()),
      );

  /// 토큰 뱅크(보드), 보유 토큰 뱅크, 할인(보너스) 뱅크 등 토큰을 나열하는 모든
  /// 곳에서 항상 이 순서로 그린다: sapphire, ruby, emerald, onyx, diamond, gold.
  /// gem_colors.dart의 gemDisplayOrder(String, 카드/귀족 비용용 — gold 제외)와 색
  /// 순서를 맞춘 Gem enum 버전이며, gold(와일드카드)는 항상 맨 끝에 둔다. 선언
  /// 순서(Gem.values)와 표시 순서를 분리해, enum 순서를 바꾸지 않고도 화면 배치를
  /// 통일한다.
  static const List<Gem> displayOrder = [
    Gem.sapphire,
    Gem.ruby,
    Gem.emerald,
    Gem.onyx,
    Gem.diamond,
    Gem.gold,
  ];
}
