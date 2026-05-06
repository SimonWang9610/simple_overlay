import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

void main() {
  group('PanelPositioner', () {
    final panel = Panel(
      id: 'panel',
      initialSize: const Size(120, 90),
      builder: (_, __) => const SizedBox(),
    );

    final constraints = PanelConstraints(
      minSize: Size(80, 60),
      maxSize: Size(800, 600),
      origin: Offset(30, 40),
    );

    test('origin positioner always returns constraints origin', () {
      final positioner = PanelPositioner.alwaysOrigin();

      final result = positioner.find(const <PanelGeometry>[], constraints, panel.initialSize!);

      expect(result, const Offset(30, 40));
    });

    test('cascade returns origin when no other panels', () {
      final positioner = PanelPositioner.cascade(offset: const Offset(20, 20), margin: 20);

      final result = positioner.find(const <PanelGeometry>[], constraints, panel.initialSize!);

      expect(result, const Offset(30, 40));
    });

    test('cascade offsets candidate while origin overlaps ordered panels', () {
      final positioner = PanelPositioner.cascade(offset: const Offset(20, 20), margin: 10);

      final others = [
        const PanelGeometry(origin: Offset(30, 40), size: Size(200, 120)),
        const PanelGeometry(origin: Offset(50, 60), size: Size(160, 120)),
      ];

      final result = positioner.find(others, constraints, panel.initialSize!);

      expect(result, const Offset(70, 80));
    });

    test('follow aligns panel anchor with screen anchor and offset', () {
      final positioner = PanelPositioner.follow(
        panelAlignment: Alignment.center,
        screenAlignment: Alignment.bottomRight,
        offset: const Offset(-10, -15),
      );

      final result = positioner.find(const <PanelGeometry>[], constraints, panel.initialSize!);

      expect(result, const Offset(730, 540));
    });

    test('alwaysOrigin ignores existing panels and panel size', () {
      final positioner = PanelPositioner.alwaysOrigin();

      final result = positioner.find(
        const [PanelGeometry(origin: Offset(0, 0), size: Size(300, 200))],
        constraints,
        const Size(999, 999),
      );

      expect(result, constraints.origin);
    });

    test('cascade stops offsetting once candidate no longer overlaps next rect', () {
      final positioner = PanelPositioner.cascade(offset: const Offset(20, 20), margin: 0);

      final others = [
        const PanelGeometry(origin: Offset(30, 40), size: Size(40, 40)),
        const PanelGeometry(origin: Offset(80, 90), size: Size(40, 40)),
      ];

      final result = positioner.find(others, constraints, panel.initialSize!);

      expect(result, const Offset(50, 60));
    });

    test('follow with defaults aligns top-left and only applies offset', () {
      const positioner = PanelPositioner.follow(offset: Offset(7, 11));

      final result = positioner.find(const <PanelGeometry>[], constraints, panel.initialSize!);

      expect(result, const Offset(7, 11));
    });
  });
}
