import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/widgets/multi_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('PanelShower (through PanelController)', () {
    testWidgets('creates a single floating host and reuses it across opens', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'a', text: 'A', maintainState: true));
      await tester.pumpAndSettle();

      expect(find.byType(MultiFloatingPanel), findsOneWidget);
      expect(find.text('A'), findsOneWidget);

      controller.open(context, buildPanel(id: 'b', text: 'B', maintainState: false));
      await tester.pumpAndSettle();

      expect(find.byType(MultiFloatingPanel), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('disposes floating host automatically when all panels close', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'a', text: 'Panel A'));
      controller.open(context, buildPanel(id: 'b', text: 'Panel B'));
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
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'a', text: 'Disposable'));
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isTrue);
      expect(find.byType(MultiFloatingPanel), findsOneWidget);

      controller.dispose();
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isFalse);
      expect(find.byType(MultiFloatingPanel), findsNothing);
      expect(find.text('Disposable'), findsNothing);
    });

    testWidgets('delays constraints setup until first legal open context', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester, size: const Size(1000, 700));
      final controller = PanelController();

      controller.open(context, buildPanel(id: 'a', text: 'A'));
      await tester.pumpAndSettle();

      expect(controller.constraints.minSize, const Size(200, 140));
      expect(controller.constraints.maxSize, const Size(1000, 700));
      expect(find.byType(MultiFloatingPanel), findsOneWidget);

      controller.dispose();
    });

    testWidgets('throws when first open uses an unmounted context', (tester) async {
      late BuildContext staleContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              staleContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(staleContext.mounted, isFalse);

      final controller = PanelController();

      expect(
        () => controller.open(staleContext, buildPanel(id: 'stale', text: 'Stale')),
        throwsA(anyOf(isA<AssertionError>(), isA<FlutterError>(), isA<TypeError>())),
      );

      controller.dispose();
    });

    testWidgets('keeps using stored mounted context when a later open receives unmounted context', (tester) async {
      late BuildContext stableContext;
      late BuildContext removableContext;
      late VoidCallback removeRemovable;
      var showRemovable = true;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 700)),
            child: StatefulBuilder(
              builder: (context, setState) {
                removeRemovable = () {
                  setState(() {
                    showRemovable = false;
                  });
                };

                return Scaffold(
                  body: Column(
                    children: [
                      Builder(
                        builder: (context) {
                          stableContext = context;
                          return const SizedBox();
                        },
                      ),
                      if (showRemovable)
                        Builder(
                          builder: (context) {
                            removableContext = context;
                            return const SizedBox(key: ValueKey('removable-context'));
                          },
                        ),
                      const SizedBox.shrink(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      final controller = PanelController();

      controller.open(stableContext, buildPanel(id: 'a', text: 'A'));
      await tester.pumpAndSettle();

      removeRemovable();
      await tester.pumpAndSettle();

      expect(removableContext.mounted, isFalse);

      controller.open(removableContext, buildPanel(id: 'b', text: 'B'));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      controller.dispose();
    });
  });
}
