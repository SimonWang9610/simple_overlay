import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/panels.dart';

abstract interface class PanelSizer {
  Size constrain(PanelConstraints constraints);

  const factory PanelSizer.scale({double scale}) = _ScalePanelSizer;
  const factory PanelSizer.aspectRatio({double aspectRatio, double scale}) = _AspectRatioSizer;
  const factory PanelSizer.fixed({required Size size}) = _FixedSizeSizer;
}

final class _ScalePanelSizer implements PanelSizer {
  final double scale;

  const _ScalePanelSizer({
    this.scale = 0.8,
  }) : assert(scale > 0 && scale <= 1, 'Scale must be between 0 (exclusive) and 1 (inclusive)');

  @override
  Size constrain(PanelConstraints constraints) {
    final scaledSize = constraints.maxSize * scale;

    return scaledSize;
  }
}

final class _AspectRatioSizer implements PanelSizer {
  final double aspectRatio;
  final double scale;

  const _AspectRatioSizer({
    this.aspectRatio = 16 / 9,
    this.scale = 1.0,
  })  : assert(aspectRatio > 0, 'Aspect ratio must be greater than 0'),
        assert(scale > 0 && scale <= 1, 'Scale must be between 0 (exclusive) and 1 (inclusive)');

  @override
  Size constrain(PanelConstraints constraints) {
    final maxSize = constraints.maxSize * scale;
    final maxAspectRatio = maxSize.width / maxSize.height;

    final constrainedWidth = maxAspectRatio > aspectRatio ? maxSize.height * aspectRatio : maxSize.width;

    return Size(constrainedWidth, constrainedWidth / aspectRatio);
  }
}

final class _FixedSizeSizer implements PanelSizer {
  final Size size;

  const _FixedSizeSizer({
    required this.size,
  });

  @override
  Size constrain(PanelConstraints constraints) {
    return constraints.constrainSize(size);
  }
}
