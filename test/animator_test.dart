import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay/simple_overlay.dart';

void main() {
  group('OverlayAnimator Tests', () {
    testWidgets('show() triggers animation and displays widget', (
      WidgetTester tester,
    ) async {
      // 1. Setup Controller using the tester's ticker provider
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      final animator = OverlayAnimator(controller);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Container())));
      final context = tester.element(find.byType(Scaffold));

      // 2. Define an animation (e.g., Fade transition 0.0 -> 1.0)
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

      // 3. Show the overlay (don't await yet as it waits for animation to finish)
      final showFuture = animator.show(
        context,
        animation: animation,
        builder: (context, anim) => FadeTransition(
          opacity: anim as Animation<double>,
          child: const Text('Animated Content'),
        ),
      );

      // 4. Verify initial state (start of animation)
      await tester.pump(); // First frame to insert the overlay

      expect(animator.isShowing, isTrue);

      await tester.pumpAndSettle(Duration(milliseconds: 300));

      // 5. Verify final state (end of animation)
      expect(find.text('Animated Content'), findsOneWidget);
      expect(animation.value, equals(1.0));

      await showFuture;
    });

    testWidgets('drive() updates animation and rebuilds', (
      WidgetTester tester,
    ) async {
      final controller = AnimationController(vsync: const TestVSync());
      final animator = OverlayAnimator<double>(controller);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Container())));
      final context = tester.element(find.byType(Scaffold));

      // Show initial animation
      final showFuture = animator.show(
        context,
        animation: AlwaysStoppedAnimation<double>(0.0),
        builder: (context, anim) => AnimatedBuilder(
          animation: anim,
          builder: (context, child) => Text('Content ${anim.value}'),
        ),
        duration: Duration(milliseconds: 150),
      );

      await tester.pumpAndSettle(Duration(milliseconds: 150));
      await showFuture;

      expect(animator.isShowing, isTrue);
      expect(find.text('Content 0.0'), findsOneWidget);

      // Drive a new animation (e.g., changing values)
      final newAnimation = Tween<double>(
        begin: 5.0,
        end: 10.0,
      ).animate(controller);

      final driveFuture = animator.drive(
        animation: newAnimation,
        duration: Duration(milliseconds: 150),
      );

      await tester.pumpAndSettle(Duration(milliseconds: 150));

      // Verify the new animation values are reflected in the widget
      expect(find.text('Content 10.0'), findsOneWidget);

      // Clean up
      await driveFuture;
    });

    testWidgets('dispose() hides overlay and disposes controller', (
      WidgetTester tester,
    ) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      final animator = OverlayAnimator(controller);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Container())));
      final context = tester.element(find.byType(Scaffold));

      final showFuture = animator.show(
        context,
        animation: controller,
        builder: (context, _) => const Text('Dispose Me'),
      );

      await tester.pumpAndSettle(Duration(milliseconds: 300));

      expect(animator.isShowing, isTrue);
      await showFuture;

      animator.dispose();

      await tester.pump();

      expect(animator.isShowing, isFalse);

      try {
        controller.forward();
      } catch (e) {
        expect(e, isAssertionError);
      }
    });
  });
}
