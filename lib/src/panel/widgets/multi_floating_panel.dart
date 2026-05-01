import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/panels.dart';

import 'package:simple_overlay_kit/src/panel/widgets/auto_resize_grid.dart';
import 'package:simple_overlay_kit/src/panel/widgets/panel_cache_key_store.dart';
import 'package:simple_overlay_kit/src/panel/widgets/panel_entry_view.dart';

class MultiFloatingPanel extends StatelessWidget {
  final PanelController controller;
  const MultiFloatingPanel({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PanelScope(
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

class _PanelGrid extends StatelessWidget {
  final Object? focusedPanelId;
  final VoidCallback? onPanelTap;
  final Iterable<PanelEntry> panels;

  _PanelGrid({
    this.focusedPanelId,
    this.onPanelTap,
    required this.panels,
  }) : assert(
          focusedPanelId == null || panels.isEmpty || panels.any((entry) => entry.id == focusedPanelId),
          'Focused panel must be the topmost panel in the grid.',
        );

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
                      child: PanelEntryView(
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

class _PanelStack extends StatelessWidget {
  final PanelController controller;

  /// The currently focused panel. This panel will be shown with a highlighted border.
  final Object? focusedPanelId;

  /// Panels to show in this window, in z-order (from back to front).
  final Iterable<PanelEntry> panels;

  _PanelStack({
    required this.controller,
    required this.panels,
    this.focusedPanelId,
  }) : assert(
          focusedPanelId == null || panels.isEmpty || panels.last.id == focusedPanelId,
          'Focused panel must be the topmost panel in the window.',
        );

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
              child: PanelEntryView(
                key: PanelCacheKeyStore.getCacheKeyForPanel(context, entry.id),
                entry: entry,
              ),
            ),
          )
      ],
    );
  }
}
