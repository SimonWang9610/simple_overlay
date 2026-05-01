import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/widgets/multi_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('PanelShower (through PanelController)', () {
    testWidgets('creates a single floating host and reuses it across opens', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        context,
        initialConstraints: testConstraints(),
      );

      controller.open(
        buildPanel(id: 'a', text: 'A', maintainState: true),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MultiFloatingPanel), findsOneWidget);
      expect(find.text('A'), findsOneWidget);

      controller.open(
        buildPanel(id: 'b', text: 'B', maintainState: false),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MultiFloatingPanel), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('disposes floating host automatically when all panels close', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        context,
        initialConstraints: testConstraints(),
      );

      controller.open(buildPanel(id: 'a', text: 'Panel A'));
      controller.open(buildPanel(id: 'b', text: 'Panel B'));
      await tester.pumpAndSettle();

      expect(find.byType(MultiFloatingPanel), findsOneWidget);

      controller.close('a');
      await tester.pumpAndSettle();
      expect(find.byType(MultiFloatingPanel), findsOneWidget);

      controller.close('b');
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isFalse);
      expect(find.byType(MultiFloatingPanel), findsNothing);
      expect(find.text('Panel A'), findsNothing);
      expect(find.text('Panel B'), findsNothing);

      controller.dispose();
    });

    testWidgets('dispose cleans up host and panel state', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        context,
        initialConstraints: testConstraints(),
      );

      controller.open(buildPanel(id: 'a', text: 'Disposable'));
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isTrue);
      expect(find.byType(MultiFloatingPanel), findsOneWidget);

      controller.dispose();
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isFalse);
      expect(find.byType(MultiFloatingPanel), findsNothing);
      expect(find.text('Disposable'), findsNothing);
    });
  });
}
