import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay/simple_overlay.dart';

void main() {
  group('SingleOverlayManager Tests', () {
    late SingleOverlayManager manager;

    setUp(() {
      manager = SingleOverlayManager();
    });

    testWidgets('show() adds widget to overlay and updates state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      builder: (context) =>
                          const Text('Hello Overlay', key: Key('overlay_text')),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(manager.hasOverlay, isFalse);
      expect(manager.isShowing, isFalse);

      // Trigger the show method
      await tester.tap(find.text('Show'));
      await tester.pump(); // Start the frame

      // Verify state
      expect(manager.hasOverlay, isTrue);
      expect(manager.isShowing, isTrue);

      // Verify widget is in the tree
      expect(find.byKey(const Key('overlay_text')), findsOneWidget);
    });

    testWidgets('hide() removes widget and clears state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => manager.show(
                    context,
                    builder: (context) => const Text('Overlay Content'),
                  ),
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      // Show it
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.text('Overlay Content'), findsOneWidget);

      // Hide it
      manager.hide();
      await tester.pump(); // Essential to let the UI reflect the removal

      // Verify state is reset
      expect(manager.hasOverlay, isFalse);
      expect(manager.isShowing, isFalse);
      expect(find.text('Overlay Content'), findsNothing);
    });

    testWidgets('show() only show once', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      builder: (context) => const Text(
                        'A',
                        key: ValueKey('A'),
                      ),
                    );
                    manager.show(
                      context,
                      builder: (context) => const Text(
                        'B',
                        key: ValueKey('B'),
                      ),
                    );
                  },
                  child: const Text('Double Show'),
                );
              },
            ),
          ),
        ),
      );

      // This should trigger the assert(!isShowing)
      await tester.tap(find.text('Double Show'));
      await tester.pump();

      // Verify state is reset
      expect(manager.hasOverlay, isTrue);
      expect(manager.isShowing, isTrue);

      expect(find.byKey(const ValueKey('A')), findsOneWidget);
    });
  });
}
