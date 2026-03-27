import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay/src/overlay_route.dart';

class BarrierConfig {
  final Color? color;
  final bool dismissible;
  final String? label;
  final Curve? curve;

  const BarrierConfig({
    this.color = const Color(0x7F000000),
    this.dismissible = true,
    this.label,
    this.curve,
  });
}

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

abstract base class TransitionRouteConfig extends FloatingConfig {
  final bool useRootNavigator;
  final BarrierConfig? barrierConfig;
  final Duration transitionDuration;
  final Duration? reverseTransitionDuration;
  final RouteTransitionsBuilder? transitionBuilder;
  final RoutePageBuilder builder;

  const TransitionRouteConfig({
    this.useRootNavigator = false,
    this.barrierConfig,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration,
    this.transitionBuilder,
    required this.builder,
  });

  TransitionRoute get route;
}

final class DialogRouteConfig extends TransitionRouteConfig {
  final Offset? anchorPoint;

  const DialogRouteConfig({
    super.useRootNavigator = false,
    super.barrierConfig = const BarrierConfig(),
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration,
    this.anchorPoint,
    super.transitionBuilder,
    required super.builder,
  });

  @override
  TransitionRoute get route => RawDialogRoute(
    pageBuilder: builder,
    barrierLabel: barrierConfig!.label,
    barrierDismissible: barrierConfig!.dismissible,
    barrierColor: barrierConfig!.color,
    transitionBuilder: transitionBuilder,
    anchorPoint: anchorPoint,
    transitionDuration: transitionDuration,
  );
}

final class SimpleTransitionRouteConfig extends TransitionRouteConfig {
  const SimpleTransitionRouteConfig({
    super.useRootNavigator = false,
    super.barrierConfig,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration,
    super.transitionBuilder,
    required super.builder,
  });

  @override
  TransitionRoute get route => SimpleTransitionRoute(
    barrier: barrierConfig,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    transitionBuilder: transitionBuilder,
    builder: builder,
  );
}
