import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/src/panel/controllers/z_index_manager.dart';

void main() {
  group('ZIndexManager', () {
    test('upgrade, downgrade and visibility checks work as expected', () {
      final manager = ZIndexManager();

      expect(manager.ordered, isEmpty);

      expect(manager.upgrade('a'), isTrue);
      expect(manager.hasValidIndex('a'), isTrue);
      expect(manager.atTop('a'), isTrue);

      expect(manager.upgrade('a'), isFalse);

      expect(manager.upgrade('b'), isTrue);
      expect(manager.atTop('a'), isFalse);
      expect(manager.atTop('b'), isTrue);

      expect(manager.downgrade('b'), isTrue);
      expect(manager.hasValidIndex('b'), isFalse);
      expect(manager.downgrade('b'), isFalse);
    });

    test('ordered returns ids from back to front and refreshes after mutations', () {
      final manager = ZIndexManager();

      manager.upgrade('a');
      manager.upgrade('b');
      manager.upgrade('c');

      expect(manager.ordered.toList(), ['a', 'b', 'c']);

      manager.upgrade('a');
      expect(manager.ordered.toList(), ['b', 'c', 'a']);

      manager.downgrade('c');
      expect(manager.ordered.toList(), ['c', 'b', 'a']);
    });

    test('remove and reset clear tracked indices', () {
      final manager = ZIndexManager();

      manager.upgrade('a');
      manager.upgrade('b');

      expect(manager.remove('x'), isFalse);
      expect(manager.remove('a'), isTrue);
      expect(manager.ordered.toList(), ['b']);

      manager.reset();

      expect(manager.ordered, isEmpty);
      expect(manager.hasValidIndex('b'), isFalse);
      expect(manager.atTop('b'), isFalse);
      expect(manager.upgrade('z'), isTrue);
      expect(manager.ordered.toList(), ['z']);
    });
  });
}
