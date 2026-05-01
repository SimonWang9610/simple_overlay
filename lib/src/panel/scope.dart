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
        'PanelScope.of() called with a context that does not contain a PanelScope.\n'
        'Make sure the widget is a descendant of [MultiFloatingPanel] that is created when you call PanelController.open().',
      );
    }

    return controller;
  }

  static PanelController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PanelScope>();
    return scope?.controller;
  }
}
