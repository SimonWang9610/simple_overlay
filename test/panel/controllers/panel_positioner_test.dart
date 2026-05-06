import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/components/panel_positioner.dart';

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
  });
}
