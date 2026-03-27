import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay/src/floating_config.dart';
import 'package:simple_overlay/src/overlay_route.dart';

import 'test_helpers.dart';

void main() {
  group('SimpleOverlayRoute', () {
    testWidgets('renders barrier and page, calls onPop', (tester) async {
      var popCalled = false;
      final context = await pumpAppAndGetContext(tester);

      final route = SimpleOverlayRoute<void>(
        barrier: const BarrierConfig(label: 'overlay-route-barrier'),
        builder: (_) => const Text('overlay-route-content'),
        onPop: () => popCalled = true,
      );

      Navigator.of(context).push(route);
      await tester.pump();

      expect(find.text('overlay-route-content'), findsOneWidget);
      expect(
        countBarriersWithLabel(tester, 'overlay-route-barrier'),
        greaterThanOrEqualTo(1),
      );

      route.markNeedsBuild();
      await tester.pump();

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(popCalled, isTrue);
      expect(find.text('overlay-route-content'), findsNothing);
      expect(countBarriersWithLabel(tester, 'overlay-route-barrier'), 0);
    });

    testWidgets('renders content without barrier when barrier is null', (
      tester,
    ) async {
      final context = await pumpAppAndGetContext(tester);
      final barrierBaseline = countAllBarriers(tester);

      final route = SimpleOverlayRoute<void>(
        barrier: null,
        builder: (_) => const Text('overlay-route-no-barrier'),
      );

      Navigator.of(context).push(route);
      await tester.pump();

      expect(find.text('overlay-route-no-barrier'), findsOneWidget);
      expect(countAllBarriers(tester), barrierBaseline);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(find.text('overlay-route-no-barrier'), findsNothing);
      expect(countAllBarriers(tester), barrierBaseline);
    });
  });
}
