import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/simple_overlay_kit.dart';

class FloatingPanelExample extends StatefulWidget {
  const FloatingPanelExample({super.key});

  @override
  State<FloatingPanelExample> createState() => _FloatingPanelExampleState();
}

class _FloatingPanelExampleState extends State<FloatingPanelExample> {
  final manager = FloatingManager();

  PanelController? _panelController;

  @override
  void dispose() {
    _panelController?.dispose();
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AlertDialog();
    return Scaffold(
      appBar: AppBar(title: const Text('Floating Panel Example')),
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            ElevatedButton(
              onPressed: () {
                _showPanel();
              },
              child: const Text('Show Panel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Pop route'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Dialog'),
                    content: const Text('This is a dialog.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Show dialog'),
            ),
            const Spacer(),
            if (_panelController != null)
              Align(
                alignment: Alignment.centerLeft,
                child: FloatingPanelDock(controller: _panelController!),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_panelController == null) return;

          if (_panelController?.mode == PanelMode.window) {
            _panelController!.mode = PanelMode.preview;
          } else {
            _panelController!.mode = PanelMode.window;
          }
        },
        child: const Icon(Icons.fullscreen),
      ),
    );
  }

  void _showPanel() {
    _panelController ??= PanelController(context);

    _panelController!.open(
      Panel(
        id: 'main_panel',
        title: 'Main Panel',
        initialSize: const Size(400, 400),
        builder: (_, c) => _PanelWidget(controller: c),
      ),
    );

    setState(() {});
  }
}

class _PanelWidget extends StatefulWidget {
  final PanelViewController controller;
  const _PanelWidget({
    required this.controller,
  });

  @override
  State<_PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<_PanelWidget> {
  Timer? _timer;

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, settings, _) {
        return Material(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (settings.mode == PanelViewMode.maximized) {
                          widget.controller.restore();
                        } else {
                          widget.controller.maximize();
                        }
                      },
                      icon: const Icon(Icons.fullscreen),
                    ),
                    Expanded(
                      child: Text(settings.title ?? "Untitled Panel"),
                    ),
                    IconButton(
                      onPressed: widget.controller.close,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _open(context),
                  child: const Text('Open sub panel'),
                ),
                Text('Counter: $_counter'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context) {
    final panelController = FloatingPanel.of(context);

    panelController.open(
      Panel(
        id: UniqueKey(),
        maintainState: false,
        initialSize: const Size(200, 200),
        builder: (_, c) => _PanelWidget(controller: c),
      ),
    );
  }
}
