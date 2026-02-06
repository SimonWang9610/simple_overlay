import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:simple_overlay/src/overlay_manager.dart';

typedef AnimatedWidgetBuilder<T> =
    Widget Function(BuildContext context, Animation<T> animation);

abstract class DisposableOverlayWithAnimator<T> implements DisposableOverlay {
  OverlayAnimator<T> get animator;

  bool get isShowing => animator.isShowing;

  @override
  void hide() {
    animator.hide();
  }

  @override
  void dispose() {
    animator.dispose();
  }
}

class OverlayAnimator<T> implements DisposableOverlay {
  final SingleOverlayManager _overlay;
  final AnimationController _controller;

  OverlayAnimator(this._controller) : _overlay = SingleOverlayManager();

  Animation<double> get parent => _controller;
  bool get isShowing => _overlay.isShowing;

  /// The current animation being used,
  /// when the overlay is rebuilt, this animation will be used to drive the changes.
  Animation<T>? _currentAnimation;

  /// show the [builder] with the given [animation] on the topmost overlay.
  Future<void> show(
    BuildContext context, {
    required Animation<T> animation,
    required AnimatedWidgetBuilder<T> builder,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    if (_overlay.isShowing) return;

    /// init the current animation,
    /// as the overlay will use this animation to build the widget instantly before driving.
    _currentAnimation = animation;

    _overlay.show(context, builder: (ctx) => builder(ctx, _currentAnimation!));

    await drive(animation: animation, duration: duration);
  }

  @override
  void hide() {
    _overlay.hide();
  }

  /// Drive the showing overlay with the given [animation].
  ///
  /// if [animating] is true, it will animate to the end of the animation.
  ///
  /// If no overlay is showing or [animating] is false,
  /// it will just return the current value of the animation.
  FutureOr<T> drive({
    required Animation<T> animation,
    Duration? duration,
    bool animating = true,
  }) async {
    _currentAnimation = animation;

    if (!_overlay.hasOverlay) return _currentAnimation!.value;

    _controller.reset();

    if (duration != null) {
      _controller.duration = duration;
    }

    /// rebuild to apply the new animation
    _overlay.rebuild();

    if (animating) {
      /// force the animation direction to forward
      await _controller.animateTo(1.0);
    }

    return _currentAnimation!.value;
  }

  /// Animate the overlay forward from the given [from] value.
  /// returns the final value of the animation.
  FutureOr<T> forward({double? from}) async {
    await _controller.forward(from: from);
    return _currentAnimation!.value;
  }

  /// Animate the overlay reverse from the given [from] value.
  /// returns the final value of the animation.
  FutureOr<T> reverse({double? from}) async {
    await _controller.reverse(from: from);
    return _currentAnimation!.value;
  }

  @override
  void dispose() {
    hide();
    _controller.dispose();
  }
}
