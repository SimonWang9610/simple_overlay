import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/simple_overlay.dart';
import 'package:simple_overlay_kit/src/overlay_route.dart';

import 'test_helpers.dart';

void main() {
  group('BarrierConfig', () {
    test('supports value equality and hashCode', () {
      const a = BarrierConfig(
        color: Color(0x7F123456),
        dismissible: false,
        label: 'barrier',
        curve: Curves.easeIn,
      );
      const b = BarrierConfig(
        color: Color(0x7F123456),
        dismissible: false,
        label: 'barrier',
        curve: Curves.easeIn,
      );
      const c = BarrierConfig();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('FloatingConfig value semantics', () {
    test('RawOverlayConfig uses value equality', () {
      const a = RawOverlayConfig(
        rootOverlay: true,
        opaque: true,
        maintainState: true,
        builder: builderA,
      );
      const b = RawOverlayConfig(
        rootOverlay: true,
        opaque: true,
        maintainState: true,
        builder: builderA,
      );
      const c = RawOverlayConfig(builder: builderB);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('OverlayRouteConfig uses value equality', () {
      const barrier = BarrierConfig(label: 'x');
      const a = OverlayRouteConfig(
        rootOverlay: true,
        opaque: true,
        maintainState: true,
        barrierConfig: barrier,
        builder: builderA,
      );
      const b = OverlayRouteConfig(
        rootOverlay: true,
        opaque: true,
        maintainState: true,
        barrierConfig: barrier,
        builder: builderA,
      );
      const c = OverlayRouteConfig(builder: builderB);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('TransitionRouteConfig route creation', () {
    test('DialogRouteConfig creates RawDialogRoute with barrier settings', () {
      const config = DialogRouteConfig(
        barrierConfig: BarrierConfig(
          label: 'dialog-barrier',
          dismissible: false,
        ),
        transitionDuration: Duration(milliseconds: 123),
        builder: routePageBuilder,
      );

      final route = config.route as RawDialogRoute;

      expect(route.transitionDuration, const Duration(milliseconds: 123));
      expect(route.barrierDismissible, isFalse);
      expect(route.barrierLabel, 'dialog-barrier');
    });

    test('SimpleTransitionRouteConfig creates expected transition route', () {
      const config = SimpleTransitionRouteConfig(
        barrierConfig: BarrierConfig(label: 'simple'),
        transitionDuration: Duration(milliseconds: 111),
        reverseTransitionDuration: Duration(milliseconds: 222),
        builder: routePageBuilder,
      );

      final route = config.route as SimpleTransitionRoute;

      expect(route.transitionDuration, const Duration(milliseconds: 111));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 222),
      );
      expect(route.barrier?.label, 'simple');
    });
  });
}
