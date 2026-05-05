import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_overlay_kit/panels.dart';

Future<BuildContext> pumpPanelAppAndGetContext(
  WidgetTester tester, {
  Size size = const Size(800, 600),
}) async {
  late BuildContext context;

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );

  return context;
}

Panel buildPanel({
  required Object id,
  required String text,
  Size size = const Size(160, 120),
  Offset? initialPosition,
  bool maintainState = true,
  bool useBuiltInView = true,
}) {
  return Panel(
    id: id,
    initialSize: size,
    initialPosition: initialPosition,
    maintainState: maintainState,
    useBuiltInView: useBuiltInView,
    builder: (_, __) => Text(text),
  );
}

PanelConstraints testConstraints({
  Size screen = const Size(800, 600),
  Size min = const Size(80, 60),
  Size? max,
  Offset origin = Offset.zero,
  double edgeVisibleThreshold = 20,
}) {
  return PanelConstraints(
    minSize: min,
    maxSize: max ?? screen,
    origin: origin,
    edgeVisibleThreshold: edgeVisibleThreshold,
  );
}
