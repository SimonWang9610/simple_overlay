import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';

/// A strategy for determining the initial position of a panel when it is opened.
abstract interface class PanelPositioner {
  Offset find(Panel panel, Iterable<PanelGeometry> others, PanelConstraints constraints);

  /// A positioner that always returns the origin specified in the constraints.
  factory PanelPositioner.origin() => const _AlwaysPanelOriginPositioner();

  /// A positioner that cascades panels diagonally with a specified offset, starting from the origin.
  /// If a candidate position overlaps with any existing panel (with a specified [margin]),
  /// the positioner will keep adding [step] until it finds a non-overlapping position.
  factory PanelPositioner.cascade({
    Offset step = const Offset(20, 20),
    double margin = 20,
  }) =>
      _OriginCascadePanelPositioner(offset: step, margin: margin);

  /// A positioner that positions the panel based on the specified alignments and offset.
  /// The [panelAlignment] specifies the point on the panel to align,
  /// and the [screenAlignment] specifies the point on the screen to align to.
  ///
  /// [offset] can be used to further adjust the position after alignment.
  ///
  /// The position calculation behaves similarly to [CompositedTransformFollower].
  factory PanelPositioner.follow({
    Offset offset = Offset.zero,
    Alignment panelAlignment = Alignment.topLeft,
    Alignment screenAlignment = Alignment.topLeft,
  }) =>
      _FollowPanelPositioner(
        offset: offset,
        panelAlignment: panelAlignment,
        screenAlignment: screenAlignment,
      );
}

final class _AlwaysPanelOriginPositioner implements PanelPositioner {
  const _AlwaysPanelOriginPositioner();

  @override
  Offset find(Panel panel, Iterable<PanelGeometry> others, PanelConstraints constraints) {
    return constraints.origin;
  }
}

final class _OriginCascadePanelPositioner implements PanelPositioner {
  final double margin;
  final Offset offset;

  const _OriginCascadePanelPositioner({
    this.offset = const Offset(20, 20),
    this.margin = 20,
  });

  @override
  Offset find(Panel panel, Iterable<PanelGeometry> others, PanelConstraints constraints) {
    if (others.isEmpty) {
      return constraints.origin;
    }

    Offset candidate = constraints.origin;

    final ordered = others.toList()..sort((a, b) => a.origin.compareTo(b.origin));

    for (final geometry in ordered) {
      final rect = geometry.rect.inflate(margin);
      if (rect.contains(candidate)) {
        candidate += offset;
      } else {
        break;
      }
    }
    return candidate;
  }
}

final class _FollowPanelPositioner implements PanelPositioner {
  final Offset offset;
  final Alignment panelAlignment;
  final Alignment screenAlignment;

  const _FollowPanelPositioner({
    this.offset = Offset.zero,
    this.panelAlignment = Alignment.topLeft,
    this.screenAlignment = Alignment.topLeft,
  });

  @override
  Offset find(Panel panel, Iterable<PanelGeometry> others, PanelConstraints constraints) {
    final panelAnchor = panelAlignment.alongSize(panel.initialSize);
    final screenAnchor = screenAlignment.alongSize(constraints.maxSize);

    return screenAnchor - panelAnchor + offset;
  }
}

extension on Offset {
  int compareTo(Offset other) {
    final dy = this.dy.compareTo(other.dy);
    if (dy != 0) return dy;

    return dx.compareTo(other.dx);
  }
}
