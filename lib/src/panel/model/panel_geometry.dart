import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/model/resize_direction.dart';

/// Represents the geometry of a panel, including its position and size.
class PanelGeometry extends Equatable {
  final Offset origin;
  final Size size;

  const PanelGeometry({
    required this.origin,
    required this.size,
  });

  PanelGeometry copyWith({
    Offset? origin,
    Size? size,
  }) {
    return PanelGeometry(
      origin: origin ?? this.origin,
      size: size ?? this.size,
    );
  }

  Rect get rect => origin & size;

  PanelGeometry move(double dx, double dy) {
    return copyWith(
      origin: origin + Offset(dx, dy),
    );
  }

  PanelGeometry resize(Offset delta, ResizeDirection direction) {
    double newX = origin.dx;
    double newY = origin.dy;

    if (direction.isLeftEdge) {
      newX += delta.dx;
    }

    if (direction.isTopEdge) {
      newY += delta.dy;
    }

    final widthDelta = (direction.isRightEdge ? delta.dx : 0.0) - (direction.isLeftEdge ? delta.dx : 0.0);
    final heightDelta = (direction.isBottomEdge ? delta.dy : 0.0) - (direction.isTopEdge ? delta.dy : 0.0);

    final newSize = Size(
      size.width + widthDelta,
      size.height + heightDelta,
    );

    return PanelGeometry(origin: Offset(newX, newY), size: newSize);
  }

  @override
  List<Object?> get props => [origin, size];
}

/// Represents the constraints for a panel, including minimum and maximum sizes,
/// screen size, and edge visibility threshold.
///
/// The [edgeVisibleThreshold] defines how much of the panel must remain visible
/// when it is moved outside the screen bounds.
/// This ensures that users can still interact with the panel.
class PanelConstraints extends Equatable {
  final Size minSize;
  final Size maxSize;
  final Offset origin;
  final double edgeVisibleThreshold;

  const PanelConstraints({
    required this.minSize,
    required this.maxSize,
    this.origin = Offset.zero,
    this.edgeVisibleThreshold = 20,
  })  : assert(maxSize > minSize, 'maxSize must be greater than or equal to minSize'),
        assert(edgeVisibleThreshold >= 0, 'edgeVisibleThreshold must be non-negative'),
        assert(origin >= Offset.zero, 'origin must be non-negative');

  factory PanelConstraints.scale(
    Size screenSize, {
    double minSizeRatio = 0.2,
    double maxSizeRatio = 1.0,
    double edgeVisibleThreshold = 20,
  }) {
    assert(minSizeRatio >= 0 && minSizeRatio <= 1, 'minSizeRatio must be between 0 and 1');
    assert(maxSizeRatio >= 0 && maxSizeRatio <= 1, 'maxSizeRatio must be between 0 and 1');
    assert(minSizeRatio <= maxSizeRatio, 'minSizeRatio must be less than or equal to maxSizeRatio');
    assert(edgeVisibleThreshold >= 0, 'edgeVisibleThreshold must be non-negative');

    final minSize = screenSize * minSizeRatio;
    final maxSize = screenSize * maxSizeRatio;

    final origin = Offset(screenSize.width - maxSize.width, screenSize.height - maxSize.height) / 2;

    return PanelConstraints(
      minSize: minSize,
      maxSize: maxSize,
      origin: origin,
      edgeVisibleThreshold: edgeVisibleThreshold,
    );
  }

  factory PanelConstraints.fromPadding(
    Size screenSize, {
    required EdgeInsets padding,
    double edgeVisibleThreshold = 20,
    Size? minSize,
  }) {
    final origin = Offset(padding.left, padding.top);
    final maxSize = Size(
      screenSize.width - padding.left - padding.right,
      screenSize.height - padding.top - padding.bottom,
    );

    return PanelConstraints(
      minSize: minSize ?? Size.zero,
      maxSize: maxSize,
      origin: origin,
      edgeVisibleThreshold: edgeVisibleThreshold,
    );
  }

  @override
  List<Object?> get props => [minSize, maxSize, origin, edgeVisibleThreshold];

  Rect get rect => origin & maxSize;

  PanelGeometry get maximumGeometry {
    return PanelGeometry(
      origin: origin,
      size: maxSize,
    );
  }

  double constrainWidth(double width) {
    return width.clamp(minSize.width, maxSize.width);
  }

  double constrainHeight(double height) {
    return height.clamp(minSize.height, maxSize.height);
  }

  Size constrainSize(Size size) {
    return Size(
      constrainWidth(size.width),
      constrainHeight(size.height),
    );
  }

  PanelGeometry constrain(PanelGeometry geometry) {
    final constrainedSize = constrainSize(geometry.size);

    final constrainedGeometry = PanelGeometry(
      origin: geometry.origin,
      size: constrainedSize,
    );

    final constrainedRect = constrainedGeometry.rect;
    final screenRect = rect;

    final intersected = constrainedRect.intersect(screenRect.deflate(edgeVisibleThreshold));

    if (!intersected.isEmpty) {
      return constrainedGeometry;
    }

    double dx = constrainedGeometry.origin.dx;
    double dy = constrainedGeometry.origin.dy;

    if (constrainedRect.right - edgeVisibleThreshold < screenRect.left) {
      dx = screenRect.left + edgeVisibleThreshold - constrainedRect.width;
    } else if (constrainedRect.left + edgeVisibleThreshold > screenRect.right) {
      dx = screenRect.right - edgeVisibleThreshold;
    }

    if (constrainedRect.bottom - edgeVisibleThreshold < screenRect.top) {
      dy = screenRect.top + edgeVisibleThreshold - constrainedRect.height;
    } else if (constrainedRect.top + edgeVisibleThreshold > screenRect.bottom) {
      dy = screenRect.bottom - edgeVisibleThreshold;
    }

    return constrainedGeometry.copyWith(
      origin: Offset(dx, dy),
    );
  }
}
