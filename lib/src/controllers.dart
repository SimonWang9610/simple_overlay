import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'routes/overlay_route.dart';
import 'routes/floating_config.dart';

/// Listenable controller for showing and hiding an [OverlayEntry]/[OverlayRoute]/[TransitionRoute]
/// Subclasses of this class should implement the logic for showing and hiding the overlay.
///
/// To ensure its status is consistent with the actual overlay,
/// the controller only exposes as [ValueListenable] instead of [ValueNotifier].
///
/// It can only show an given [FloatingConfig] once, and will be disposed after hiding the overlay.
///
/// See also:
/// - [_OverlayEntryController]: the controller for showing and hiding [OverlayEntry].
/// - [_OverlayRouteController]: the controller for showing and hiding [OverlayRoute].
/// - [_TransitionRouteController]: the controller for showing and hiding [TransitionRoute].
abstract base class FloatingController extends ChangeNotifier
    implements ValueListenable<bool> {
  FloatingController();

  /// When showing [TransitionRoute], the showing status will be set to true immediately,
  /// await [show] will complete when the route's transition animation is completed.
  ///
  /// For [OverlayRoute]/[TransitionRoute], popping the route by user action or system back button
  /// will set the showing status to false automatically.
  FutureOr<void> show(BuildContext context);

  FutureOr<void> hide();

  @override
  bool get value => _value;

  bool _value = false;

  set _showing(bool value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }

  factory FloatingController.withConfig(FloatingConfig config) {
    return switch (config) {
      RawOverlayConfig raw => _OverlayEntryController(raw),
      OverlayRouteConfig route => _OverlayRouteController(route),
      TransitionRouteConfig transition => _TransitionRouteController(
        transition,
      ),
    };
  }
}

final class _OverlayEntryController extends FloatingController {
  final RawOverlayConfig config;

  _OverlayEntryController(this.config);

  OverlayEntry? _entry;

  @override
  void show(BuildContext context) {
    if (value) return;

    final overlay = Overlay.of(context, rootOverlay: config.rootOverlay);

    _entry ??= OverlayEntry(
      builder: config.builder,
      opaque: config.opaque,
      maintainState: config.maintainState,
    );

    overlay.insert(_entry!);

    _entry!.addListener(_onOverlayEntryChanged);

    _showing = true;
  }

  @override
  void hide() {
    _entry?.removeListener(_onOverlayEntryChanged);
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
    _showing = false;
  }

  void _onOverlayEntryChanged() {
    if (_entry == null) return;

    if (_entry!.mounted) {
      _showing = true;
    } else {
      hide();
    }
  }

  @override
  void dispose() {
    hide();
    super.dispose();
  }
}

final class _OverlayRouteController extends FloatingController {
  final OverlayRouteConfig config;

  _OverlayRouteController(this.config);

  OverlayRoute? _route;

  @override
  void show(BuildContext context) {
    if (value) return;

    _route ??= SimpleOverlayRoute(
      opaque: config.opaque,
      maintainState: config.maintainState,
      builder: config.builder,
    );

    final navigator = Navigator.of(context, rootNavigator: config.rootOverlay);

    /// When the route is popped by user action or system back button,
    /// the showing status will be set to false automatically.
    // ignore: unawaited_futures
    navigator.push(_route!).whenComplete(
      () {
        _route = null;
        _showing = false;
      },
    );

    _showing = true;
  }

  @override
  void hide() {
    _remove();
    _showing = false;
  }

  void _remove() {
    if (_route != null && _route!.isActive) {
      _route!.navigator?.removeRoute(_route!);
    }
    _route = null;
  }

  @override
  void dispose() {
    _remove();
    super.dispose();
  }
}

final class _TransitionRouteController extends FloatingController {
  final TransitionRouteConfig config;

  _TransitionRouteController(this.config);

  @override
  bool get value => _value && config.route.isActive;

  bool _isDisposed = false;

  @override
  Future<void> show(BuildContext context) async {
    if (value) return;

    final navigator = Navigator.of(
      context,
      rootNavigator: config.useRootNavigator,
    );

    /// When the route is popped by user action or system back button,
    /// the showing status will be set to false automatically.
    // ignore: unawaited_futures
    navigator.push(config.route).whenComplete(() {
      _showing = false;
    });

    final completer = Completer<void>();

    void complete(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        config.route.animation?.removeStatusListener(complete);
      }
    }

    if (config.route.animation != null) {
      config.route.animation!.addStatusListener(complete);
    } else {
      completer.complete();
    }

    _showing = true;

    return completer.future;
  }

  @override
  Future<void> hide() async {
    if (config.route.isActive) {
      config.route.navigator?.removeRoute(config.route);
      await config.route.completed;
    }

    _showing = false;
  }

  @override
  void dispose() {
    hide();
    _isDisposed = true;
    super.dispose();
  }

  @override
  set _showing(bool value) {
    if (_isDisposed) return;
    super._showing = value;
  }
}
