import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/model/panel.dart';
import 'package:simple_overlay_kit/src/panel/model/resize_direction.dart';

abstract interface class PanelViewController extends ValueListenable<PanelSettings> {
  void minimize();
  void maximize();
  void restore();

  void move(double dx, double dy);
  void resize(Offset delta, ResizeDirection direction);

  set title(String? newTitle);

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
    Object panelId, {
    required PanelSettings initialSettings,
    required PanelViewDelegate delegate,
    PanelBounds? initialBounds,
  }) {
    return _ViewControllerImpl(
      panelId,
      delegate: delegate,
      initialSettings: initialSettings,
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

// TODO: constrain PanelGeometry inside PanelBounds
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
    if (_bounds == bounds) return;
    _bounds = bounds;
  }

  @override
  void bringToFront() {
    delegate.onPanelFocused(panelId);
  }

  @override
  void close() {
    delegate.onPanelClosed(panelId);
  }

  @override
  set title(String? newTitle) {
    if (newTitle != _settings.title) {
      _settings = _settings.copyWith(title: newTitle);
      notifyListeners();
    }
  }

  PanelGeometry? _restorableGeometry;

  @override
  void maximize() {
    _restorableGeometry = _settings.geometry;

    _settings = PanelSettings(
      title: _settings.title,
      geometry: _bounds?.maximumGeometry ?? _settings.geometry,
      mode: PanelViewMode.maximized,
    );

    delegate.onPanelMaximize(panelId);
    notifyListeners();
  }

  @override
  void minimize() {
    _restorableGeometry = _settings.geometry;
    _settings = _settings.copyWith(mode: PanelViewMode.minimized);
    delegate.onPanelMinimize(panelId);
    notifyListeners();
  }

  @override
  void restore() {
    if (_restorableGeometry != null) {
      _settings = _settings.copyWith(geometry: _restorableGeometry);
      _restorableGeometry = null;
    }

    _settings = _settings.copyWith(mode: PanelViewMode.normal);

    notifyListeners();

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
  void resize(Offset delta, ResizeDirection direction) {
    final newGeometry = _settings.geometry.resize(delta, direction);
    final newSettings = _settings.copyWith(geometry: newGeometry);

    if (_settings != newSettings) {
      _settings = newSettings;
      notifyListeners();
    }
  }
}
