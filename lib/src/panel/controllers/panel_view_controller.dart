import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/model/panel_view_state.dart';
import 'package:simple_overlay_kit/src/panel/model/resize_direction.dart';

abstract interface class PanelViewController extends ValueListenable<PanelViewState> {
  void minimize();
  void maximize();
  void restore();

  void move(double dx, double dy);
  void resize(Offset delta, ResizeDirection direction);

  set title(String? newTitle);

  void bringToFront();

  void close();

  set constraints(PanelConstraints constraints);

  factory PanelViewController(
    Object panelId, {
    required PanelViewDelegate delegate,
    required PanelViewState initialState,
    required PanelConstraints initialConstraints,
  }) = _ViewControllerImpl;
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

  PanelConstraints _constraints;

  PanelViewState _state;

  _ViewControllerImpl(
    this.panelId, {
    required this.delegate,
    required PanelViewState initialState,
    required PanelConstraints initialConstraints,
  })  : _state = initialState,
        _constraints = initialConstraints;

  @override
  PanelViewState get value => _state;

  @override
  set constraints(PanelConstraints constraints) {
    if (_constraints == constraints) return;
    _constraints = constraints;

    final geometry = _constraints.constrain(_state.geometry);

    if (geometry != _state.geometry) {
      _state = _state.copyWith(geometry: geometry);
      notifyListeners();
    }
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
    _update(title: newTitle);
  }

  PanelGeometry? _restorableGeometry;

  @override
  void maximize() {
    _restorableGeometry = _state.geometry;

    final updated = _update(
      mode: PanelViewMode.maximized,
      geometry: _constraints.maximumGeometry,
    );

    if (updated) {
      delegate.onPanelMaximize(panelId);
    } else {
      _restorableGeometry = null;
    }
  }

  @override
  void minimize() {
    _restorableGeometry = _state.geometry;
    final updated = _update(mode: PanelViewMode.minimized);

    if (updated) {
      delegate.onPanelMinimize(panelId);
    } else {
      _restorableGeometry = null;
    }
  }

  @override
  void restore() {
    final updated = _update(
      mode: PanelViewMode.normal,
      geometry: _restorableGeometry,
    );

    _restorableGeometry = null;

    if (updated) {
      delegate.onPanelRestore(panelId);
    }
  }

  @override
  void move(double dx, double dy) {
    _update(
      geometry: _state.geometry.move(dx, dy),
    );
  }

  @override
  void resize(Offset delta, ResizeDirection direction) {
    _update(
      geometry: _state.geometry.resize(delta, direction),
    );
  }

  bool _update({
    String? title,
    PanelViewMode? mode,
    PanelGeometry? geometry,
  }) {
    final newState = _state.copyWith(
      title: title,
      mode: mode,
      geometry: geometry != null ? _constraints.constrain(geometry) : null,
    );

    if (_state != newState) {
      _state = newState;
      notifyListeners();
      return true;
    }

    return false;
  }
}
