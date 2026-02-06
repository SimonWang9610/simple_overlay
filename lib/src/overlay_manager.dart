import 'package:flutter/widgets.dart';

abstract interface class DisposableOverlay {
  void dispose();
  void hide();
}

class SingleOverlayManager {
  bool get hasOverlay => _overlay != null;
  bool get isShowing => hasOverlay && (_overlay?.mounted ?? false);

  OverlayEntry? _overlay;

  void show(
    BuildContext context, {
    required WidgetBuilder builder,
    bool opaque = false,
    bool maintainState = false,
    bool canSizeOverlay = false,
  }) {
    assert(!isShowing, 'Overlay is already showing');

    _overlay = OverlayEntry(
      builder: builder,
      opaque: opaque,
      maintainState: maintainState,
      canSizeOverlay: canSizeOverlay,
    );

    Overlay.of(context).insert(_overlay!);
  }

  void hide() {
    _overlay?.remove();
    _overlay?.dispose();
    _overlay = null;
  }

  void rebuild() {
    _overlay?.markNeedsBuild();
  }
}
