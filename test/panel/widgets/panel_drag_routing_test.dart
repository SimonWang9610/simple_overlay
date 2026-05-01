import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

import '../panel_test_helpers.dart';

void main() {
  group('panel drag gesture routing', () {
    testWidgets('dragging a non-focused panel moves itself after focus reorder', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        context,
        initialConstraints: testConstraints(),
      );

      controller.open(
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
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'b');

      final panelA = _viewControllerOf(controller, 'a');
      final panelB = _viewControllerOf(controller, 'b');

      final aOriginBefore = panelA.value.geometry.origin;
      final bOriginBefore = panelB.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-body-a')), const Offset(30, 20));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'a');

      final aOriginAfter = panelA.value.geometry.origin;
      final bOriginAfter = panelB.value.geometry.origin;

      expect(aOriginAfter.dx, greaterThan(aOriginBefore.dx));
      expect(aOriginAfter.dy, greaterThan(aOriginBefore.dy));
      expect(bOriginAfter, bOriginBefore);

      controller.dispose();
    });
  });
}

PanelViewController _viewControllerOf(PanelController controller, Object id) {
  return controller.orderedPanels.firstWhere((entry) => entry.id == id).controller;
}
