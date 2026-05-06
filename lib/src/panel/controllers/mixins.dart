import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/controllers/panel_shower.dart';

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
  PanelConstraints? _constraints;

  @override
  PanelConstraints get constraints => _constraints!;

  @override
  set constraints(PanelConstraints newConstraints) {
    if (_constraints == newConstraints) return;

    _constraints = newConstraints;

    for (final panel in panels) {
      panel.controller.constraints = newConstraints;
    }

    notifyListeners();
  }

  PanelConfig _config = PanelConfig();

  @override
  PanelConfig get config => _config;

  @override
  set config(PanelConfig newConfig) {
    if (_config == newConfig) return;
    _config = newConfig;
    notifyListeners();
  }

  PanelMode _mode = PanelMode.window;

  @override
  PanelMode get mode => _mode;

  @override
  set mode(PanelMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
  }

  void setup({
    PanelConstraints? constraints,
    PanelMode? mode,
    PanelPositioner? positioner,
    PanelSizer? sizer,
    PanelConfig? config,
  }) {
    if (constraints != null) {
      _constraints = constraints;
    }

    if (mode != null) {
      _mode = mode;
    }

    if (positioner != null) {
      _positioner = positioner;
    }

    if (config != null) {
      _config = config;
    }

    if (sizer != null) {
      _sizer = sizer;
    }
  }

  late PanelPositioner _positioner;

  PanelPositioner get positioner => _positioner;

  set positioner(PanelPositioner newPositioner) {
    _positioner = newPositioner;
  }

  late PanelSizer _sizer;

  PanelSizer get sizer => _sizer;

  set sizer(PanelSizer newSizer) {
    _sizer = newSizer;
  }
}

base mixin PanelShowerMixin on PanelController, PanelStateSetterMixin {
  late final PanelShower _shower = PanelShower(this);

  void ensureOnstage(BuildContext context, Panel panel) {
    _shower.ensurePanelOnstage(context, panel: panel);
  }

  void _setupConstraintsIfNeeded(BuildContext context) {
    if (_constraints != null) return;

    assert(
      context.mounted,
      'Initial constraints were not provided, and the context used to open the first panel is not mounted.',
    );

    final screenSize = MediaQuery.sizeOf(context);

    constraints = PanelConstraints.scale(screenSize);
  }

  @mustCallSuper
  @override
  void open(BuildContext context, Panel panel) {
    _setupConstraintsIfNeeded(context);
  }

  @override
  void dispose() {
    _shower.dispose();
    super.dispose();
  }
}
