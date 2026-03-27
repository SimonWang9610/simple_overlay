import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay/src/routes/overlay_route.dart';

sealed class OverlayConfig {
  const OverlayConfig();
}

final class RawOverlayConfig extends OverlayConfig {
  final bool rootOverlay;
  final OverlayEntryConfig entryConfig;
  final WidgetBuilder builder;
  final bool useRoute;

  const RawOverlayConfig({
    this.rootOverlay = false,
    this.entryConfig = const OverlayEntryConfig(),
    this.useRoute = true,
    required this.builder,
  });
}

final class RouteOverlayConfig extends OverlayConfig {
  final bool useRootNavigator;
  final TransitionRoute route;

  const RouteOverlayConfig({
    this.useRootNavigator = false,
    required this.route,
  });

  RouteOverlayConfig.dialog({
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

  RouteOverlayConfig.custom({
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
}
