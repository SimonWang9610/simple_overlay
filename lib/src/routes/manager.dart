import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay/src/routes/overlay_route.dart';
import 'package:simple_overlay/src/routes/overlay_config.dart';

abstract base class FloatingOverlayController extends ChangeNotifier
    implements ValueListenable<bool> {
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
}

final class RawOverlayController extends FloatingOverlayController {
  final RawOverlayConfig config;

  RawOverlayController(this.config);

  OverlayEntry? _entry;
  OverlayRoute? _route;

  @override
  FutureOr<void> show(BuildContext context) async {
    if (value) return;

    if (config.useRoute) {
      _route ??= SimpleOverlayRoute(
        config: config.entryConfig,
        builder: config.builder,
        onPop: () => _showing = false,
      );

      Navigator.of(context, rootNavigator: config.rootOverlay).push(_route!);
    } else {
      final overlay = Overlay.of(context, rootOverlay: config.rootOverlay);

      _entry ??= OverlayEntry(
        builder: config.builder,
        opaque: config.entryConfig.opaque,
        maintainState: config.entryConfig.maintainState,
        canSizeOverlay: config.entryConfig.canSizeOverlay,
      );

      overlay.insert(_entry!);
    }

    _showing = true;
  }

  @override
  FutureOr<void> hide() {
    _remove();
    _showing = false;
  }

  void _remove() {
    _entry?.remove();
    _entry?.dispose();

    if (_route != null && _route!.isActive) {
      _route!.navigator?.removeRoute(_route!);
    }

    _entry = null;
    _route = null;
  }

  @override
  void dispose() {
    _remove();
    super.dispose();
  }
}

final class TransitionOverlayController extends FloatingOverlayController {
  final RouteOverlayConfig config;

  TransitionOverlayController(this.config);

  @override
  bool get value => _value && config.route.isActive;

  bool _isDisposed = false;

  @override
  FutureOr<void> show(BuildContext context) async {
    if (value) return;

    final navigator = Navigator.of(
      context,
      rootNavigator: config.useRootNavigator,
    );

    navigator.push(config.route);

    config.route.completed.then((_) {
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
