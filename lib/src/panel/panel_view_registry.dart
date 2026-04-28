import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/model/panel.dart';

import 'panel_view_controller.dart';

abstract base class PanelRegistry extends ChangeNotifier {
  List<PanelViewEntry> get visiblePanels;
  List<PanelViewEntry> get minimizedPanels;

  PanelViewEntry? get focusedPanel => visiblePanels.isNotEmpty ? visiblePanels.last : null;

  set bounds(PanelBounds? newBounds);

  void open(Panel panel);
  void close(Object panelId);
  void bringToFront(Object panelId);

  PanelRegistry._();

  factory PanelRegistry(Panel? initialPanel, {PanelBounds? initialBounds}) = _PanelRegistryImpl;
}

final class _PanelRegistryImpl extends PanelRegistry implements PanelViewDelegate {
  _PanelRegistryImpl(Panel? initialPanel, {PanelBounds? initialBounds}) : super._() {
    if (initialPanel != null) open(initialPanel);
    _bounds = initialBounds;
  }

  final Map<Object, PanelViewEntry> _panels = {};
  final Map<Object, int> _panelZIndices = {};

  int _highestZIndex = 0;
  int _nextZIndex() => ++_highestZIndex;

  PanelBounds? _bounds;

  @override
  set bounds(PanelBounds? newBounds) {
    _bounds = newBounds;
    for (final panel in _panels.values) {
      panel.controller.bounds = newBounds;
    }
  }

  @override
  List<PanelViewEntry> get visiblePanels {
    final zIndices = _panelZIndices.keys.toList()
      ..sort(
        (a, b) => _panelZIndices[a]!.compareTo(_panelZIndices[b]!),
      );

    return zIndices.map((id) => _panels[id]!).toList();
  }

  @override
  List<PanelViewEntry> get minimizedPanels {
    final minimizedIds = _panels.keys
        .toSet()
        .difference(
          _panelZIndices.keys.toSet(),
        )
        .toList();

    return minimizedIds.map((id) => _panels[id]!).toList();
  }

  @override
  void open(Panel panel) {
    assert(
      !_panels.containsKey(panel.id),
      'A panel with id "${panel.id}" is already registered.',
    );

    _panels[panel.id] = PanelViewEntry(
      id: panel.id,
      controller: PanelViewController.fromPanel(
        panel,
        delegate: this,
        initialBounds: _bounds,
      ),
      settings: panel.settings,
      builder: panel.builder,
    );

    _panelZIndices[panel.id] = _nextZIndex();

    notifyListeners();
  }

  @override
  void close(Object panelId) {
    final removed = _panels.remove(panelId);

    if (removed == null) return;

    _panelZIndices.remove(panelId);
    removed.controller.close();
    notifyListeners();
  }

  @override
  void bringToFront(Object panelId) {
    if (!_panels.containsKey(panelId)) return;

    final zIndex = _panelZIndices[panelId];

    /// Already at the front, no change needed.
    if (zIndex == _highestZIndex) return;

    _panelZIndices[panelId] = _nextZIndex();
    notifyListeners();
  }

  @override
  void onPanelMinimize(Object panelId) {
    final removed = _panelZIndices.remove(panelId);
    if (removed != null) notifyListeners();
  }

  @override
  void onPanelClosed(Object panelId) {
    close(panelId);
  }

  @override
  void onPanelMaximize(Object panelId) {
    bringToFront(panelId);
  }

  @override
  void onPanelRestore(Object panelId) {
    bringToFront(panelId);
  }

  @override
  void onPanelFocused(Object panelId) {
    bringToFront(panelId);
  }

  @override
  void dispose() {
    final panels = _panels.values.toList();
    _panels.clear();
    _panelZIndices.clear();

    for (final p in panels) {
      close(p.id);
    }

    super.dispose();
  }
}
