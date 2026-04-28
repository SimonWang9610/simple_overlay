import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/src/panel/panel_view_registry.dart';
import 'package:simple_overlay_kit/src/panel/model/panel.dart';

class PanelScope extends StatefulWidget {
  final PanelBounds? bounds;
  final Panel panel;

  const PanelScope({
    super.key,
    required this.panel,
    this.bounds,
  });

  @override
  State<PanelScope> createState() => _PanelScopeState();
}

class _PanelScopeState extends State<PanelScope> {
  late PanelRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = PanelRegistry(
      widget.panel,
      initialBounds: widget.bounds,
    );
  }

  @override
  void didUpdateWidget(covariant PanelScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.panel.id != widget.panel.id) {
      _registry.dispose();
      _registry = PanelRegistry(widget.panel);
    }

    if (oldWidget.bounds != widget.bounds) {
      _registry.bounds = widget.bounds;
    }
  }

  @override
  void dispose() {
    _registry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RegistryScope(
      registry: _registry,
      child: ListenableBuilder(
        listenable: _registry,
        builder: (_, __) {
          final panels = _registry.visiblePanels;

          if (panels.isEmpty) {
            return const SizedBox.shrink();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              for (final entry in panels)
                ValueListenableBuilder(
                  valueListenable: entry.controller,
                  builder: (_, settings, child) {
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: settings.geometry.origin.dx,
                      top: settings.geometry.origin.dy,
                      width: settings.geometry.size.width,
                      height: settings.geometry.size.height,
                      child: child!,
                    );
                  },
                  child: _PanelWidget(entry: entry),
                )
            ],
          );
        },
      ),
    );
  }
}

class _RegistryScope extends InheritedWidget {
  final PanelRegistry registry;

  const _RegistryScope({
    required this.registry,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _RegistryScope oldWidget) {
    return oldWidget.registry != registry;
  }
}

class _PanelWidget extends StatefulWidget {
  final PanelViewEntry entry;

  const _PanelWidget({
    required this.entry,
  });

  @override
  State<_PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<_PanelWidget> {
  final cursor = ValueNotifier(SystemMouseCursors.basic);

  @override
  void dispose() {
    cursor.dispose();
    super.dispose();
  }

  // todo: update cursor based on hover position (e.g. resize handles, title bar, etc.) to distinguish move/resize
  // void _updateCursor() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.entry.controller.bringToFront,
      onPanStart: (_) => widget.entry.controller.bringToFront(),
      onPanUpdate: (details) {
        widget.entry.controller.move(
          details.delta.dx,
          details.delta.dy,
        );
      },
      child: ValueListenableBuilder(
        valueListenable: cursor,
        builder: (context, cursor, child) {
          return MouseRegion(
            cursor: cursor,
            child: child,
          );
        },
        child: widget.entry.builder(
          context,
          widget.entry.controller,
        ),
      ),
    );
  }
}
