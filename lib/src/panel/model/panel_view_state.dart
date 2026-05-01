import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'panel_geometry.dart';

/// Represents the state of a panel view, including its title, mode, and geometry.
class PanelViewState extends Equatable {
  final String? title;
  final PanelViewMode mode;
  final PanelGeometry geometry;

  const PanelViewState({
    this.title,
    this.mode = PanelViewMode.normal,
    required this.geometry,
  });

  @override
  List<Object?> get props => [title, mode, geometry];

  PanelViewState copyWith({
    String? title,
    PanelViewMode? mode,
    PanelGeometry? geometry,
  }) {
    return PanelViewState(
      title: title ?? this.title,
      mode: mode ?? this.mode,
      geometry: geometry ?? this.geometry,
    );
  }
}
