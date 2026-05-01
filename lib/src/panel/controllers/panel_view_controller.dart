import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';
import 'package:simple_overlay_kit/src/panel/model/resize_direction.dart';

/// Controller for individual panel views, allowing manipulation of the panel's state and geometry.
///
/// Unlike [PanelController], which manages the collection of panels,
/// [PanelViewController] is focused on controlling a single panel's behavior and properties.
///
/// They can communicate via the [PanelViewDelegate] to notify about state changes or user interactions.
abstract interface class PanelViewController extends ValueListenable<PanelViewState> {
  void minimize();
  void maximize();
  void restore();

  void move(double dx, double dy);

  void resize(Offset delta, ResizeDirection direction);

  set title(String? newTitle);

  void bringToFront();

  void close();

  void dispose();

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

final class _ViewControllerImpl extends ChangeNotifier implements PanelViewController {
  final Object panelId;
  final PanelViewDelegate delegate;

  PanelConstraints _constraints;

  late PanelViewState _state;

  _ViewControllerImpl(
    this.panelId, {
    required this.delegate,
    required PanelViewState initialState,
    required PanelConstraints initialConstraints,
  }) : _constraints = initialConstraints {
    _state = initialState.copyWith(
      geometry: _constraints.constrain(initialState.geometry),
    );
  }

  @override
  PanelViewState get value => _state;

  @override
  set constraints(PanelConstraints constraints) {
    if (_constraints == constraints) return;
    _constraints = constraints;

    final geometry = _constraints.constrain(_state.geometry);
    _update(geometry: geometry);
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

  @override
  void dispose() {
    close();
    super.dispose();
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
