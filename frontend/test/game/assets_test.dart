import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/game/assets.dart';

void main() {
  group('GameAssets.cardFace', () {
    test('티어1 카드는 alembic 접미사, 색상별 1~8번을 매긴다', () {
      expect(GameAssets.cardFace('T1-Diamond-1'), 'cards/diamond_01_L1_alembic.png');
      expect(GameAssets.cardFace('T1-Diamond-8'), 'cards/diamond_08_L1_alembic.png');
      expect(GameAssets.cardFace('T1-Ruby-3'), 'cards/ruby_03_L1_alembic.png');
    });

    test('티어2 카드는 전역 인덱스 9~14로 매핑된다', () {
      expect(GameAssets.cardFace('T2-Emerald-1'), 'cards/emerald_09_L2_book.png');
      expect(GameAssets.cardFace('T2-Emerald-6'), 'cards/emerald_14_L2_key.png');
    });

    test('티어3 카드는 전역 인덱스 15~18로 매핑된다', () {
      expect(GameAssets.cardFace('T3-Onyx-1'), 'cards/onyx_15_L3_stone.png');
      expect(GameAssets.cardFace('T3-Onyx-4'), 'cards/onyx_18_L3_homunculus.png');
    });

    test('형식이 맞지 않으면 null을 반환한다', () {
      expect(GameAssets.cardFace('unexpected-id'), isNull);
    });
  });

  group('GameAssets.cardBack', () {
    test('티어별로 다른 뒷면 이미지를 반환한다', () {
      expect(GameAssets.cardBack(1), 'cards/back_level1_green.png');
      expect(GameAssets.cardBack(2), 'cards/back_level2_yellow.png');
      expect(GameAssets.cardBack(3), 'cards/back_level3_blue.png');
    });
  });

  group('GameAssets.nobleImage', () {
    test('귀족 id에서 숫자를 뽑아 2자리로 채운다', () {
      expect(GameAssets.nobleImage('N1'), 'nobles/noble_01.png');
      expect(GameAssets.nobleImage('N10'), 'nobles/noble_10.png');
    });
  });

  group('GameAssets.tokenImage', () {
    test('보석 색상을 원소 테마 토큰 이름으로 매핑한다', () {
      expect(GameAssets.tokenImage('Diamond'), 'tokens/token_aether.png');
      expect(GameAssets.tokenImage('Sapphire'), 'tokens/token_water.png');
      expect(GameAssets.tokenImage('Emerald'), 'tokens/token_earth.png');
      expect(GameAssets.tokenImage('Ruby'), 'tokens/token_fire.png');
      expect(GameAssets.tokenImage('Onyx'), 'tokens/token_wind.png');
      expect(GameAssets.tokenImage('Gold'), 'tokens/token_gold.png');
    });
  });
}
