part of '../floating_panel.dart';

class _PanelGrid extends StatelessWidget {
  final Object? focusedPanelId;
  final VoidCallback? onPanelTap;
  final Iterable<PanelViewEntry> panels;

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
