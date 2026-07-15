// 카드/귀족/토큰 아트(assets/image/*)와 게임 데이터를 잇는 순수 매핑 함수들.
// Flame이 아니라 여기서만 경로 문자열을 만들고, splendor_game.dart가
// `game.loadSprite(...)`로 로드합니다(prefix는 SplendorGame.onLoad에서
// 'assets/image/'로 설정하므로 아래 경로들은 그 아래부터 상대 경로입니다).
//
// 카드 id는 backend/Backend/Game/CardData.cs의 `T{tier}-{Bonus}-{index}`
// 포맷(예: "T1-Diamond-1")을 따릅니다. 파일명(assets/image/cards/*.png)은
// 색상별로 1~18번 전역 인덱스 + 고정된 접미사(alembic/book/... )를 씁니다.

class GameAssets {
  GameAssets._();

  static final RegExp _cardIdPattern = RegExp(r'^T(\d+)-(\w+)-(\d+)$');

  // 인덱스(1~18) -> 파일명 접미사. 1~8은 티어1(alembic), 9~14는 티어2, 15~18은 티어3.
  static const List<String> _cardSuffixes = [
    'L1_alembic', 'L1_alembic', 'L1_alembic', 'L1_alembic',
    'L1_alembic', 'L1_alembic', 'L1_alembic', 'L1_alembic',
    'L2_book', 'L2_mortar', 'L2_candle', 'L2_scale', 'L2_hourglass', 'L2_key',
    'L3_stone', 'L3_ouroboros', 'L3_sigil', 'L3_homunculus',
  ];

  // 토큰 아트는 원소 리스킨을 쓴다. 색↔파일 대응은 실제 이미지를 눈으로 확인해
  // 맞췄다: token_wind.png는 초록 코인(=emerald), token_earth.png는 검정 코인
  // (=onyx)이다. 예전에는 이 둘이 뒤바뀌어 있어(emerald→earth, onyx→wind) onyx를
  // 가져가면 초록 코인이 늘어 emerald가 오르는 것처럼 보였다.
  static const Map<String, String> _tokenElementNames = {
    'diamond': 'aether',
    'sapphire': 'water',
    'emerald': 'wind',
    'ruby': 'fire',
    'onyx': 'earth',
    'gold': 'gold',
  };

  /// 카드 id("T1-Diamond-1")로 얼굴 이미지 경로를 만듭니다.
  /// 형식이 예상과 다르면(백엔드 계약이 바뀌는 등) null을 반환하니, 호출부에서
  /// [cardBack]으로 폴백하세요.
  static String? cardFace(String cardId) {
    final match = _cardIdPattern.firstMatch(cardId);
    if (match == null) return null;
    final tier = int.parse(match.group(1)!);
    final bonus = match.group(2)!.toLowerCase();
    final indexInTier = int.parse(match.group(3)!);
    return cardFaceByBonus(bonus: bonus, tier: tier, indexInTier: indexInTier);
  }

  static String? cardFaceByBonus({
    required String bonus,
    required int tier,
    required int indexInTier,
  }) {
    final globalIndex = switch (tier) {
      1 => indexInTier,
      2 => 8 + indexInTier,
      3 => 14 + indexInTier,
      _ => null,
    };
    if (globalIndex == null || globalIndex < 1 || globalIndex > _cardSuffixes.length) {
      return null;
    }
    final suffix = _cardSuffixes[globalIndex - 1];
    final nn = globalIndex.toString().padLeft(2, '0');
    return 'cards/${bonus.toLowerCase()}_${nn}_$suffix.png';
  }

  static String cardBack(int tier) => switch (tier) {
        1 => 'cards/back_level1_green.png',
        2 => 'cards/back_level2_yellow.png',
        _ => 'cards/back_level3_blue.png',
      };

  /// 귀족 id("N4" 등, backend CardData.GenerateNobles 참고)로 이미지 경로를 만듭니다.
  static String nobleImage(String nobleId) {
    final digits = nobleId.replaceAll(RegExp(r'[^0-9]'), '');
    final n = int.tryParse(digits) ?? 1;
    final clamped = n.clamp(1, 10);
    return 'nobles/noble_${clamped.toString().padLeft(2, '0')}.png';
  }

  /// 보석 색상 문자열(대소문자 무관, "Diamond"/"diamond")로 토큰 이미지 경로를 만듭니다.
  static String tokenImage(String gem) {
    final element = _tokenElementNames[gem.toLowerCase()] ?? gem.toLowerCase();
    return 'tokens/token_$element.png';
  }
}
