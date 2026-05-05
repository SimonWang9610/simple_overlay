import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

import '../panel_test_helpers.dart';

void main() {
  group('MultiFloatingPanel behavior', () {
    testWidgets('window mode hides minimized panels and preview mode shows them', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(900, 700),
          min: const Size(120, 90),
        ),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A'));
      controller.open(context, buildPanel(id: 'b', text: 'Panel B'));
      await tester.pumpAndSettle();

      final panelAController = controller.panels.firstWhere((entry) => entry.id == 'a').controller;
      panelAController.minimize();
      await tester.pumpAndSettle();

      expect(controller.mode, PanelMode.window);
      expect(find.text('Panel A'), findsNothing);
      expect(find.text('Panel B'), findsOneWidget);

      controller.mode = PanelMode.preview;
      await tester.pumpAndSettle();

      expect(find.text('Panel A'), findsOneWidget);
      expect(find.text('Panel B'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('tapping panel in preview mode focuses it and switches back to window mode', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(900, 700),
          min: const Size(120, 90),
        ),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A', initialPosition: const Offset(40, 40)));
      controller.open(context, buildPanel(id: 'b', text: 'Panel B', initialPosition: const Offset(320, 80)));
      controller.mode = PanelMode.preview;
      await tester.pumpAndSettle();

      final previewTapTarget = find.ancestor(
        of: find.text('Panel A').first,
        matching: find.byWidgetPredicate(
          (widget) => widget is GestureDetector && widget.onTap != null && widget.onPanUpdate == null,
        ),
      );

      expect(previewTapTarget, findsOneWidget);

      await tester.tap(previewTapTarget);
      await tester.pumpAndSettle();

      expect(controller.mode, PanelMode.window);
      expect(controller.focusedPanel, 'a');

      controller.dispose();
    });

    testWidgets('barrier tap dismisses preview when barrierDismissible is true', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(900, 700),
          min: const Size(120, 90),
          max: const Size(600, 500),
          origin: const Offset(100, 80),
        ),
        initialConfig: const PanelConfig(
          previewStyle: PanelPreviewStyle(
            barrierDismissible: true,
            barrierColor: Colors.black26,
          ),
        ),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A'));
      controller.mode = PanelMode.preview;
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(controller.mode, PanelMode.window);

      controller.dispose();
    });

    testWidgets('barrier tap does not dismiss preview when barrierDismissible is false', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(900, 700),
          min: const Size(120, 90),
          max: const Size(600, 500),
          origin: const Offset(100, 80),
        ),
        initialConfig: const PanelConfig(
          previewStyle: PanelPreviewStyle(
            barrierDismissible: false,
            barrierColor: Colors.black26,
          ),
        ),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A'));
      controller.mode = PanelMode.preview;
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(controller.mode, PanelMode.preview);

      controller.dispose();
    });

    testWidgets('uses different PanelConfig decorations for focused and unfocused panels in window mode',
        (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(900, 700),
          min: const Size(120, 90),
        ),
        initialConfig: const PanelConfig(
          decoration: BoxDecoration(color: Colors.amber),
          focusedDecoration: BoxDecoration(color: Colors.teal),
        ),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A', initialPosition: const Offset(40, 40)));
      controller.open(context, buildPanel(id: 'b', text: 'Panel B', initialPosition: const Offset(320, 80)));
      await tester.pumpAndSettle();

      final panelADecorated = _panelContainerForText(tester, 'Panel A');
      final panelBDecorated = _panelContainerForText(tester, 'Panel B');

      expect(panelADecorated.color, Colors.amber);
      expect(panelBDecorated.color, Colors.teal);

      controller.dispose();
    });

    testWidgets('applies updated PanelConfig when controller config changes', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(900, 700),
          min: const Size(120, 90),
        ),
        initialConfig: const PanelConfig(
          decoration: BoxDecoration(color: Colors.orange),
          focusedDecoration: BoxDecoration(color: Colors.pink),
        ),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A'));
      await tester.pumpAndSettle();

      expect(_panelContainerForText(tester, 'Panel A').color, Colors.pink);

      controller.config = const PanelConfig(
        decoration: BoxDecoration(color: Colors.lime),
        focusedDecoration: BoxDecoration(color: Colors.indigo),
      );
      await tester.pumpAndSettle();

      expect(_panelContainerForText(tester, 'Panel A').color, Colors.indigo);

      controller.dispose();
    });

    testWidgets('uses preview-specific decorations from PanelConfig in preview mode', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(900, 700),
          min: const Size(120, 90),
        ),
        initialConfig: const PanelConfig(
          decoration: BoxDecoration(color: Colors.amber),
          focusedDecoration: BoxDecoration(color: Colors.teal),
          previewStyle: PanelPreviewStyle(
            decoration: BoxDecoration(color: Colors.brown),
            focusedDecoration: BoxDecoration(color: Colors.cyan),
          ),
        ),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A', initialPosition: const Offset(40, 40)));
      controller.open(context, buildPanel(id: 'b', text: 'Panel B', initialPosition: const Offset(320, 80)));
      await tester.pumpAndSettle();

      controller.mode = PanelMode.preview;
      await tester.pumpAndSettle();

      final panelADecorated = _panelContainerForText(tester, 'Panel A');
      final panelBDecorated = _panelContainerForText(tester, 'Panel B');

      expect(panelADecorated.color, Colors.brown);
      expect(panelBDecorated.color, Colors.cyan);

      controller.dispose();
    });
  });
}

BoxDecoration _panelContainerForText(WidgetTester tester, String text) {
  final decoratedBoxFinder = find.ancestor(
    of: find.text(text).first,
    matching: find.byType(DecoratedBox),
  );

  expect(decoratedBoxFinder, findsWidgets);

  final decoratedBoxes = tester.widgetList<DecoratedBox>(decoratedBoxFinder).toList();
  return decoratedBoxes.map((widget) => widget.decoration).whereType<BoxDecoration>().first;
}
