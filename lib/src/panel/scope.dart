import 'package:flutter/widgets.dart';
import 'package:simple_overlay_kit/panels.dart';

class PanelScope extends InheritedWidget {
  final PanelController controller;

  const PanelScope({
    super.key,
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant PanelScope oldWidget) {
    return oldWidget.controller != controller;
  }

  static PanelController of(BuildContext context) {
    final controller = maybeOf(context);

    if (controller == null) {
      throw FlutterError(
        'PanelController.of() called with a context that does not contain a PanelController.\n'
        'Make sure to wrap your widget tree with a FloatingPanel.',
      );
    }

    return controller;
  }

  static PanelController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PanelScope>();
    return scope?.controller;
  }
}
