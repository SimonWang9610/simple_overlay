import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/mixins/panel_shower.dart';
import 'package:simple_overlay_kit/src/panel/mixins/z_index_manager.dart';
import 'package:simple_overlay_kit/src/panel/model/panel.dart';

import 'panel_view_controller.dart';

abstract base class PanelController extends ChangeNotifier {
  PanelBounds? get bounds;
  set bounds(PanelBounds? newBounds);

  void open(Panel panel);
  void close(Object panelId);
  void closeAll();
  void bringToFront(Object panelId);

  bool isVisible(Object panelId);

  PanelMode get mode;
  set mode(PanelMode newMode);

  Object? get focusedPanel;

  List<PanelViewEntry> get panels;

  List<PanelViewEntry> get unorderedPanels;

  bool get hasPanels;

  PanelController._();

  factory PanelController(
    BuildContext context, {
    Panel? initialPanel,
    PanelBounds? initialBounds,
    PanelMode initialMode,
  }) = _PanelControllerImpl;
}

final class _PanelControllerImpl extends PanelController with _PanelViewDelegateImpl, _PanelModeNotifier {
  _PanelControllerImpl(
    this.context, {
    Panel? initialPanel,
    PanelBounds? initialBounds,
    PanelMode initialMode = PanelMode.window,
  }) : super._() {
    _mode = initialMode;
    _bounds = initialBounds;

    if (initialPanel != null) open(initialPanel);
  }

  final BuildContext context;
  final _zIndices = ZIndexManager();
  late final _shower = PanelShower(this);
  final Map<Object, PanelViewEntry> _panels = {};

  @override
  PanelMode get mode => _mode;

  @override
  Object? get focusedPanel {
    final topmost = _zIndices.ordered.lastOrNull;
    assert(
      topmost == null || _panels.containsKey(topmost),
      'ZIndexManager contains an id that does not exist in panels.',
    );

    return topmost;
  }

  PanelBounds? _bounds;

  @override
  PanelBounds? get bounds => _bounds;

  @override
  set bounds(PanelBounds? newBounds) {
    _bounds = newBounds;
    for (final panel in _panels.values) {
      panel.controller.bounds = newBounds;
    }
  }

  @override
  bool isVisible(Object panelId) {
    assert(_panels.containsKey(panelId), 'No panel with id "$panelId" is registered.');
    return _zIndices.hasValidIndex(panelId);
  }

  @override
  bool get hasPanels => _panels.isNotEmpty;

  @override
  List<PanelViewEntry> get panels {
    return List.unmodifiable(_zIndices.ordered.map((id) => _panels[id]!));
  }

  @override
  List<PanelViewEntry> get unorderedPanels {
    return List.unmodifiable(_panels.values);
  }

  @override
  void open(Panel panel) {
    assert(
      !_panels.containsKey(panel.id),
      'A panel with id "${panel.id}" is already registered.',
    );

    final settings = panel.getInitialSettings(_findCandidatePosition(), "Untitled-${_panels.length}");

    _panels[panel.id] = PanelViewEntry(
      id: panel.id,
      controller: PanelViewController.fromPanel(
        panel.id,
        delegate: this,
        initialSettings: settings,
        initialBounds: _bounds,
      ),
      builder: panel.builder,
    );

    if (settings.mode != PanelViewMode.minimized) {
      _zIndices.upgrade(panel.id);
    } else {
      _zIndices.downgrade(panel.id);
    }

    assert(
      context.mounted,
      'Given context is not mounted. Make sure to call PanelController.open() after the widget is built.',
    );

    _shower.ensurePanelOnstage(context, panel: panel);

    notifyListeners();
  }

  @override
  void close(Object panelId) {
    final removed = _panels.remove(panelId);

    if (removed == null) return;

    _zIndices.remove(panelId);
    removed.controller.close();

    notifyListeners();
  }

  @override
  void closeAll() {
    final panels = _panels.values.toList();
    _panels.clear();

    for (final p in panels) {
      close(p.id);
    }

    _zIndices.reset();

    notifyListeners();
  }

  @override
  void bringToFront(Object panelId) {
    if (!_panels.containsKey(panelId)) return;

    if (!_zIndices.atTop(panelId)) {
      _zIndices.upgrade(panelId);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    closeAll();
    _shower.dispose();
    super.dispose();
  }

  @override
  bool _markPanelMinimized(Object panelId) {
    return _zIndices.downgrade(panelId);
  }

  Offset _findCandidatePosition() {
    Offset candidate = _bounds?.topleft ?? Offset.zero;

    final ordered = _panels.values.toList()
      ..sort((a, b) {
        return a.controller.value.geometry.origin.compareTo(b.controller.value.geometry.origin);
      });

    for (final entry in ordered) {
      final geometry = entry.controller.value.geometry;
      final rect = geometry.rect.inflate(20);
      if (rect.contains(candidate)) {
        candidate += const Offset(20, 20);
      } else {
        break;
      }
    }

    return candidate;
  }
}

base mixin _PanelModeNotifier on PanelController {
  late PanelMode _mode;

  @override
  PanelMode get mode => _mode;

  @override
  set mode(PanelMode newMode) {
    if (_mode == newMode) return;
    print('mode changed: $_mode -> $newMode');
    _mode = newMode;
    notifyListeners();
  }
}

base mixin _PanelViewDelegateImpl on PanelController implements PanelViewDelegate {
  @override
  void onPanelMinimize(Object panelId) {
    if (_markPanelMinimized(panelId)) {
      notifyListeners();
    }
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

  bool _markPanelMinimized(Object panelId);
}

extension on Offset {
  int compareTo(Offset other) {
    final dy = this.dy.compareTo(other.dy);
    if (dy != 0) return dy;

    return dx.compareTo(other.dx);
  }
}
