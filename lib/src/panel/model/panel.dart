import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/panel_view_controller.dart';

typedef PanelWidgetBuilder = Widget Function(BuildContext context, PanelViewController controller);

class Panel {
  final Object id;
  final PanelSettings settings;
  final PanelWidgetBuilder builder;

  const Panel({
    required this.id,
    required this.settings,
    required this.builder,
  });
}

class PanelViewEntry {
  final Object id;
  final PanelSettings settings;
  final PanelWidgetBuilder builder;
  final PanelViewController controller;

  const PanelViewEntry({
    required this.id,
    required this.settings,
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

  @override
  List<Object?> get props => [origin, size];
}

class PanelSettings extends Equatable {
  final String? title;
  final PanelGeometry geometry;

  const PanelSettings({
    this.title,
    required this.geometry,
  });

  PanelSettings copyWith({
    String? title,
    PanelGeometry? geometry,
  }) {
    return PanelSettings(
      title: title ?? this.title,
      geometry: geometry ?? this.geometry,
    );
  }

  @override
  List<Object?> get props => [title, geometry];
}

class PanelBounds extends Equatable {
  final Size minSize;
  final Size maxSize;
  final Offset topleft;

  const PanelBounds({
    required this.minSize,
    required this.maxSize,
    required this.topleft,
  });

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
