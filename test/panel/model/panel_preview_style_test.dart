import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

void main() {
  group('PanelPreviewStyle', () {
    test('has expected defaults', () {
      const style = PanelPreviewStyle();

      expect(style.horizontalSpacing, 8);
      expect(style.verticalSpacing, 8);
      expect(style.expandLastRow, isFalse);
      expect(style.barrierColor, isNull);
      expect(style.barrierDismissible, isTrue);
      expect(style.decoration, isNull);
      expect(style.focusedDecoration, isNull);
    });

    test('supports custom spacing and barrier settings', () {
      const style = PanelPreviewStyle(
        horizontalSpacing: 16,
        verticalSpacing: 12,
        expandLastRow: true,
        barrierColor: Colors.black26,
        barrierDismissible: false,
      );

      expect(style.horizontalSpacing, 16);
      expect(style.verticalSpacing, 12);
      expect(style.expandLastRow, isTrue);
      expect(style.barrierColor, Colors.black26);
      expect(style.barrierDismissible, isFalse);
    });

    test('supports custom decoration variants', () {
      const style = PanelPreviewStyle(
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      );

      expect((style.decoration as BoxDecoration).color, Colors.orange);
      expect((style.focusedDecoration as BoxDecoration).color, Colors.blue);
      expect(
        (style.decoration as BoxDecoration).borderRadius,
        const BorderRadius.all(Radius.circular(10)),
      );
      expect(
        (style.focusedDecoration as BoxDecoration).borderRadius,
        const BorderRadius.all(Radius.circular(14)),
      );
    });

    test('equatable compares spacing and barrier-related fields', () {
      const base = PanelPreviewStyle(
        horizontalSpacing: 8,
        verticalSpacing: 8,
        expandLastRow: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
      );

      const same = PanelPreviewStyle(
        horizontalSpacing: 8,
        verticalSpacing: 8,
        expandLastRow: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
      );

      const differentSpacing = PanelPreviewStyle(
        horizontalSpacing: 9,
        verticalSpacing: 8,
        expandLastRow: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
      );

      const differentBarrier = PanelPreviewStyle(
        horizontalSpacing: 8,
        verticalSpacing: 8,
        expandLastRow: false,
        barrierColor: Colors.black12,
        barrierDismissible: false,
      );

      expect(base, same);
      expect(base, isNot(differentSpacing));
      expect(base, isNot(differentBarrier));
    });
  });
}
