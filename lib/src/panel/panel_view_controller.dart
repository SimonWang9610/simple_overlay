import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/model/panel.dart';

abstract interface class PanelViewController extends ValueListenable<PanelSettings> {
  void minimize();
  void maximize();
  void restore();

  void move(double dx, double dy);
  void resize(double width, double height);

  void bringToFront();

  void close();

  set bounds(PanelBounds? bounds);

  factory PanelViewController(
    Object panelId, {
    required PanelViewDelegate delegate,
    required PanelSettings initialSettings,
    PanelBounds? initialBounds,
  }) = _ViewControllerImpl;

  factory PanelViewController.fromPanel(
    Panel panel, {
    required PanelViewDelegate delegate,
    PanelBounds? initialBounds,
  }) {
    return _ViewControllerImpl(
      panel.id,
      delegate: delegate,
      initialSettings: panel.settings,
      initialBounds: initialBounds,
    );
  }
}

abstract interface class PanelViewDelegate {
  void onPanelMinimize(Object panelId);
  void onPanelMaximize(Object panelId);
  void onPanelRestore(Object panelId);
  void onPanelClosed(Object panelId);
  void onPanelFocused(Object panelId);
}

final class _ViewControllerImpl extends ChangeNotifier implements PanelViewController {
  final Object panelId;
  final PanelViewDelegate delegate;

  PanelBounds? _bounds;

  PanelSettings _settings;

  _ViewControllerImpl(
    this.panelId, {
    required this.delegate,
    required PanelSettings initialSettings,
    PanelBounds? initialBounds,
  })  : _settings = initialSettings,
        _bounds = initialBounds;

  @override
  PanelSettings get value => _settings;

  @override
  set bounds(PanelBounds? bounds) {
    _bounds = bounds;
    // todo: apply bounds constraints to current geometry and update if needed
  }

  @override
  void bringToFront() {
    delegate.onPanelFocused(panelId);
  }

  @override
  void close() {
    delegate.onPanelClosed(panelId);
  }

  PanelGeometry? _restorableGeometry;

  @override
  void maximize() {
    _restorableGeometry = _settings.geometry;
    _settings = PanelSettings(
      title: _settings.title,
      geometry: _settings.geometry.copyWith(
        origin: _settings.geometry.origin,
        size: _settings.geometry.size,
      ),
    );
    delegate.onPanelMaximize(panelId);
    notifyListeners();
  }

  @override
  void minimize() {
    _restorableGeometry = _settings.geometry;
    delegate.onPanelMinimize(panelId);
  }

  @override
  void restore() {
    if (_restorableGeometry != null) {
      _settings = _settings.copyWith(geometry: _restorableGeometry);
      _restorableGeometry = null;
      notifyListeners();
    }

    delegate.onPanelRestore(panelId);
  }

  @override
  void move(double dx, double dy) {
    final current = _settings.geometry.origin;
    final newOrigin = current + Offset(dx, dy);
    _settings = _settings.copyWith(
      geometry: _settings.geometry.copyWith(origin: newOrigin),
    );
    notifyListeners();
  }

  @override
  void resize(double width, double height) {
    final newSize = _settings.geometry.size + Offset(width, height);
    final newGeometry = _settings.geometry.copyWith(size: newSize);

    final newSettings = _settings.copyWith(
      geometry: _bounds != null ? _bounds!.clamp(newGeometry) : newGeometry,
    );

    if (newSettings.geometry != _settings.geometry) {
      _settings = newSettings;
      notifyListeners();
    }
  }
}
