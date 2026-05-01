import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/model/resize_direction.dart';

import '../panel_test_helpers.dart';

void main() {
  group('PanelViewController', () {
    late _DelegateSpy delegate;
    late PanelConstraints constraints;
    late PanelViewController controller;

    setUp(() {
      delegate = _DelegateSpy();
      constraints = testConstraints(
        screen: const Size(500, 400),
        min: const Size(100, 80),
        max: const Size(300, 220),
      );

      controller = PanelViewController(
        'panel-1',
        delegate: delegate,
        initialState: const PanelViewState(
          title: 'Initial',
          geometry: PanelGeometry(
            origin: Offset(800, 800),
            size: Size(30, 30),
          ),
        ),
        initialConstraints: constraints,
      );
    });

    test('constrains initial geometry during creation', () {
      final state = controller.value;

      expect(state.geometry.size, const Size(100, 80));
      expect(state.geometry.origin.dx, constraints.screenSize.width - constraints.edgeVisibleThreshold);
      expect(state.geometry.origin.dy, constraints.screenSize.height - constraints.edgeVisibleThreshold);
    });

    test('setting title updates state and notifies listeners', () {
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.title = 'Renamed';

      expect(controller.value.title, 'Renamed');
      expect(notifications, 1);
    });

    test('bringToFront and close delegate to focused/closed callbacks', () {
      controller.bringToFront();
      controller.close();

      expect(delegate.focused, ['panel-1']);
      expect(delegate.closed, ['panel-1']);
    });

    test('maximize updates state and restores previous geometry', () {
      controller.move(-120, -90);
      final beforeMaximize = controller.value.geometry;

      controller.maximize();

      expect(controller.value.mode, PanelViewMode.maximized);
      expect(controller.value.geometry, constraints.maximumGeometry);
      expect(delegate.maximized, ['panel-1']);

      controller.restore();

      expect(controller.value.mode, PanelViewMode.normal);
      expect(controller.value.geometry, beforeMaximize);
      expect(delegate.restored, ['panel-1']);
    });

    test('minimize updates state and restore returns to previous geometry', () {
      controller.move(-100, -100);
      final beforeMinimize = controller.value.geometry;

      controller.minimize();
      expect(controller.value.mode, PanelViewMode.minimized);
      expect(delegate.minimized, ['panel-1']);

      controller.restore();
      expect(controller.value.mode, PanelViewMode.normal);
      expect(controller.value.geometry, beforeMinimize);
      expect(delegate.restored, ['panel-1']);
    });

    test('move and resize are constrained to bounds and size limits', () {
      controller.move(-999, -999);
      final moved = controller.value.geometry;
      expect(moved.origin, const Offset(-80, -60));

      controller.resize(const Offset(1000, 1000), ResizeDirection.bottomRight);
      final resized = controller.value.geometry;

      expect(resized.size, const Size(300, 220));
      expect(resized.origin, const Offset(-80, -60));
    });

    test('updating constraints to same value is a no-op, new value re-constrains state', () {
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.constraints = constraints;
      expect(notifications, 0);

      controller.constraints = testConstraints(
        screen: const Size(360, 260),
        min: const Size(120, 90),
        max: const Size(220, 160),
      );

      expect(notifications, 1);
      expect(controller.value.geometry.size, const Size(120, 90));
    });
  });
}

final class _DelegateSpy implements PanelViewDelegate {
  final List<Object> minimized = [];
  final List<Object> maximized = [];
  final List<Object> restored = [];
  final List<Object> closed = [];
  final List<Object> focused = [];

  @override
  void onPanelClosed(Object panelId) {
    closed.add(panelId);
  }

  @override
  void onPanelFocused(Object panelId) {
    focused.add(panelId);
  }

  @override
  void onPanelMaximize(Object panelId) {
    maximized.add(panelId);
  }

  @override
  void onPanelMinimize(Object panelId) {
    minimized.add(panelId);
  }

  @override
  void onPanelRestore(Object panelId) {
    restored.add(panelId);
  }
}
