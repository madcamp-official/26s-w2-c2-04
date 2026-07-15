import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/gem.dart';

void main() {
  group('Gem.wireValue', () {
    test('PascalCase로 직렬화한다(백엔드 GemType이 naming policy 없는 '
        'JsonStringEnumConverter를 쓰기 때문)', () {
      expect(Gem.diamond.wireValue, 'Diamond');
      expect(Gem.sapphire.wireValue, 'Sapphire');
      expect(Gem.emerald.wireValue, 'Emerald');
      expect(Gem.ruby.wireValue, 'Ruby');
      expect(Gem.onyx.wireValue, 'Onyx');
      expect(Gem.gold.wireValue, 'Gold');
    });
  });

  group('Gem.fromWireValue', () {
    test('PascalCase 문자열을 역매핑한다', () {
      expect(Gem.fromWireValue('Diamond'), Gem.diamond);
      expect(Gem.fromWireValue('Gold'), Gem.gold);
    });

    test('소문자로 와도 관대하게 처리한다', () {
      expect(Gem.fromWireValue('diamond'), Gem.diamond);
    });
  });
}
