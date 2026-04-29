import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/simple_overlay_kit.dart';
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
                controller: controller,
                panels: panels,
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
  final PanelController controller;
  final List<PanelViewEntry> panels;

  const _PanelWindow({
    required this.controller,
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
                child: Offstage(
                  offstage: !controller.isVisible(entry.id),
                  child: child,
                ),
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

class _PanelGrid extends StatefulWidget {
  final Object? focusedPanelId;
  final List<PanelViewEntry> panels;

  const _PanelGrid({
    this.focusedPanelId,
    required this.panels,
  });

  @override
  State<_PanelGrid> createState() => _PanelGridState();
}

class _PanelGridState extends State<_PanelGrid> {
  @override
  Widget build(BuildContext context) {
    return AutoResizeGrid(
      children: [
        for (final entry in widget.panels.reversed)
          Material(
            elevation: entry.id == widget.focusedPanelId ? 8 : 2,
            shape: RoundedRectangleBorder(
              side: entry.id == widget.focusedPanelId ? BorderSide(width: 2) : BorderSide.none,
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

typedef PanelDockWidgetBuilder = Widget Function(
  BuildContext context,
  PanelViewController controller,
  bool isFocused,
);

class FloatingPanelDock extends StatelessWidget {
  final PanelController controller;
  final PanelDockWidgetBuilder builder;

  const FloatingPanelDock({
    super.key,
    required this.controller,
    this.builder = _defaultPanelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in controller.unorderedPanels)
                builder(
                  context,
                  entry.controller,
                  entry.id == controller.focusedPanel,
                ),
            ],
          ),
        );
      },
    );
  }
}

Widget _defaultPanelBuilder(BuildContext context, PanelViewController controller, bool isFocused) {
  return _DefaultDockItem(controller: controller, isFocused: isFocused);
}

class _DefaultDockItem extends StatelessWidget {
  final bool isFocused;
  final PanelViewController controller;
  const _DefaultDockItem({
    required this.controller,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFocused ? Colors.green : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, settings, child) {
          return SizedBox(
            width: 100,
            child: GestureDetector(
              onTap: () {
                if (settings.mode == PanelViewMode.minimized) {
                  controller.restore();
                } else {
                  if (isFocused) {
                    controller.minimize();
                  } else {
                    controller.bringToFront();
                  }
                }
              },
              child: Row(
                spacing: 6,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      controller.close();
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      settings.title ?? "Untitled Panel",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    settings.mode == PanelViewMode.minimized ? Icons.open_in_full : Icons.minimize,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
