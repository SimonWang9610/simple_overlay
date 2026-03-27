import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay/simple_overlay.dart';

import 'test_helpers.dart';

void main() {
  group('FloatingController.withConfig', () {
    testWidgets('creates raw overlay controller branch', (tester) async {
      final controller = FloatingController.withConfig(
        const RawOverlayConfig(builder: builderA),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);
      expect(find.text('A'), findsOneWidget);

      controller.hide();
      await tester.pump();

      expect(controller.value, isFalse);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('creates transition route controller branch', (tester) async {
      final controller = FloatingController.withConfig(
        const SimpleTransitionRouteConfig(
          transitionDuration: Duration(milliseconds: 100),
          builder: routePageBuilder,
        ),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(controller.value, isTrue);
      expect(find.text('route-page'), findsOneWidget);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('route-page'), findsNothing);
    });
  });

  group('FloatingController.overlay', () {
    testWidgets('show/hide updates state and listeners with no barrier added', (
      tester,
    ) async {
      final controller = FloatingController.overlay(
        builder: (_) => const Text('overlay-entry-content'),
      );
      var notifications = 0;
      controller.addListener(() => notifications++);

      final context = await pumpAppAndGetContext(tester);
      final barrierBaseline = countAllBarriers(tester);

      expect(controller.value, isFalse);

      controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);
      expect(find.text('overlay-entry-content'), findsOneWidget);
      expect(countAllBarriers(tester), barrierBaseline);

      controller.show(context);
      await tester.pump();
      expect(find.text('overlay-entry-content'), findsOneWidget);

      controller.hide();
      await tester.pump();

      expect(controller.value, isFalse);
      expect(find.text('overlay-entry-content'), findsNothing);
      expect(countAllBarriers(tester), barrierBaseline);
      expect(notifications, greaterThanOrEqualTo(2));
    });

    testWidgets('dispose while showing removes entry and clears value', (
      tester,
    ) async {
      final controller = FloatingController.overlay(
        builder: (_) => const Text('overlay-entry-dispose'),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      expect(controller.value, isTrue);
      expect(find.text('overlay-entry-dispose'), findsOneWidget);

      controller.dispose();
      await tester.pump();

      expect(controller.value, isFalse);
      expect(find.text('overlay-entry-dispose'), findsNothing);
    });
  });

  group('FloatingController.route', () {
    testWidgets('without barrier config pushes and pops route content', (
      tester,
    ) async {
      final controller = FloatingController.route(
        builder: (_) => const Text('route-controller-no-barrier'),
      );

      final context = await pumpAppAndGetContext(tester);
      final barrierBaseline = countAllBarriers(tester);

      controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);
      expect(find.text('route-controller-no-barrier'), findsOneWidget);
      expect(countAllBarriers(tester), barrierBaseline);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('route-controller-no-barrier'), findsNothing);
      expect(countAllBarriers(tester), barrierBaseline);
    });

    testWidgets('with barrier config renders labeled barrier', (tester) async {
      const barrierLabel = 'route-controller-barrier';
      final controller = FloatingController.withConfig(
        const OverlayRouteConfig(
          barrierConfig: BarrierConfig(label: barrierLabel),
          builder: builderA,
        ),
      );

      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);
      expect(find.text('A'), findsOneWidget);
      expect(
        countBarriersWithLabel(tester, barrierLabel),
        greaterThanOrEqualTo(1),
      );

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(countBarriersWithLabel(tester, barrierLabel), 0);
    });

    testWidgets('hide removes route without navigator pop', (tester) async {
      final controller = FloatingController.route(
        barrierConfig: const BarrierConfig(label: 'route-hide-barrier'),
        builder: (_) => const Text('route-controller-hide'),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);
      expect(find.text('route-controller-hide'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('route-controller-hide'), findsNothing);
      expect(countBarriersWithLabel(tester, 'route-hide-barrier'), 0);
    });

    testWidgets('calling show twice keeps a single active route', (
      tester,
    ) async {
      final controller = FloatingController.route(
        builder: (_) => const Text('route-show-twice'),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);
      expect(find.text('route-show-twice'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();
      expect(controller.value, isFalse);
      expect(find.text('route-show-twice'), findsNothing);
    });

    testWidgets('dispose while route is active clears state', (tester) async {
      final controller = FloatingController.route(
        builder: (_) => const Text('route-dispose-active'),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      expect(controller.value, isTrue);

      controller.dispose();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('route-dispose-active'), findsNothing);
    });
  });

  group('FloatingController.custom transition', () {
    testWidgets('without barrier config renders route content only', (
      tester,
    ) async {
      final controller = FloatingController.custom(
        transitionDuration: const Duration(milliseconds: 100),
        builder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const Text('custom-transition-no-barrier'),
      );

      final context = await pumpAppAndGetContext(tester);
      final barrierBaseline = countAllBarriers(tester);

      controller.show(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(controller.value, isTrue);
      expect(find.text('custom-transition-no-barrier'), findsOneWidget);
      expect(countAllBarriers(tester), barrierBaseline);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('custom-transition-no-barrier'), findsNothing);
      expect(countAllBarriers(tester), barrierBaseline);
    });

    testWidgets('with barrier config renders labeled barrier', (tester) async {
      const barrierLabel = 'custom-transition-barrier';
      final controller = FloatingController.custom(
        transitionDuration: const Duration(milliseconds: 100),
        barrierConfig: const BarrierConfig(
          label: barrierLabel,
          curve: Curves.linear,
        ),
        builder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const Text('custom-transition-with-barrier'),
      );

      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(controller.value, isTrue);
      expect(find.text('custom-transition-with-barrier'), findsOneWidget);
      expect(
        countBarriersWithLabel(tester, barrierLabel),
        greaterThanOrEqualTo(1),
      );

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(countBarriersWithLabel(tester, barrierLabel), 0);
    });

    testWidgets('hide is safe before show', (tester) async {
      final controller = FloatingController.custom(
        builder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const Text('custom-hide-before-show'),
      );

      await controller.hide();
      expect(controller.value, isFalse);

      final context = await pumpAppAndGetContext(tester);
      controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(controller.value, isFalse);
    });

    testWidgets('hide removes active transition route', (tester) async {
      final controller = FloatingController.custom(
        transitionDuration: const Duration(milliseconds: 100),
        builder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const Text('custom-hide-active'),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(controller.value, isTrue);

      await controller.hide();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('custom-hide-active'), findsNothing);
    });

    testWidgets('calling show twice while active is a no-op', (tester) async {
      final controller = FloatingController.custom(
        transitionDuration: const Duration(milliseconds: 100),
        builder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const Text('custom-show-twice'),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      await controller.show(context);
      await tester.pump();

      expect(controller.value, isTrue);
      expect(find.text('custom-show-twice'), findsOneWidget);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(controller.value, isFalse);
    });

    testWidgets('dispose while active transition route clears state', (
      tester,
    ) async {
      final controller = FloatingController.custom(
        transitionDuration: const Duration(milliseconds: 100),
        builder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const Text('custom-dispose-active'),
      );
      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(controller.value, isTrue);

      controller.dispose();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('custom-dispose-active'), findsNothing);
    });
  });

  group('FloatingController.dialog transition', () {
    testWidgets('uses barrier config and clears state after pop', (
      tester,
    ) async {
      const barrierLabel = 'dialog-controller-barrier';
      final controller = FloatingController.dialog(
        barrierConfig: const BarrierConfig(
          label: barrierLabel,
          dismissible: false,
        ),
        builder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => const Text('dialog-controller-content'),
      );

      final context = await pumpAppAndGetContext(tester);

      controller.show(context);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(controller.value, isTrue);
      expect(find.text('dialog-controller-content'), findsOneWidget);
      expect(
        countBarriersWithLabel(tester, barrierLabel),
        greaterThanOrEqualTo(1),
      );

      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(controller.value, isFalse);
      expect(find.text('dialog-controller-content'), findsNothing);
      expect(countBarriersWithLabel(tester, barrierLabel), 0);
    });
  });
}
