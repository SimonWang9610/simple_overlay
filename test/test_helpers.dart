import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget builderA(BuildContext context) => const Text('A');
Widget builderB(BuildContext context) => const Text('B');

Widget routePageBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
) {
  return const Text('route-page');
}

Future<BuildContext> pumpAppAndGetContext(WidgetTester tester) async {
  late BuildContext context;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    ),
  );

  return context;
}

int countAllBarriers(WidgetTester tester) {
  final modalCount = find.byType(ModalBarrier).evaluate().length;
  final animatedCount = find.byType(AnimatedModalBarrier).evaluate().length;
  return modalCount + animatedCount;
}

int countBarriersWithLabel(WidgetTester tester, String label) {
  final modalLabeled = tester
      .widgetList<ModalBarrier>(find.byType(ModalBarrier))
      .where((widget) => widget.semanticsLabel == label)
      .length;

  final animatedLabeled = tester
      .widgetList<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
      .where((widget) => widget.semanticsLabel == label)
      .length;

  return modalLabeled + animatedLabeled;
}
