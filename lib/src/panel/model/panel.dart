import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';

typedef PanelWidgetBuilder = Widget Function(BuildContext context, PanelViewController controller);

class Panel {
  final Object id;

  /// Whether the panel's state should be maintained when it's not visible,
  /// or switching to a different mode.
  ///
  /// If false, the panel view state will not be maintained internally,
  /// it is the developer's responsibility to maintain the state externally if needed.
  final bool maintainState;

  /// Whether to use the built-in panel view [PanelEntryView], which handles dragging and resizing.
  ///
  /// If false, it is the developer's responsibility to provide their own implementation for dragging and resizing the panel.
  final bool useBuiltInView;

  /// Optional title for the panel, which can be used to build the panel item in the dock when the panel is minimized.
  final String? title;

  /// The initial position of the panel when it's first opened.
  /// If null, [PanelController] will determine the initial position based on the current open panels
  /// and the available space.
  ///
  /// [PanelConstraints]  will still apply to the initial position,
  /// so if the provided position is out of bounds,
  /// it will be adjusted to fit within the constraints.
  final Offset? initialPosition;

  /// The initial size of the panel when it's first opened.
  ///
  /// [PanelConstraints] will still apply to the initial size,
  /// so if the provided size is out of bounds,
  /// it will be adjusted to fit within the constraints.
  final Size initialSize;

  /// The builder function for the panel's content.
  ///
  /// If [useBuiltInView] is true, the builder will be wrapped in a [PanelEntryView],
  /// which provides built-in dragging and resizing functionality.
  ///
  /// All widgets built by this builder will be provided with a [PanelViewController]
  /// that can be used to control the panel's state and geometry.
  ///
  /// All Widgets can also use [PanelScope.of] to access the master [PanelController] to open new panels or switch modes.
  final PanelWidgetBuilder builder;

  const Panel({
    required this.id,
    required this.builder,
    this.title,
    this.initialPosition,
    required this.initialSize,
    this.maintainState = true,
    this.useBuiltInView = true,
  });

  PanelViewState getInitialState(Offset defaultOrigin, String defaultTitle) {
    return PanelViewState(
      title: title ?? defaultTitle,
      mode: PanelViewMode.normal,
      geometry: PanelGeometry(
        origin: initialPosition ?? defaultOrigin,
        size: initialSize,
      ),
    );
  }
}

class PanelEntry {
  final Object id;
  final bool useBuiltInView;
  final PanelWidgetBuilder builder;
  final PanelViewController controller;

  const PanelEntry({
    required this.id,
    required this.builder,
    required this.controller,
    required this.useBuiltInView,
  });
}
