import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PanelPreviewStyle extends Equatable {
  final double horizontalSpacing;
  final double verticalSpacing;
  final bool expandLastRow;
  final Color? barrierColor;
  final bool barrierDismissible;
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;

  const PanelPreviewStyle({
    this.horizontalSpacing = 8,
    this.verticalSpacing = 8,
    this.expandLastRow = false,
    this.barrierColor,
    this.barrierDismissible = true,
    this.decoration,
    this.focusedDecoration,
  });

  @override
  List<Object?> get props => [
        horizontalSpacing,
        verticalSpacing,
        expandLastRow,
        barrierColor,
        barrierDismissible,
        decoration,
        focusedDecoration,
      ];
}

class PanelConfig extends Equatable {
  final PanelPreviewStyle previewStyle;
  final BoxDecoration focusedDecoration;
  final BoxDecoration decoration;

  const PanelConfig({
    this.previewStyle = const PanelPreviewStyle(
      barrierColor: Colors.black54,
      barrierDismissible: true,
    ),
    this.focusedDecoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      boxShadow: [
        BoxShadow(
          color: Colors.purple,
          blurRadius: 5,
          offset: Offset(0, 1),
        ),
      ],
    ),
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      boxShadow: [
        BoxShadow(
          color: Colors.purple,
          blurRadius: 5,
          offset: Offset(0, 1),
        ),
      ],
    ),
  });

  @override
  List<Object?> get props => [
        previewStyle,
        focusedDecoration,
        decoration,
      ];

  Widget wrap(
    Widget panelView, {
    bool focused = false,
    bool preview = false,
  }) {
    final d = switch ((preview, focused)) {
      (true, false) => previewStyle.decoration ?? decoration,
      (true, true) => previewStyle.focusedDecoration ?? focusedDecoration,
      (false, true) => focusedDecoration,
      (false, false) => decoration,
    };

    if (d.borderRadius != null) {
      panelView = ClipRRect(
        borderRadius: d.borderRadius!,
        child: panelView,
      );
    }

    return DecoratedBox(
      decoration: d,
      child: panelView,
    );
  }
}
