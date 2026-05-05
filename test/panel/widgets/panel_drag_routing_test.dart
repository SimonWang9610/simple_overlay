import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

import '../panel_test_helpers.dart';

void main() {
  group('panel drag gesture routing', () {
    testWidgets('multiple drags across three panels move only the dragged panel', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        initialConstraints: testConstraints(),
      );

      controller.open(
        context,
        Panel(
          id: 'a',
          initialSize: const Size(160, 120),
          maintainState: false,
          initialPosition: const Offset(40, 40),
          builder: (_, __) => const Center(
            child: SizedBox.square(
              key: ValueKey('panel-body-a'),
              dimension: 40,
              child: Text('Panel A'),
            ),
          ),
        ),
      );
      controller.open(
        context,
        Panel(
          id: 'b',
          initialSize: const Size(160, 120),
          maintainState: false,
          initialPosition: const Offset(320, 40),
          builder: (_, __) => const Center(
            child: SizedBox.square(
              key: ValueKey('panel-body-b'),
              dimension: 40,
              child: Text('Panel B'),
            ),
          ),
        ),
      );

      controller.open(
        context,
        Panel(
          id: 'c',
          initialSize: const Size(160, 120),
          maintainState: false,
          initialPosition: const Offset(600, 40),
          builder: (_, __) => const Center(
            child: SizedBox.square(
              key: ValueKey('panel-body-c'),
              dimension: 40,
              child: Text('Panel C'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'c');

      final panelA = _viewControllerOf(controller, 'a');
      final panelB = _viewControllerOf(controller, 'b');
      final panelC = _viewControllerOf(controller, 'c');

      Offset aOrigin = panelA.value.geometry.origin;
      Offset bOrigin = panelB.value.geometry.origin;
      Offset cOrigin = panelC.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-body-a')), const Offset(30, 20));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'a');
      expect(panelA.value.geometry.origin.dx, greaterThan(aOrigin.dx));
      expect(panelA.value.geometry.origin.dy, greaterThan(aOrigin.dy));
      expect(panelB.value.geometry.origin, bOrigin);
      expect(panelC.value.geometry.origin, cOrigin);
      aOrigin = panelA.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-body-b')), const Offset(-24, 18));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'b');
      expect(panelB.value.geometry.origin.dx, lessThan(bOrigin.dx));
      expect(panelB.value.geometry.origin.dy, greaterThan(bOrigin.dy));
      expect(panelA.value.geometry.origin, aOrigin);
      expect(panelC.value.geometry.origin, cOrigin);
      bOrigin = panelB.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-body-c')), const Offset(16, 22));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'c');
      expect(panelC.value.geometry.origin.dx, greaterThan(cOrigin.dx));
      expect(panelC.value.geometry.origin.dy, greaterThan(cOrigin.dy));
      expect(panelA.value.geometry.origin, aOrigin);
      expect(panelB.value.geometry.origin, bOrigin);
      cOrigin = panelC.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-body-a')), const Offset(-32, 24));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'a');
      expect(panelA.value.geometry.origin, isNot(aOrigin));
      expect(panelA.value.geometry.origin.dy, greaterThan(aOrigin.dy));
      expect(panelB.value.geometry.origin, bOrigin);
      expect(panelC.value.geometry.origin, cOrigin);

      controller.dispose();
    });
  });
}

PanelViewController _viewControllerOf(PanelController controller, Object id) {
  return controller.orderedPanels.firstWhere((entry) => entry.id == id).controller;
}
