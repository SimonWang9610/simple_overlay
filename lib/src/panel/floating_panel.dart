import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/panels.dart';

import 'package:simple_overlay_kit/src/panel/widgets/auto_resize_grid.dart';
import 'package:simple_overlay_kit/src/panel/widgets/panel_cache_key_store.dart';
import 'package:simple_overlay_kit/src/panel/widgets/panel_view.dart';

part 'widgets/panel_grid.dart';
part 'widgets/panel_stack.dart';

class FloatingPanel extends StatelessWidget {
  final PanelController controller;

  const FloatingPanel({
    super.key,
    required this.controller,
  });

  static PanelController of(BuildContext context) {
    final controller = maybeOf(context);

    if (controller == null) {
      throw FlutterError(
        'PanelController.of() called with a context that does not contain a PanelController.\n'
        'Make sure to wrap your widget tree with a FloatingPanel.',
      );
    }

    return controller;
  }

  static PanelController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_Scope>();
    return scope?.controller;
  }

  @override
  Widget build(BuildContext context) {
    return _Scope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, __) {
          if (!controller.hasPanels) {
            return const SizedBox.shrink();
          }

          final panel = switch (controller.mode) {
            PanelMode.window => _PanelStack(
                controller: controller,
                panels: controller.orderedPanels,
                focusedPanelId: controller.focusedPanel,
              ),
            PanelMode.preview => Center(
                child: _PanelGrid(
                  focusedPanelId: controller.focusedPanel,
                  panels: controller.panels,
                  onPanelTap: () {
                    controller.mode = PanelMode.window;
                  },
                ),
              ),
          };

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: panel,
          );
        },
      ),
    );
  }
}

class _Scope extends InheritedWidget {
  final PanelController controller;

  const _Scope({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _Scope oldWidget) {
    return oldWidget.controller != controller;
  }
}
