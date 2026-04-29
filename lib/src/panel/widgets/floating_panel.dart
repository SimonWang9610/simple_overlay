import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/src/panel/panel_controller.dart';
import 'package:simple_overlay_kit/src/panel/model/panel.dart';
import 'package:simple_overlay_kit/src/panel/widgets/auto_resize_grid.dart';
import 'package:simple_overlay_kit/src/panel/widgets/panel_cache_key_store.dart';
import 'package:simple_overlay_kit/src/panel/widgets/panel_view.dart';

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
    final scope = context.dependOnInheritedWidgetOfExactType<_PanelScope>();
    return scope?.controller;
  }

  @override
  Widget build(BuildContext context) {
    return _PanelScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, __) {
          final panels = controller.panels;

          if (panels.isEmpty) {
            return const SizedBox.shrink();
          }

          return switch (controller.mode) {
            PanelMode.window => _PanelWindow(
                panels: panels.where((entry) => controller.isVisible(entry.id)).toList(),
              ),
            PanelMode.preview => Center(
                child: _PanelGrid(
                  focusedPanelId: controller.focusedPanel,
                  panels: panels,
                ),
              ),
          };
        },
      ),
    );
  }
}

class _PanelScope extends InheritedWidget {
  final PanelController controller;

  const _PanelScope({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _PanelScope oldWidget) {
    return oldWidget.controller != controller;
  }
}

class _PanelWindow extends StatelessWidget {
  final List<PanelViewEntry> panels;

  const _PanelWindow({
    required this.panels,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final entry in panels)
          ValueListenableBuilder(
            valueListenable: entry.controller,
            builder: (_, settings, child) {
              return Positioned(
                left: settings.geometry.origin.dx,
                top: settings.geometry.origin.dy,
                width: settings.geometry.size.width,
                height: settings.geometry.size.height,
                child: child!,
              );
            },
            child: PanelView(
              key: PanelCacheKeyStore.getCacheKeyForPanel(context, entry.id),
              entry: entry,
            ),
          )
      ],
    );
  }
}

class _PanelGrid extends StatelessWidget {
  final Object? focusedPanelId;
  final List<PanelViewEntry> panels;

  const _PanelGrid({
    this.focusedPanelId,
    required this.panels,
  });

  @override
  Widget build(BuildContext context) {
    return AutoResizeGrid(
      children: [
        for (final entry in panels.reversed)
          Material(
            elevation: entry.id == focusedPanelId ? 8 : 2,
            shape: RoundedRectangleBorder(
              side: entry.id == focusedPanelId ? BorderSide(width: 2) : BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox.fromSize(
                size: entry.controller.value.geometry.size,
                child: PanelView(
                  key: PanelCacheKeyStore.getCacheKeyForPanel(context, entry.id),
                  entry: entry,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
