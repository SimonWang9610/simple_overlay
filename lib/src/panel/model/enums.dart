/// Mode for how the panel view is displayed within its panel.
enum PanelViewMode {
  /// The panel is displayed in its normal state, with the user able to move and resize it.
  normal,

  /// The panel is minimized.
  ///
  /// The panel main view is not visible for [PanelMode.window],
  /// while for [PanelMode.preview], the panel is displayed in a scaled down version.
  ///
  /// Typically, the dock should have a way to show the minimized panels and allow users to restore them.
  minimized,

  /// The panel is maximized to fill the entire available space of the floating panel,
  /// constrained by [PanelConstraints].
  maximized,
}

/// Mode for how the panels are displayed within the floating panel.
enum PanelMode {
  /// Each panel is displayed in its own window, and the user can move and resize them freely.
  window,

  /// All panels are displayed together in a grid layout, and the user cannot move or resize them.
  preview,
}
