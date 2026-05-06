import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

import '../panel_test_helpers.dart';

void main() {
  group('PanelController', () {
    testWidgets('uses MediaQuery-based scaled constraints when not provided', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(1200, 900));
      final controller = PanelController();

      controller.open(context, buildPanel(id: 'bootstrap', text: 'Bootstrap'));

      final constraints = controller.constraints;
      expect(constraints.origin, Offset.zero);
      expect(constraints.minSize, const Size(240, 180));
      expect(constraints.maxSize, const Size(1200, 900));

      controller.closeAll();
      await tester.pumpAndSettle();
    });

    testWidgets('open adds panels with expected default candidate positions', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(1000, 800));
      final controller = PanelController(
        initialConstraints: testConstraints(
          screen: const Size(1000, 800),
          min: const Size(80, 60),
        ),
      );

      final panelA = buildPanel(id: 'a', text: 'Panel A', size: const Size(120, 90));
      final panelB = buildPanel(id: 'b', text: 'Panel B', size: const Size(120, 90));

      controller.open(context, panelA);
      controller.open(context, panelB);
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isTrue);
      expect(controller.focusedPanel, 'b');
      expect(controller.orderedPanels.map((entry) => entry.id).toList(), ['a', 'b']);
      expect(find.text('Panel A'), findsOneWidget);
      expect(find.text('Panel B'), findsOneWidget);

      final panelAState = _entryById(controller, 'a').controller.value;
      final panelBState = _entryById(controller, 'b').controller.value;

      expect(panelAState.geometry.origin, Offset.zero);
      expect(panelBState.geometry.origin, const Offset(20, 20));

      controller.closeAll();
      await tester.pumpAndSettle();
    });

    testWidgets('minimize and restore update visibility and focused panel', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        initialConstraints: testConstraints(),
      );

      controller.open(context, buildPanel(id: 'a', text: 'A'));
      controller.open(context, buildPanel(id: 'b', text: 'B'));
      await tester.pump();

      final panelBController = _entryById(controller, 'b').controller;

      expect(controller.focusedPanel, 'b');
      expect(controller.isVisible('b'), isTrue);

      panelBController.minimize();
      await tester.pump();

      expect(controller.isVisible('b'), isFalse);
      expect(controller.focusedPanel, 'a');

      panelBController.restore();
      await tester.pump();

      expect(controller.isVisible('b'), isTrue);
      expect(controller.focusedPanel, 'b');

      controller.closeAll();
      await tester.pumpAndSettle();
    });

    testWidgets('mode and constraints setters notify only on effective changes', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(900, 700));
      final initialConstraints = testConstraints(
        screen: const Size(900, 700),
        min: const Size(120, 90),
      );
      final controller = PanelController(
        initialConstraints: initialConstraints,
        initialMode: PanelMode.window,
      );

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.mode = PanelMode.window;
      expect(notifications, 0);

      controller.mode = PanelMode.preview;
      expect(controller.mode, PanelMode.preview);
      expect(notifications, 1);

      controller.open(context, buildPanel(id: 'panel', text: 'Panel', size: const Size(60, 60)));
      await tester.pump();

      final updatedConstraints = testConstraints(
        screen: const Size(900, 700),
        min: const Size(200, 180),
        max: const Size(300, 260),
      );
      controller.constraints = updatedConstraints;

      final panelGeometry = _entryById(controller, 'panel').controller.value.geometry;
      expect(panelGeometry.size, const Size(200, 180));

      controller.closeAll();
      await tester.pumpAndSettle();
    });

    testWidgets('close and closeAll remove panels and support delegated close', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        initialConstraints: testConstraints(),
      );

      controller.open(context, buildPanel(id: 'a', text: 'Panel A'));
      controller.open(context, buildPanel(id: 'b', text: 'Panel B'));
      await tester.pumpAndSettle();

      _entryById(controller, 'a').controller.close();
      await tester.pumpAndSettle();

      expect(controller.panels.map((entry) => entry.id).toList(), ['b']);
      expect(find.text('Panel A'), findsNothing);

      controller.closeAll();
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isFalse);
      expect(controller.orderedPanels, isEmpty);
      expect(find.text('Panel B'), findsNothing);

      controller.closeAll();
      await tester.pumpAndSettle();
    });

    testWidgets('bringToFront and close ignore unknown ids and avoid duplicate notifications', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        initialConstraints: testConstraints(),
      );

      controller.open(context, buildPanel(id: 'a', text: 'A'));
      controller.open(context, buildPanel(id: 'b', text: 'B'));
      await tester.pump();

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.bringToFront('missing');
      controller.close('missing');
      expect(notifications, 0);

      controller.bringToFront('b');
      expect(notifications, 0);

      controller.bringToFront('a');
      expect(controller.focusedPanel, 'a');
      expect(notifications, 1);

      controller.closeAll();
      await tester.pumpAndSettle();
    });

    testWidgets('maximize, restore and focus from PanelViewController bring panel to front', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        initialConstraints: testConstraints(),
      );

      controller.open(context, buildPanel(id: 'a', text: 'A'));
      controller.open(context, buildPanel(id: 'b', text: 'B'));
      await tester.pump();

      final panelAController = _entryById(controller, 'a').controller;
      expect(controller.focusedPanel, 'b');

      panelAController.maximize();
      expect(controller.focusedPanel, 'a');

      panelAController.minimize();
      panelAController.restore();
      expect(controller.focusedPanel, 'a');

      panelAController.bringToFront();
      expect(controller.focusedPanel, 'a');

      controller.closeAll();
      await tester.pumpAndSettle();
    });

    testWidgets('duplicate panel id throws assertion error', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(
        initialConstraints: testConstraints(),
      );

      final panel = buildPanel(id: 'dup', text: 'Duplicate');
      controller.open(context, panel);

      expect(
        () => controller.open(context, panel),
        throwsA(isA<StateError>()),
      );

      controller.dispose();
    });

    testWidgets('uses given positioner and sizer when panel initial geometry is not provided', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final constraints = testConstraints(
        screen: const Size(800, 600),
        min: const Size(100, 80),
        max: const Size(400, 300),
      );

      final controller = PanelController(
        initialConstraints: constraints,
        positioner: const PanelPositioner.follow(
          panelAlignment: Alignment.bottomRight,
          screenAlignment: Alignment.bottomRight,
        ),
        sizer: const PanelSizer.fixed(size: Size(220, 140)),
      );

      controller.open(
        context,
        Panel(
          id: 'auto-geometry',
          builder: (_, __) => const Text('Auto Geometry'),
        ),
      );
      await tester.pumpAndSettle();

      final geometry = _entryById(controller, 'auto-geometry').controller.value.geometry;

      expect(geometry.size, const Size(220, 140));
      expect(geometry.origin, const Offset(180, 160));

      controller.dispose();
    });

    testWidgets('initial constraints are initialized once when not provided', (tester) async {
      late BuildContext outerContext;
      late BuildContext innerContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1000, 700)),
            child: Builder(
              builder: (context) {
                outerContext = context;
                return MediaQuery(
                  data: const MediaQueryData(size: Size(320, 240)),
                  child: Builder(
                    builder: (context) {
                      innerContext = context;
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      final controller = PanelController();

      controller.open(outerContext, buildPanel(id: 'a', text: 'A'));
      await tester.pumpAndSettle();
      final firstConstraints = controller.constraints;

      controller.open(innerContext, buildPanel(id: 'b', text: 'B'));
      await tester.pumpAndSettle();

      expect(firstConstraints.maxSize, const Size(1000, 700));
      expect(controller.constraints, firstConstraints);

      controller.dispose();
    });

    testWidgets('PanelController.close and PanelViewController.close are idempotent together', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'a', text: 'A'));
      controller.open(context, buildPanel(id: 'b', text: 'B'));
      await tester.pumpAndSettle();

      final panelAController = _entryById(controller, 'a').controller;

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.close('a');
      panelAController.close();
      controller.close('a');
      await tester.pumpAndSettle();

      expect(controller.panels.map((entry) => entry.id), ['b']);
      expect(notifications, 1);

      controller.dispose();
    });

    testWidgets('bringToFront on topmost panel keeps full z-order unchanged', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'a', text: 'A'));
      controller.open(context, buildPanel(id: 'b', text: 'B'));
      controller.open(context, buildPanel(id: 'c', text: 'C'));
      await tester.pumpAndSettle();

      final beforeOrder = controller.orderedPanels.map((entry) => entry.id).toList();

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.bringToFront('c');

      expect(controller.orderedPanels.map((entry) => entry.id).toList(), beforeOrder);
      expect(notifications, 0);

      controller.dispose();
    });
  });
}

PanelEntry _entryById(PanelController controller, Object id) {
  return controller.panels.firstWhere((entry) => entry.id == id);
}
