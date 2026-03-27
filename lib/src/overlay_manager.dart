import 'dart:async';

import 'package:flutter/widgets.dart';
import 'routes/floating_config.dart';
import 'controllers.dart';

final class FloatingManager extends ChangeNotifier {
  FloatingManager();

  FloatingController? _controller;

  bool get isShowing => _controller?.value ?? false;

  FutureOr<void> show(BuildContext context, FloatingConfig config) async {
    if (_controller != null) {
      _disposeController();
    }

    _controller = FloatingController.withConfig(config);

    /// Listen to the controller's value changes and notify listeners of this manager.
    _controller!.addListener(notifyListeners);

    await _controller!.show(context);
  }

  FutureOr<void> hide() async {
    await _controller?.hide();
    _disposeController();
  }

  void _disposeController() {
    _controller?.removeListener(notifyListeners);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }
}
