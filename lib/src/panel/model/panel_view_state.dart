import 'package:equatable/equatable.dart';
import 'package:simple_overlay_kit/simple_overlay_kit.dart';

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
