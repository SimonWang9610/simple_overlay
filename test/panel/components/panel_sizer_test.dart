import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

void main() {
  group('PanelSizer', () {
    final constraints = PanelConstraints(
      minSize: const Size(120, 80),
      maxSize: const Size(1000, 600),
      origin: Offset.zero,
    );

    test('scale uses default 0.8 of max size', () {
      const sizer = PanelSizer.scale();

      final size = sizer.constrain(constraints);

      expect(size, const Size(800, 480));
    });

    test('scale uses custom factor', () {
      const sizer = PanelSizer.scale(scale: 0.5);

      final size = sizer.constrain(constraints);

      expect(size, const Size(500, 300));
    });

    test('aspectRatio uses width-constrained branch when max is narrow', () {
      const sizer = PanelSizer.aspectRatio(aspectRatio: 2, scale: 1);
      final narrowConstraints = PanelConstraints(
        minSize: const Size(80, 60),
        maxSize: const Size(600, 500),
      );

      final size = sizer.constrain(narrowConstraints);

      expect(size, const Size(600, 300));
    });

    test('aspectRatio uses height-constrained branch when max is wide', () {
      const sizer = PanelSizer.aspectRatio(aspectRatio: 2, scale: 1);
      final wideConstraints = PanelConstraints(
        minSize: const Size(80, 60),
        maxSize: const Size(1200, 500),
      );

      final size = sizer.constrain(wideConstraints);

      expect(size, const Size(1000, 500));
    });

    test('fixed size is clamped by constraints bounds', () {
      const sizer = PanelSizer.fixed(size: Size(10, 2000));

      final size = sizer.constrain(constraints);

      expect(size, const Size(120, 600));
    });
  });
}
