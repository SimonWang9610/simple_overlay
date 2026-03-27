import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay/src/routes/overlay_route.dart';

sealed class FloatingConfig {
  const FloatingConfig();
}

final class RawOverlayConfig extends FloatingConfig {
  final bool rootOverlay;
  final bool opaque;
  final bool maintainState;
  final WidgetBuilder builder;

  const RawOverlayConfig({
    this.rootOverlay = false,
    this.opaque = false,
    this.maintainState = false,
    required this.builder,
  });

  OverlayRouteConfig get useRoute => OverlayRouteConfig(
    rootOverlay: rootOverlay,
    opaque: opaque,
    maintainState: maintainState,
    builder: builder,
  );

  @override
  int get hashCode => Object.hash(rootOverlay, opaque, maintainState, builder);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RawOverlayConfig &&
        other.rootOverlay == rootOverlay &&
        other.opaque == opaque &&
        other.maintainState == maintainState &&
        other.builder == builder;
  }
}

final class OverlayRouteConfig extends FloatingConfig {
  final bool rootOverlay;
  final bool opaque;
  final bool maintainState;
  final WidgetBuilder builder;

  const OverlayRouteConfig({
    this.rootOverlay = false,
    this.opaque = false,
    this.maintainState = false,
    required this.builder,
  });

  RawOverlayConfig get useRaw => RawOverlayConfig(
    rootOverlay: rootOverlay,
    opaque: opaque,
    maintainState: maintainState,
    builder: builder,
  );

  @override
  int get hashCode => Object.hash(rootOverlay, opaque, maintainState, builder);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RawOverlayConfig &&
        other.rootOverlay == rootOverlay &&
        other.opaque == opaque &&
        other.maintainState == maintainState &&
        other.builder == builder;
  }
}

final class TransitionRouteConfig extends FloatingConfig {
  final bool useRootNavigator;
  final TransitionRoute route;

  TransitionRouteConfig.dialog({
    BarrierConfig barrierConfig = const BarrierConfig(),
    this.useRootNavigator = false,
    Offset? anchorPoint,
    RouteTransitionsBuilder? transitionBuilder,
    required RoutePageBuilder builder,
  }) : route = RawDialogRoute(
         pageBuilder: builder,
         barrierLabel: barrierConfig.label,
         barrierDismissible: barrierConfig.dismissible,
         barrierColor: barrierConfig.color,
         transitionBuilder: transitionBuilder,
         anchorPoint: anchorPoint,
       );

  TransitionRouteConfig.custom({
    this.useRootNavigator = false,
    BarrierConfig? barrierConfig,
    Duration transitionDuration = const Duration(milliseconds: 200),
    Duration? reverseTransitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
    required RoutePageBuilder builder,
  }) : route = SimpleTransitionRoute(
         barrier: barrierConfig,
         transitionDuration: transitionDuration,
         reverseTransitionDuration: reverseTransitionDuration,
         transitionBuilder: transitionBuilder,
         builder: builder,
       );

  @override
  int get hashCode => Object.hash(useRootNavigator, route);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransitionRouteConfig &&
        other.useRootNavigator == useRootNavigator &&
        other.route == route;
  }
}
