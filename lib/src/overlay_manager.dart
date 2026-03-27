import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:simple_overlay/simple_overlay.dart';

final class OverlayManager extends ChangeNotifier {
  OverlayManager();

  FloatingOverlayController? _controller;

  bool get isShowing => _controller?.value ?? false;

  FutureOr<void> show(BuildContext context, OverlayConfig config) async {
    if (_controller != null) {
      _controller!.removeListener(notifyListeners);
      _controller!.dispose();
      _controller = null;
    }

    switch (config) {
      case RawOverlayConfig raw:
        _controller = RawOverlayController(raw);
      case RouteOverlayConfig route:
        _controller = TransitionOverlayController(route);
    }

    _controller!.addListener(notifyListeners);

    await _controller!.show(context);
  }

  FutureOr<void> hide() async {
    await _controller?.hide();
  }
}
