import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

void main() {
  group('PanelConstraints', () {
    test('scale computes min/max size and centered origin', () {
      final constraints = PanelConstraints.scale(
        const Size(1000, 800),
        minSizeRatio: 0.25,
        maxSizeRatio: 0.5,
      );

      expect(constraints.minSize, const Size(250, 200));
      expect(constraints.maxSize, const Size(500, 400));
      expect(constraints.origin, const Offset(250, 200));
    });

    test('fromPadding computes origin and max size from safe area', () {
      final constraints = PanelConstraints.fromPadding(
        const Size(1200, 900),
        padding: const EdgeInsets.fromLTRB(40, 20, 60, 80),
        minSize: const Size(100, 90),
      );

      expect(constraints.origin, const Offset(40, 20));
      expect(constraints.maxSize, const Size(1100, 800));
      expect(constraints.minSize, const Size(100, 90));
    });

    test('constrainSize enforces min and max bounds', () {
      final constraints = PanelConstraints(
        minSize: const Size(100, 80),
        maxSize: const Size(300, 220),
      );

      expect(constraints.constrainSize(const Size(10, 10)), const Size(100, 80));
      expect(constraints.constrainSize(const Size(500, 500)), const Size(300, 220));
      expect(constraints.constrainSize(const Size(180, 160)), const Size(180, 160));
    });

    test('constrain keeps geometry unchanged when already within bounds', () {
      final constraints = PanelConstraints(
        minSize: Size(100, 80),
        maxSize: Size(400, 300),
      );

      const geometry = PanelGeometry(
        origin: Offset(40, 30),
        size: Size(200, 120),
      );

      expect(constraints.constrain(geometry), geometry);
    });

    test('constrain repositions geometry to keep edge visibility', () {
      final constraints = PanelConstraints(
        minSize: Size(100, 80),
        maxSize: Size(300, 220),
        edgeVisibleThreshold: 20,
      );

      const farOutside = PanelGeometry(
        origin: Offset(1000, 1000),
        size: Size(80, 60),
      );

      final constrained = constraints.constrain(farOutside);

      expect(constrained.size, const Size(100, 80));
      expect(constrained.origin, const Offset(280, 200));
    });
  });
}
