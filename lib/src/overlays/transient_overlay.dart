import 'package:flutter/widgets.dart';
import 'package:simple_overlay/src/animator.dart';

/// A transient overlay that can be shown and hidden with an animation.
///
/// It could be used to show temporary messages or indicators that disappear after a short duration.
class TransientOverlay extends DisposableOverlayWithAnimator<double> {
  final OverlayAnimator<double> _animator;

  @override
  OverlayAnimator<double> get animator => _animator;

  TransientOverlay(AnimationController controller)
    : _animator = OverlayAnimator<double>(controller);

  /// show the overlay with the animation builder,
  ///
  /// if [autoHide] is true,
  /// it will hide itself after the animation is completed and the optional [displayDuration] is passed.
  Future<void> show(
    BuildContext context, {
    required AnimatedWidgetBuilder<double> builder,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
    Duration? displayDuration,
    bool autoHide = true,
  }) async {
    await _animator.show(
      context,
      animation: _animator.parent,
      builder: builder,
      duration: duration,
    );

    if (autoHide) {
      if (displayDuration != null) {
        await Future.delayed(displayDuration);
      }

      hide();
    }
  }
}
