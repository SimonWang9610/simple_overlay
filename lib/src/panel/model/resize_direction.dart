import 'package:flutter/widgets.dart';

enum ResizeDirection {
  left,
  right,
  up,
  down,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  bool get isLeftEdge =>
      this == ResizeDirection.left || this == ResizeDirection.topLeft || this == ResizeDirection.bottomLeft;

  bool get isRightEdge =>
      this == ResizeDirection.right || this == ResizeDirection.topRight || this == ResizeDirection.bottomRight;

  bool get isTopEdge =>
      this == ResizeDirection.up || this == ResizeDirection.topLeft || this == ResizeDirection.topRight;

  bool get isBottomEdge =>
      this == ResizeDirection.down || this == ResizeDirection.bottomLeft || this == ResizeDirection.bottomRight;

  bool get isHorizontal =>
      this == ResizeDirection.left ||
      this == ResizeDirection.right ||
      this == ResizeDirection.topLeft ||
      this == ResizeDirection.topRight ||
      this == ResizeDirection.bottomLeft ||
      this == ResizeDirection.bottomRight;

  bool get isVertical =>
      this == ResizeDirection.up ||
      this == ResizeDirection.down ||
      this == ResizeDirection.topLeft ||
      this == ResizeDirection.topRight ||
      this == ResizeDirection.bottomLeft ||
      this == ResizeDirection.bottomRight;

  ResizeDirection get opposite {
    return switch (this) {
      ResizeDirection.left => ResizeDirection.right,
      ResizeDirection.right => ResizeDirection.left,
      ResizeDirection.up => ResizeDirection.down,
      ResizeDirection.down => ResizeDirection.up,
      ResizeDirection.topLeft => ResizeDirection.bottomRight,
      ResizeDirection.topRight => ResizeDirection.bottomLeft,
      ResizeDirection.bottomLeft => ResizeDirection.topRight,
      ResizeDirection.bottomRight => ResizeDirection.topLeft,
    };
  }

  Rect buildEdgeRect(Size size, double edgeThreshold) {
    return switch (this) {
      ResizeDirection.left => Rect.fromLTWH(
          0,
          edgeThreshold,
          edgeThreshold,
          size.height - 2 * edgeThreshold,
        ),
      ResizeDirection.right => Rect.fromLTWH(
          size.width - edgeThreshold,
          edgeThreshold,
          edgeThreshold,
          size.height - 2 * edgeThreshold,
        ),
      ResizeDirection.up => Rect.fromLTWH(
          edgeThreshold,
          0,
          size.width - 2 * edgeThreshold,
          edgeThreshold,
        ),
      ResizeDirection.down => Rect.fromLTWH(
          edgeThreshold,
          size.height - edgeThreshold,
          size.width - 2 * edgeThreshold,
          edgeThreshold,
        ),
      ResizeDirection.topLeft => Rect.fromLTWH(
          0,
          0,
          edgeThreshold,
          edgeThreshold,
        ),
      ResizeDirection.topRight => Rect.fromLTWH(
          size.width - edgeThreshold,
          0,
          edgeThreshold,
          edgeThreshold,
        ),
      ResizeDirection.bottomLeft => Rect.fromLTWH(
          0,
          size.height - edgeThreshold,
          edgeThreshold,
          edgeThreshold,
        ),
      ResizeDirection.bottomRight => Rect.fromLTWH(
          size.width - edgeThreshold,
          size.height - edgeThreshold,
          edgeThreshold,
          edgeThreshold,
        ),
    };
  }
}
