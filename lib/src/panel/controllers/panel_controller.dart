import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/controllers/panel_shower.dart';
import 'package:simple_overlay_kit/src/panel/controllers/z_index_manager.dart';

abstract base class PanelController extends ChangeNotifier {
  /// Whether this controller uses an overlay to display panels.
  /// If false, the panels are expected to be displayed in a [Route] above the current context.
  /// If true, the controller will ensure that panels are displayed in an [Overlay] above the current context,
  /// which will ensure panels are not overridden by other routes.
  ///
  /// Default to false.
  final bool useOverlay;

  PanelConstraints get constraints;
  set constraints(PanelConstraints newConstraints);

  void open(Panel panel);
  void close(Object panelId);
  void closeAll();
  void bringToFront(Object panelId);

  /// Checks if the panel with the given id is currently visible (i.e., not minimized).
  bool isVisible(Object panelId);

  PanelMode get mode;
  set mode(PanelMode newMode);

  /// Returns the id of the currently focused panel, or null if no panel is focused.
  Object? get focusedPanel;

  /// Returns panels in z-order (from back to front).
  Iterable<PanelViewEntry> get orderedPanels;

  /// Returns panels in the order they were added, regardless of z-order.
  Iterable<PanelViewEntry> get panels;

  /// Whether there is at least one panel currently open.
  bool get hasPanels;

  PanelController._(this.useOverlay);

  factory PanelController(
    BuildContext context, {
    PanelConstraints? initialConstraints,
    PanelMode initialMode,
    bool useOverlay,
  }) = _PanelControllerImpl;
}

final class _PanelControllerImpl extends PanelController with _PanelViewDelegateImpl, _PanelModeNotifier {
  _PanelControllerImpl(
    this.context, {
    PanelConstraints? initialConstraints,
    PanelMode initialMode = PanelMode.window,
    bool useOverlay = false,
  }) : super._(useOverlay) {
    _mode = initialMode;

    if (initialConstraints != null) {
      _constraints = initialConstraints;
    } else {
      final screenSize = MediaQuery.sizeOf(context);
      _constraints = PanelConstraints.scale(screenSize);
    }
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

  late PanelConstraints _constraints;

  @override
  PanelConstraints get constraints => _constraints;

  @override
  set constraints(PanelConstraints newConstraints) {
    _constraints = newConstraints;
    for (final panel in _panels.values) {
      panel.controller.constraints = newConstraints;
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
  Iterable<PanelViewEntry> get orderedPanels {
    return _zIndices.ordered.map((id) => _panels[id]!);
  }

  @override
  Iterable<PanelViewEntry> get panels {
    return _panels.values;
  }

  @override
  void open(Panel panel) {
    assert(
      !_panels.containsKey(panel.id),
      'A panel with id "${panel.id}" is already registered.',
    );

    final state = panel.getInitialState(
      _findCandidatePosition(),
      "Untitled-${_panels.length}",
    );

    _panels[panel.id] = PanelViewEntry(
      id: panel.id,
      controller: PanelViewController(
        panel.id,
        delegate: this,
        initialState: state,
        initialConstraints: _constraints,
      ),
      builder: panel.builder,
    );

    if (state.mode != PanelViewMode.minimized) {
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
    Offset candidate = _constraints.topleft + const Offset(20, 20);

    final ordered = _panels.values.toList()
      ..sort(
        (a, b) {
          return a.controller.value.geometry.origin.compareTo(b.controller.value.geometry.origin);
        },
      );

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
