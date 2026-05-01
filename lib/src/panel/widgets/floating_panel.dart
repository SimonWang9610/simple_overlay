import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/simple_overlay_kit.dart';
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
          if (!controller.hasPanels) {
            return const SizedBox.shrink();
          }

          final panel = switch (controller.mode) {
            PanelMode.window => _PanelWindow(
                controller: controller,
                panels: controller.panels,
                focusedPanelId: controller.focusedPanel,
              ),
            PanelMode.preview => Center(
                child: _PanelGrid(
                  focusedPanelId: controller.focusedPanel,
                  panels: controller.unorderedPanels,
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
  final PanelController controller;
  final Object? focusedPanelId;
  final Iterable<PanelViewEntry> panels;

  const _PanelWindow({
    required this.controller,
    required this.panels,
    this.focusedPanelId,
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
                child: Offstage(
                  offstage: !controller.isVisible(entry.id),
                  child: child,
                ),
              );
            },
            child: Material(
              elevation: entry.id == focusedPanelId ? 10 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: PanelView(
                key: PanelCacheKeyStore.getCacheKeyForPanel(context, entry.id),
                entry: entry,
              ),
            ),
          )
      ],
    );
  }
}

class _PanelGrid extends StatelessWidget {
  final Object? focusedPanelId;
  final VoidCallback? onPanelTap;
  final Iterable<PanelViewEntry> panels;

  const _PanelGrid({
    this.focusedPanelId,
    this.onPanelTap,
    required this.panels,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return SizedBox.fromSize(
      size: screenSize * 0.8,
      child: AutoResizeGrid(
        children: [
          for (final entry in panels)
            Material(
              elevation: entry.id == focusedPanelId ? 8 : 2,
              shape: RoundedRectangleBorder(
                side: entry.id == focusedPanelId ? BorderSide() : BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onHover: (value) {
                  if (value) {
                    entry.controller.bringToFront();
                  }
                },
                onTap: () {
                  entry.controller.bringToFront();
                  onPanelTap?.call();
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Center(
                    child: SizedBox.fromSize(
                      size: entry.controller.value.geometry.size,
                      child: PanelView(
                        key: PanelCacheKeyStore.getCacheKeyForPanel(context, entry.id),
                        enabled: false,
                        entry: entry,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
