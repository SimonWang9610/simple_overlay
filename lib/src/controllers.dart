import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'overlay_route.dart';
import 'floating_config.dart';

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
abstract base class FloatingController extends ChangeNotifier implements ValueListenable<bool> {
  final VoidCallback? onAutoHide;

  FloatingController({
    this.onAutoHide,
  });

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

  bool _isDisposed = false;

  set _showing(bool value) {
    if (_isDisposed) return;
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  factory FloatingController.withConfig(FloatingConfig config, {VoidCallback? onAutoHide}) {
    return switch (config) {
      final RawOverlayConfig raw => _OverlayEntryController(raw, onAutoHide: onAutoHide),
      final OverlayRouteConfig route => _OverlayRouteController(route, onAutoHide: onAutoHide),
      final TransitionRouteConfig transition => _TransitionRouteController(
          transition,
          onAutoHide: onAutoHide,
        ),
    };
  }

  /// Factory constructor for creating a [RawDialogRoute] with custom transition.
  factory FloatingController.dialog({
    BarrierConfig barrierConfig = const BarrierConfig(),
    bool useRootNavigator = false,
    Offset? anchorPoint,
    RouteTransitionsBuilder? transitionBuilder,
    VoidCallback? onAutoHide,
    required RoutePageBuilder builder,
  }) {
    final config = DialogRouteConfig(
      barrierConfig: barrierConfig,
      useRootNavigator: useRootNavigator,
      anchorPoint: anchorPoint,
      transitionBuilder: transitionBuilder,
      builder: builder,
    );

    return _TransitionRouteController(config, onAutoHide: onAutoHide);
  }

  /// Factory constructor for creating a [SimpleTransitionRoute] with custom transition.
  factory FloatingController.transition({
    bool useRootNavigator = false,
    BarrierConfig? barrierConfig,
    Duration transitionDuration = const Duration(milliseconds: 200),
    Duration? reverseTransitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
    VoidCallback? onAutoHide,
    required RoutePageBuilder builder,
  }) {
    final config = SimpleTransitionRouteConfig(
      useRootNavigator: useRootNavigator,
      barrierConfig: barrierConfig,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionBuilder: transitionBuilder,
      builder: builder,
    );

    return _TransitionRouteController(config, onAutoHide: onAutoHide);
  }

  /// Factory constructor for creating an overlay.
  ///
  /// if [useRoute] is true, it will create a [SimpleOverlayRoute] and push it to the navigator,
  /// [transitionDuration], [reverseTransitionDuration] and [transitionBuilder] will be ignored in this case.
  ///
  /// if [useRoute] is false, it will create an [OverlayEntry] and insert it to the overlay,
  /// [transitionDuration], [reverseTransitionDuration] and [transitionBuilder] will be used for the transition
  /// of the overlay entry.
  ///
  /// [barrierConfig] will only be used when [useRoute] is true, and will be ignored when [useRoute] is false.
  factory FloatingController.overlay({
    bool rootOverlay = false,
    bool opaque = false,
    bool maintainState = false,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration? reverseTransitionDuration,
    bool useRoute = false,
    BarrierConfig? barrierConfig,
    OverlayTransitionBuilder? transitionBuilder,
    VoidCallback? onAutoHide,
    required WidgetBuilder builder,
  }) {
    if (useRoute) {
      final config = OverlayRouteConfig(
        rootOverlay: rootOverlay,
        opaque: opaque,
        maintainState: maintainState,
        barrierConfig: barrierConfig,
        builder: builder,
      );

      return _OverlayRouteController(config, onAutoHide: onAutoHide);
    }

    final config = RawOverlayConfig(
      rootOverlay: rootOverlay,
      opaque: opaque,
      maintainState: maintainState,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionBuilder: transitionBuilder,
      builder: builder,
    );

    return _OverlayEntryController(config, onAutoHide: onAutoHide);
  }
}

final class _OverlayEntryController extends FloatingController {
  final RawOverlayConfig config;

  _OverlayEntryController(this.config, {super.onAutoHide});

  OverlayEntry? _entry;
  AnimationController? _animation;

  @override
  Future<void> show(BuildContext context) async {
    if (value) return;

    if (config.transitionBuilder != null) {
      final navigator = Navigator.of(context, rootNavigator: config.rootOverlay);

      _animation ??= AnimationController(
        duration: config.transitionDuration,
        reverseDuration: config.reverseTransitionDuration,
        debugLabel: 'Raw overlay Animation',
        vsync: navigator,
      );
    }

    final overlay = Overlay.of(context, rootOverlay: config.rootOverlay);

    _entry ??= OverlayEntry(
      builder: (ctx) {
        Widget child = config.builder(ctx);

        if (config.transitionBuilder != null) {
          child = config.transitionBuilder!(
            ctx,
            _animation!,
            child,
          );
        }

        return child;
      },
      opaque: config.opaque,
      maintainState: config.maintainState,
    );

    overlay.insert(_entry!);

    _entry!.addListener(_onOverlayEntryChanged);

    _showing = true;

    await _animation?.forward();
  }

  @override
  Future<void> hide() async {
    await _animation?.reverse();

    _hide();
  }

  void _hide() {
    _entry?.removeListener(_onOverlayEntryChanged);
    _entry?.remove();
    _entry?.dispose();
    _animation?.dispose();
    _animation = null;
    _entry = null;
    _showing = false;
  }

  void _onOverlayEntryChanged() {
    if (_entry == null) return;

    if (_entry!.mounted) {
      _showing = true;
    } else {
      _hide();
      onAutoHide?.call();
    }
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }
}

final class _OverlayRouteController extends FloatingController {
  final OverlayRouteConfig config;

  _OverlayRouteController(this.config, {super.onAutoHide});

  OverlayRoute? _route;

  @override
  bool get value => _value && _route != null;

  @override
  void show(BuildContext context) {
    if (value) return;
    assert(_route == null, 'Route is already showing');

    _route = SimpleOverlayRoute(
      opaque: config.opaque,
      maintainState: config.maintainState,
      builder: config.builder,
      barrier: config.barrierConfig,
    );

    final navigator = Navigator.of(context, rootNavigator: config.rootOverlay);

    /// When the route is popped by user action or system back button,
    /// the showing status will be set to false automatically.
    // ignore: unawaited_futures
    navigator.push(_route!).whenComplete(
      () {
        _route = null;
        _showing = false;
        onAutoHide?.call();
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
    hide();
    _isDisposed = true;
    super.dispose();
  }
}

final class _TransitionRouteController extends FloatingController {
  final TransitionRouteConfig config;

  _TransitionRouteController(this.config, {super.onAutoHide});

  @override
  bool get value => _value && _route != null;

  TransitionRoute? _route;

  @override
  Future<void> show(BuildContext context) async {
    if (value) return;
    assert(_route == null, 'Route is already showing');

    ///! Must create a new route from the config,
    ///! as a route can not be reused after it is pushed and popped.
    _route = config.route;

    final navigator = Navigator.of(
      context,
      rootNavigator: config.useRootNavigator,
    );

    /// When the route is popped by user action or system back button,
    /// the showing status will be set to false automatically.
    // ignore: unawaited_futures
    navigator.push(_route!).whenComplete(() {
      _route = null;
      _showing = false;
      onAutoHide?.call();
    });

    final completer = Completer<void>();

    void complete(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        _route?.animation?.removeStatusListener(complete);
      }
    }

    if (_route?.animation != null) {
      _route!.animation!.addStatusListener(complete);
    } else {
      completer.complete();
    }

    _showing = true;

    return completer.future;
  }

  @override
  Future<void> hide() async {
    final route = _route;
    _route = null;
    _showing = false;

    if (route?.isActive ?? false) {
      route?.navigator?.removeRoute(route);

      /// when [TransitionRoute.dispose] is called, the route will be removed from navigator
      /// and its animation will be disposed immediately,
      ///
      /// [Route.popped] typically happens before [Route.dispose],
      /// and the route's animation will be disposed in [Route.dispose].
      await route?.completed;
    }
  }

  @override
  void dispose() {
    hide();
    _isDisposed = true;
    super.dispose();
  }
}
