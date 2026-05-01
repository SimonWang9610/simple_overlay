part of '../floating_panel.dart';

class _PanelStack extends StatelessWidget {
  final PanelController controller;

  /// The currently focused panel. This panel will be shown with a highlighted border.
  final Object? focusedPanelId;

  /// Panels to show in this window, in z-order (from back to front).
  final Iterable<PanelViewEntry> panels;

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
