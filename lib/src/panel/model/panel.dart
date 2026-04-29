import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/model/resize_direction.dart';
import 'package:simple_overlay_kit/src/panel/panel_view_controller.dart';

typedef PanelWidgetBuilder = Widget Function(BuildContext context, PanelViewController controller);

class Panel {
  final Object id;
  final bool maintainState;
  final String? title;
  final Offset? initialPosition;
  final Size initialSize;
  final PanelViewMode? initialMode;
  final PanelWidgetBuilder builder;

  const Panel({
    required this.id,
    required this.builder,
    this.title,
    this.initialPosition,
    required this.initialSize,
    this.initialMode,
    this.maintainState = true,
  });

  PanelSettings getInitialSettings(Offset defaultOrigin) {
    return PanelSettings(
      title: title,
      mode: initialMode ?? PanelViewMode.normal,
      geometry: PanelGeometry(
        origin: initialPosition ?? defaultOrigin,
        size: initialSize,
      ),
    );
  }
}

class PanelViewEntry {
  final Object id;
  final PanelWidgetBuilder builder;
  final PanelViewController controller;

  const PanelViewEntry({
    required this.id,
    required this.builder,
    required this.controller,
  });
}

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

class PanelSettings extends Equatable {
  final String? title;
  final PanelViewMode mode;
  final PanelGeometry geometry;

  const PanelSettings({
    this.title,
    this.mode = PanelViewMode.normal,
    required this.geometry,
  });

  PanelSettings copyWith({
    String? title,
    PanelGeometry? geometry,
    PanelViewMode? mode,
  }) {
    return PanelSettings(
      title: title ?? this.title,
      geometry: geometry ?? this.geometry,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object?> get props => [title, geometry, mode];
}

class PanelBounds extends Equatable {
  final Size minSize;
  final Size maxSize;
  final Offset topleft;

  const PanelBounds({
    required this.minSize,
    required this.maxSize,
    this.topleft = Offset.zero,
  });

  factory PanelBounds.from(
    BuildContext context, {
    double minWidth = 100,
    double minHeight = 100,
    double scale = 1.0,
  }) {
    final fullSize = MediaQuery.sizeOf(context);
    final maxSize = fullSize * scale;

    final topLeft = Offset(
      (fullSize.width - maxSize.width) / 2,
      (fullSize.height - maxSize.height) / 2,
    );

    return PanelBounds(
      minSize: Size(minWidth, minHeight),
      maxSize: maxSize,
      topleft: topLeft,
    );
  }

  PanelBounds copyWith({
    Size? minSize,
    Size? maxSize,
    Offset? topleft,
  }) {
    return PanelBounds(
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      topleft: topleft ?? this.topleft,
    );
  }

  PanelGeometry get maximumGeometry {
    return PanelGeometry(
      origin: topleft,
      size: maxSize,
    );
  }

  PanelGeometry get minimumGeometry {
    return PanelGeometry(
      origin: topleft,
      size: minSize,
    );
  }

  PanelGeometry clamp(PanelGeometry geometry) {
    final clampedSize = Size(
      geometry.size.width.clamp(minSize.width, maxSize.width),
      geometry.size.height.clamp(minSize.height, maxSize.height),
    );

    return PanelGeometry(origin: geometry.origin, size: clampedSize);
  }

  @override
  List<Object?> get props => [minSize, maxSize, topleft];
}

enum PanelViewMode {
  normal,
  minimized,
  maximized,
}

enum PanelMode {
  window,
  preview,
}
