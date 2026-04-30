import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/simple_overlay_kit.dart';

typedef PanelDockWidgetBuilder = Widget Function(
  BuildContext context,
  PanelViewController controller,
  bool isFocused,
);

Widget _defaultPanelBuilder(BuildContext context, PanelViewController controller, bool isFocused) {
  return _DefaultDockItem(controller: controller, isFocused: isFocused);
}

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
            spacing: 4,
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

class _DefaultDockItem extends StatelessWidget {
  final bool isFocused;
  final PanelViewController controller;
  const _DefaultDockItem({
    required this.controller,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
