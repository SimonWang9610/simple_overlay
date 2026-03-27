import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay/simple_overlay.dart';

import 'test_helpers.dart';

void main() {
  group('FloatingManager', () {
    testWidgets('show and hide updates manager state and listeners', (
      tester,
    ) async {
      final manager = FloatingManager();
      var managerNotifications = 0;

      manager.addListener(() => managerNotifications++);
      final context = await pumpAppAndGetContext(tester);

      expect(manager.isShowing, isFalse);

      await manager.show(
        context,
        const RawOverlayConfig(builder: builderA),
      );
      await tester.pump();

      expect(manager.isShowing, isTrue);
      expect(find.text('A'), findsOneWidget);

      await manager.show(
        context,
        const RawOverlayConfig(builder: builderB),
      );
      await tester.pump();

      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsOneWidget);

      await manager.hide();
      await tester.pump();

      expect(manager.isShowing, isFalse);
      expect(find.text('B'), findsNothing);
      expect(managerNotifications, greaterThanOrEqualTo(2));
    });
  });
}
