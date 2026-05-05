import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

void main() {
  group('PanelConfig.wrap', () {
    testWidgets('uses normal decoration when not focused and not preview', (tester) async {
      final config = PanelConfig(
        decoration: const BoxDecoration(color: Colors.red),
        focusedDecoration: const BoxDecoration(color: Colors.blue),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: config.wrap(const SizedBox(key: ValueKey('panel'))),
        ),
      );

      final decorated = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      expect((decorated.decoration as BoxDecoration).color, Colors.red);
      expect(find.byType(ClipRRect), findsNothing);
    });

    testWidgets('uses preview decorations and focused fallback in preview mode', (tester) async {
      final config = PanelConfig(
        decoration: const BoxDecoration(color: Colors.red),
        focusedDecoration: const BoxDecoration(color: Colors.blue),
        previewStyle: const PanelPreviewStyle(
          decoration: BoxDecoration(color: Colors.green),
        ),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              config.wrap(const SizedBox(), preview: true, focused: false),
              config.wrap(const SizedBox(), preview: true, focused: true),
            ],
          ),
        ),
      );

      final decorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((widget) => widget.decoration as BoxDecoration)
          .toList();

      expect(decorations[0].color, Colors.green);
      expect(decorations[1].color, Colors.blue);
    });

    testWidgets('wrap clips child when selected decoration has border radius', (tester) async {
      final config = PanelConfig(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedDecoration: const BoxDecoration(color: Colors.blue),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: config.wrap(const SizedBox()),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
