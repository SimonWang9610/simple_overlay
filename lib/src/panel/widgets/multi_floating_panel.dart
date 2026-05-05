import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/panels.dart';

import 'package:simple_overlay_kit/src/panel/widgets/grid_flow.dart';
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
                  panelConstraints: controller.constraints,
                  switchToWindowMode: () {
                    controller.mode = PanelMode.window;
                  },
                ),
              ),
          };

          return PanelTheme(
            config: controller.config,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: panel,
            ),
          );
        },
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
    final config = PanelTheme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        for (final entry in panels)
          ValueListenableBuilder(
            key: ValueKey(entry.id),
            valueListenable: entry.controller,
            builder: (_, settings, child) {
              return Positioned(
                left: settings.geometry.origin.dx,
                top: settings.geometry.origin.dy,
                width: settings.geometry.size.width,
                height: settings.geometry.size.height,
                child: entry.addRepaintBoundary ? RepaintBoundary(child: child) : child!,
              );
            },
            child: Offstage(
              offstage: !controller.isVisible(entry.id),
              child: config.wrap(
                PanelEntryView(
                  key: PanelCacheKeyStore.getCacheKeyForPanel(context, entry.id),
                  entry: entry,
                ),
                focused: focusedPanelId == entry.id,
                preview: false,
              ),
            ),
          )
      ],
    );
  }
}

class _PanelGrid extends StatefulWidget {
  final Object? focusedPanelId;
  final VoidCallback? switchToWindowMode;
  final Iterable<PanelEntry> panels;
  final PanelConstraints panelConstraints;

  _PanelGrid({
    this.focusedPanelId,
    this.switchToWindowMode,
    required this.panels,
    required this.panelConstraints,
  }) : assert(
          focusedPanelId == null || panels.isEmpty || panels.any((entry) => entry.id == focusedPanelId),
          'Focused panel must be the topmost panel in the grid.',
        );

  @override
  State<_PanelGrid> createState() => _PanelGridState();
}

class _PanelGridState extends State<_PanelGrid> {
  late final _focusing = ValueNotifier<Object?>(widget.focusedPanelId);
  late List<PanelEntry> _panels = widget.panels.toList();

  @override
  void didUpdateWidget(_PanelGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusedPanelId != widget.focusedPanelId) {
      _focusing.value = widget.focusedPanelId;
    }

    if (oldWidget.panels != widget.panels) {
      _panels = widget.panels.toList();
    }
  }

  @override
  void dispose() {
    _panels.clear();
    _focusing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geometry = widget.panelConstraints.maximumGeometry;
    final config = PanelTheme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: config.previewStyle.barrierDismissible ? widget.switchToWindowMode : null,
            child: ColoredBox(
              color: config.previewStyle.barrierColor ?? Colors.transparent,
            ),
          ),
        ),
        Positioned(
          top: geometry.origin.dy,
          left: geometry.origin.dx,
          width: geometry.size.width,
          height: geometry.size.height,
          child: Flow(
            delegate: PanelGridFlowDelegate(
              entries: _panels,
              panelConstraints: widget.panelConstraints,
              horizontalSpacing: config.previewStyle.horizontalSpacing,
              verticalSpacing: config.previewStyle.verticalSpacing,
              expandLastRow: config.previewStyle.expandLastRow,
            ),
            children: [
              for (final entry in _panels)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: MouseRegion(
                    onHover: (_) {
                      _focusing.value = entry.id;
                    },
                    child: GestureDetector(
                      onTap: () {
                        entry.controller.bringToFront();
                        widget.switchToWindowMode?.call();
                      },
                      child: Center(
                        child: ValueListenableBuilder(
                          valueListenable: _focusing,
                          builder: (context, focusedId, child) {
                            final panelView = config.wrap(
                              SizedBox.fromSize(
                                size: entry.controller.value.geometry.size,
                                child: PanelEntryView(
                                  key: PanelCacheKeyStore.getCacheKeyForPanel(context, entry.id),
                                  enabled: false,
                                  entry: entry,
                                ),
                              ),
                              focused: focusedId == entry.id,
                              preview: true,
                            );

                            if (entry.addRepaintBoundary) {
                              return RepaintBoundary(child: panelView);
                            } else {
                              return panelView;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
