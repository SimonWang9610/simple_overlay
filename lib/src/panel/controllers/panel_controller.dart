import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/controllers/mixins.dart';
import 'package:simple_overlay_kit/src/panel/controllers/panel_positioner.dart';
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

  PanelConfig get config;
  set config(PanelConfig newConfig);

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
  Iterable<PanelEntry> get orderedPanels;

  /// Returns panels in the order they were added, regardless of z-order.
  Iterable<PanelEntry> get panels;

  /// Whether there is at least one panel currently open.
  bool get hasPanels;

  PanelController._(this.useOverlay);

  factory PanelController(
    BuildContext context, {
    PanelConstraints? initialConstraints,
    PanelConfig? initialConfig,
    PanelPositioner? positioner,
    PanelMode initialMode,
    bool useOverlay,
  }) = _PanelControllerImpl;
}

final class _PanelControllerImpl extends PanelController with PanelViewDelegateImpl, PanelStateSetterMixin {
  _PanelControllerImpl(
    this.context, {
    PanelConstraints? initialConstraints,
    PanelConfig? initialConfig,
    PanelPositioner? positioner,
    PanelMode initialMode = PanelMode.window,
    bool useOverlay = false,
  }) : super._(useOverlay) {
    final PanelConstraints c;

    if (initialConstraints != null) {
      c = initialConstraints;
    } else {
      final screenSize = MediaQuery.sizeOf(context);
      c = PanelConstraints.scale(screenSize);
    }

    setup(
      constraints: c,
      mode: initialMode,
      config: initialConfig,
      positioner: positioner,
    );
  }

  final BuildContext context;
  final _zIndices = ZIndexManager();
  late final _shower = PanelShower(this);
  final Map<Object, PanelEntry> _panels = {};

  @override
  Object? get focusedPanel {
    final topmost = _zIndices.ordered.lastOrNull;
    assert(
      topmost == null || _panels.containsKey(topmost),
      'ZIndexManager contains an id that does not exist in panels.',
    );

    return topmost;
  }

  @override
  bool isVisible(Object panelId) {
    assert(_panels.containsKey(panelId), 'No panel with id "$panelId" is registered.');
    return _zIndices.hasValidIndex(panelId);
  }

  @override
  bool get hasPanels => _panels.isNotEmpty;

  @override
  Iterable<PanelEntry> get orderedPanels {
    return _zIndices.ordered.map((id) => _panels[id]!);
  }

  @override
  Iterable<PanelEntry> get panels {
    return _panels.values;
  }

  @override
  void open(Panel panel) {
    assert(
      !_panels.containsKey(panel.id),
      'A panel with id "${panel.id}" is already registered.',
    );

    final state = panel.getInitialState(
      positioner.find(
        panel,
        panels.map((e) => e.controller.value.geometry),
        constraints,
      ),
      "Untitled-${_panels.length}",
    );

    _panels[panel.id] = PanelEntry(
      id: panel.id,
      useBuiltInView: panel.useBuiltInView,
      addRepaintBoundary: panel.addRepaintBoundary,
      controller: PanelViewController(
        panel.id,
        delegate: this,
        initialState: state,
        initialConstraints: constraints,
      ),
      builder: panel.builder,
    );

    if (state.mode == PanelViewMode.minimized) {
      _zIndices.downgrade(panel.id);
    } else {
      _zIndices.upgrade(panel.id);
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
    removed.controller.dispose();

    notifyListeners();
  }

  @override
  void closeAll() {
    if (_panels.isEmpty) return;

    final panels = _panels.values.toList();
    _panels.clear();

    for (final p in panels) {
      p.controller.dispose();
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
  bool markPanelMinimized(Object panelId) {
    return _zIndices.downgrade(panelId);
  }
}
