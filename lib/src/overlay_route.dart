import 'package:flutter/material.dart';
import 'floating_config.dart';

class SimpleOverlayRoute<T> extends OverlayRoute<T> {
  final bool opaque;
  final bool maintainState;
  final BarrierConfig? barrier;
  final WidgetBuilder builder;
  final VoidCallback? onPop;

  SimpleOverlayRoute({
    this.barrier,
    super.settings,
    super.requestFocus,
    this.opaque = false,
    this.maintainState = false,
    required this.builder,
    this.onPop,
  });

  OverlayEntry? _barrierEntry;
  OverlayEntry? _overlayEntry;

  Widget _buildBarrierEntry(BuildContext context) {
    final config = barrier;
    assert(config != null);

    return ModalBarrier(
      color: config!.color,
      dismissible: config.dismissible,
      semanticsLabel: config.label,
      barrierSemanticsDismissible: config.dismissible,
    );
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    if (barrier != null) {
      _barrierEntry = OverlayEntry(builder: _buildBarrierEntry);
    }

    _overlayEntry = OverlayEntry(
      opaque: opaque,
      maintainState: maintainState,
      builder: (context) => builder(context),
    );

    if (_barrierEntry != null) {
      return [_barrierEntry!, _overlayEntry!];
    }

    return [_overlayEntry!];
  }

  @override
  bool didPop(T? result) {
    final popped = super.didPop(result);

    if (popped) {
      onPop?.call();
    }

    return popped;
  }

  void markNeedsBuild() {
    _barrierEntry?.markNeedsBuild();
    _overlayEntry?.markNeedsBuild();
  }
}

class SimpleTransitionRoute<T> extends TransitionRoute<T> {
  final Duration _transitionDuration;
  final Duration _reverseTransitionDuration;
  final bool _allowSnapshotting;
  final bool _opaque;
  final bool _maintainState;
  final RoutePageBuilder builder;
  final RouteTransitionsBuilder? transitionBuilder;

  final BarrierConfig? barrier;

  final _pageKey = GlobalKey();

  SimpleTransitionRoute({
    Duration transitionDuration = const Duration(milliseconds: 200),
    Duration? reverseTransitionDuration,
    bool allowSnapshotting = true,
    bool opaque = false,
    bool maintainState = false,
    this.barrier,
    super.settings,
    super.requestFocus,
    this.transitionBuilder,
    required this.builder,
  }) : _transitionDuration = transitionDuration,
       _reverseTransitionDuration =
           reverseTransitionDuration ?? transitionDuration,
       _allowSnapshotting = allowSnapshotting,
       _opaque = opaque,
       _maintainState = maintainState;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;

  @override
  bool get opaque => _opaque;

  @override
  bool get allowSnapshotting => _allowSnapshotting;

  @override
  bool get popGestureEnabled => false;

  Widget? _page;

  Widget _buildPageEntry(BuildContext context) {
    _page ??= RepaintBoundary(
      key: _pageKey,
      child: Builder(
        builder: (ctx) => builder(ctx, animation!, secondaryAnimation!),
      ),
    );

    final Widget transitioned =
        transitionBuilder?.call(
          context,
          animation!,
          secondaryAnimation!,
          _page!,
        ) ??
        FadeTransition(opacity: animation!, child: _page!);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: RepaintBoundary(
        child: transitioned,
      ),
    );
  }

  Widget _buildBarrierEntry(BuildContext context) {
    final config = barrier;
    assert(config != null);

    final color = config!.color;

    final Widget barrierWidget = (color != null && config.curve != null)
        ? AnimatedModalBarrier(
            color: animation!.drive(
              ColorTween(begin: color.withOpacity(0.0), end: color).chain(
                CurveTween(curve: config.curve!),
              ),
            ),
            dismissible: config.dismissible,
            semanticsLabel: config.label,
            barrierSemanticsDismissible: config.dismissible,
          )
        : ModalBarrier(
            color: color,
            dismissible: config.dismissible,
            semanticsLabel: config.label,
            barrierSemanticsDismissible: config.dismissible,
          );

    return IgnorePointer(
      ignoring: !animation!.isForwardOrCompleted,
      child: barrierWidget,
    );
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    if (barrier != null) {
      _barrierEntry = OverlayEntry(builder: _buildBarrierEntry);
    }

    _overlayEntry = OverlayEntry(
      opaque: _opaque,
      maintainState: _maintainState,
      builder: _buildPageEntry,
    );

    return [?_barrierEntry, _overlayEntry!];
  }

  OverlayEntry? _barrierEntry;
  OverlayEntry? _overlayEntry;

  void markNeedsBuild() {
    if (barrier != null) {
      _barrierEntry?.markNeedsBuild();
    }

    _overlayEntry?.markNeedsBuild();
  }
}
