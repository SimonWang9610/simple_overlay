import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/model/enums.dart';
import 'package:simple_overlay_kit/src/panel/model/panel_geometry.dart';
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

  PanelSettings getInitialSettings(Offset defaultOrigin, String defaultTitle) {
    return PanelSettings(
      title: title ?? defaultTitle,
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
