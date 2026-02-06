import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:simple_overlay/src/animator.dart';

/// An overlay that can be aligned on the screen with the alignment animation.
class AlignmentOverlay extends DisposableOverlayWithAnimator<Alignment> {
  final OverlayAnimator<Alignment> _animator;
  final double scale;

  late Alignment _alignment;
  late Offset _screenCenter;

  @override
  OverlayAnimator<Alignment> get animator => _animator;

  AlignmentOverlay(AnimationController controller, {this.scale = 0.9})
    : _animator = OverlayAnimator<Alignment>(controller);

  /// show the overlay with alignment animation from [start] to [end].
  ///
  /// If only one of [start] or [end] is provided, or they are same,
  /// the animation will downgrade to an always stopped animation.
  Future<void> show(
    BuildContext context, {
    Alignment? start,
    Alignment? end,
    required AnimatedWidgetBuilder<Alignment> builder,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
  }) async {
    assert(
      start != null || end != null,
      'Either start or end alignment must be provided',
    );

    _screenCenter = MediaQuery.of(context).size.center(Offset.zero);
    _alignment = start ?? end ?? Alignment.center;

    await _animator.show(
      context,
      animation: _createAnimation(start: start, end: end, curve: curve),
      builder: builder,
      duration: duration,
    );
  }

  /// Move to the given position.
  ///
  /// the position is used to calculate the new alignment.
  ///
  /// Animation is disabled to avoid flickering.
  Future<bool> moveTo(Offset position) async {
    if (!isShowing) return false;

    double dx = (position.dx - _screenCenter.dx) / _screenCenter.dx;
    double dy = (position.dy - _screenCenter.dy) / _screenCenter.dy;

    dx = dx.abs() < 1 ? dx : dx / dx.abs();
    dy = dy.abs() < 1 ? dy : dy / dy.abs();

    final newAlign = Alignment(dx, dy);

    if (_alignment == newAlign) return false;

    _alignment = newAlign;

    await _animator.drive(
      /// purposely create an always stopped animation to avoid flickering
      animation: _createAnimation(start: _alignment, end: newAlign),
      duration: const Duration(milliseconds: 300),
      animating: false,
    );

    // ensure the alignment is synced
    _alignment = newAlign;

    return true;
  }

  /// Adjust alignment based on the given axis.
  ///
  /// It will align to the closest edge on the given axis.
  ///
  /// [Axis.horizontal]: align to left or right edge.
  ///
  /// [Axis.vertical]: align to top or bottom edge.
  Future<void> autoAlign(
    Axis axis, {
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    if (!isShowing) return;

    final newAlign = switch (axis) {
      Axis.horizontal => _adjustHorizontal(),
      Axis.vertical => _adjustVertical(),
    };

    if (_alignment == newAlign) return;

    await _animator.drive(
      animation: _createAnimation(start: _alignment, end: newAlign),
      duration: duration,
    );

    _alignment = newAlign;
  }

  Alignment _adjustHorizontal() {
    double dx = _alignment.x;

    if (dx != 0) {
      dx = dx / dx.abs() * scale;
    }

    return Alignment(dx, _alignment.y);
  }

  Alignment _adjustVertical() {
    double dy = _alignment.y;

    if (dy != 0) {
      dy = dy / dy.abs() * scale;
    }

    return Alignment(_alignment.x, dy);
  }

  Animation<Alignment> _createAnimation({
    Alignment? start,
    Alignment? end,
    Curve? curve,
  }) {
    assert(
      start != null || end != null,
      'Either start or end alignment must be provided',
    );

    final tween = AlignmentTween(
      begin: start ?? _alignment,
      end: end ?? _alignment,
    );

    if (tween.begin == tween.end) {
      return AlwaysStoppedAnimation<Alignment>(tween.end!);
    }

    return tween.animate(
      CurvedAnimation(parent: _animator.parent, curve: curve ?? Curves.linear),
    );
  }
}
