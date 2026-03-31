import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/simple_overlay_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final manager = FloatingManager();
  final position = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListenableBuilder(
              listenable: manager,
              builder: (_, _) {
                return Text(
                  'Overlay is ${manager.isShowing ? "showing" : "hidden"}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            Text('Raw overlay examples'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      OverlayRouteConfig(
                        builder: (context) => AlertDialog(
                          title: const Text('Hello'),
                          content: const Text(
                            'This is a simple raw overlay dialog using route',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => manager.hide(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Show raw overlay with route'),
                ),
                ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      OverlayRouteConfig(
                        barrierConfig: const BarrierConfig(),
                        builder: (context) => AlertDialog(
                          title: const Text('Hello'),
                          content: const Text(
                            'This is a simple raw overlay dialog using route with barrier',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => manager.hide(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Show raw overlay with route and barrier'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      RawOverlayConfig(
                        builder: (context) => AlertDialog(
                          title: const Text('Hello'),
                          content: const Text(
                            'This is a simple raw overlay without route',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => manager.hide(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Show raw overlay with overlay'),
                ),
                ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      RawOverlayConfig(
                        transitionBuilder: (context, animation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        builder: (context) => AlertDialog(
                          title: const Text('Hello'),
                          content: const Text(
                            'This is a simple raw overlay without route but animated',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => manager.hide(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Show raw overlay with overlay/animation'),
                ),
              ],
            ),
            Text('Dialog route example'),
            ElevatedButton(
              onPressed: () {
                manager.show(
                  context,
                  DialogRouteConfig(
                    builder: (context, animation, secondaryAnimation) {
                      return AlertDialog(
                        title: const Text('Hello'),
                        content: const Text('This is a simple overlay dialog.'),
                        actions: [
                          TextButton(
                            onPressed: () => manager.hide(),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              child: const Text('Show dialog overlay'),
            ),
            Text("Custom route example"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      SimpleTransitionRouteConfig(
                        barrierConfig: BarrierConfig(),
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return ScaleTransition(
                                scale: animation,
                                child: AlignTransition(
                                  alignment: AlignmentTween(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        builder: (context, animation, secondaryAnimation) {
                          return AlertDialog(
                            title: const Text('Hello'),
                            content: const Text(
                              'This is a custom route dialog with barrier',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => manager.hide(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('Show custom route overlay with barrier'),
                ),
                ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      SimpleTransitionRouteConfig(
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return ScaleTransition(
                                scale: animation,
                                child: AlignTransition(
                                  alignment: AlignmentTween(
                                    begin: Alignment.topCenter,
                                    end: Alignment.center,
                                  ).animate(animation),

                                  child: child,
                                ),
                              );
                            },
                        builder: (context, animation, secondaryAnimation) {
                          return Material(
                            type: MaterialType.transparency,
                            child: Column(
                              spacing: 20,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'This is a custom route dialog without barrier',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                ElevatedButton(
                                  onPressed: () => manager.hide(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Show custom route overlay without barrier',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    manager.show(
                      context,
                      SimpleTransitionRouteConfig(
                        builder: (_, _, _) {
                          return Stack(
                            children: [
                              Positioned(
                                top: 10,
                                right: 20,
                                child: ColoredBox(
                                  color: Colors.red,
                                  child: const SizedBox(
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  child: Text("Show custom route overlay with Positioned"),
                ),
              ],
            ),
            Text("Transient overlay example"),
            ElevatedButton(
              onPressed: () async {
                await manager.show(
                  context,
                  SimpleTransitionRouteConfig(
                    transitionDuration: const Duration(seconds: 2),
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                          final alignment =
                              AlignmentTween(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(
                                    0.0,
                                    0.5,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                              );

                          final scale = Tween(
                            begin: 1.0,
                            end: 0.0,
                          ).animate(animation);

                          return AlignTransition(
                            alignment: alignment,
                            child: ScaleTransition(scale: scale, child: child),
                          );
                        },
                    builder: (context, animation, secondaryAnimation) {
                      return Material(
                        type: MaterialType.transparency,
                        child: AnimatedBuilder(
                          animation: animation,
                          builder: (_, _) {
                            return SizedBox(
                              width: 200,
                              height: 200,
                              child: ColoredBox(
                                color: Colors.red.withOpacity(animation.value),
                                child: const SizedBox.expand(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );

                assert(manager.isShowing);

                manager.hide();
              },
              child: const Text(
                'Show transient overlay (auto hide after animation)',
              ),
            ),
            Text("Draggable positioned overlay example"),
            ElevatedButton(
              onPressed: () {
                final config = RawOverlayConfig(
                  builder: (context) {
                    return ValueListenableBuilder<Offset>(
                      valueListenable: position,
                      builder: (context, value, child) {
                        return Positioned(
                          left: value.dx,
                          top: value.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              position.value += details.delta;
                            },
                            onPanEnd: (details) {
                              final globalPosition = details.globalPosition;

                              if (globalPosition.dx < 0 ||
                                  globalPosition.dy < 0) {
                                manager.hide();
                                return;
                              }
                            },
                            child: ColoredBox(
                              color: Colors.red,
                              child: const SizedBox(width: 100, height: 100),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );

                manager.show(context, config);
              },
              child: const Text('Show draggable positioned overlay'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              child: Text("Pop Route"),
            ),

            ElevatedButton(
              onPressed: () {
                manager.hide();
              },
              child: Text("Hide"),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Hello'),
                    content: const Text(
                      'This is a normal dialog without overlay',
                      style: TextStyle(color: Colors.red),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Text("Show normal dialog"),
            ),
          ],
        ),
      ),
    );
  }
}
