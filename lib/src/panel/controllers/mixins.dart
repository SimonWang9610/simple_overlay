import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/controllers/panel_positioner.dart';

base mixin PanelViewDelegateImpl on PanelController implements PanelViewDelegate {
  @override
  void onPanelMinimize(Object panelId) {
    if (markPanelMinimized(panelId)) {
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

  bool markPanelMinimized(Object panelId);
}

base mixin PanelStateSetterMixin on PanelController {
  late PanelConstraints _constraints;

  @override
  PanelConstraints get constraints => _constraints;

  @override
  set constraints(PanelConstraints newConstraints) {
    _constraints = newConstraints;
    for (final panel in panels) {
      panel.controller.constraints = newConstraints;
    }
  }

  late PanelConfig _config = PanelConfig();

  @override
  PanelConfig get config => _config;

  @override
  set config(PanelConfig newConfig) {
    if (_config == newConfig) return;
    _config = newConfig;
    notifyListeners();
  }

  late PanelMode _mode;

  @override
  PanelMode get mode => _mode;

  @override
  set mode(PanelMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
  }

  void setup({
    required PanelConstraints constraints,
    required PanelMode mode,
    PanelPositioner? positioner,
    PanelConfig? config,
  }) {
    _constraints = constraints;
    _mode = mode;
    _config = config ?? PanelConfig();
    _positioner = positioner ?? PanelPositioner.cascade();
  }

  late PanelPositioner _positioner;

  PanelPositioner get positioner => _positioner;

  set positioner(PanelPositioner newPositioner) {
    _positioner = newPositioner;
  }
}
