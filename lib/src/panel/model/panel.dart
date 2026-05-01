import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/src/panel/model/enums.dart';
import 'package:simple_overlay_kit/src/panel/model/panel_geometry.dart';
import 'package:simple_overlay_kit/src/panel/model/panel_view_state.dart';
import 'package:simple_overlay_kit/src/panel/controllers/panel_view_controller.dart';

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

  PanelViewState getInitialState(Offset defaultOrigin, String defaultTitle) {
    return PanelViewState(
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
