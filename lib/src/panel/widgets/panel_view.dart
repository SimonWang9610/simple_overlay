import 'package:flutter/material.dart';
import 'package:simple_overlay_kit/src/panel/model/panel.dart';
import 'package:simple_overlay_kit/src/panel/model/resize_direction.dart';

class PanelView extends StatefulWidget {
  final double resizeThreshold;
  final bool enabled;
  final PanelViewEntry entry;

  const PanelView({
    super.key,
    this.enabled = true,
    required this.entry,
    this.resizeThreshold = 10,
  });

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView> {
  final _cursor = ValueNotifier(MouseCursor.defer);

  final Map<ResizeDirection, Rect> _resizeZones = {};

  ResizeDirection? _direction;
  bool _gestureActive = false;

  @override
  void initState() {
    super.initState();

    widget.entry.controller.addListener(_determineResizeZones);
    _determineResizeZones();
  }

  @override
  void didUpdateWidget(covariant PanelView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.entry.controller != widget.entry.controller) {
      oldWidget.entry.controller.removeListener(_determineResizeZones);
      widget.entry.controller.addListener(_determineResizeZones);
      _determineResizeZones();
    }
  }

  void _determineResizeZones() {
    final size = widget.entry.controller.value.geometry.size;

    for (final d in ResizeDirection.values) {
      _resizeZones[d] = d.buildEdgeRect(
        size,
        widget.resizeThreshold,
      );
    }
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: GestureDetector(
        onTap: widget.entry.controller.bringToFront,
        onPanDown: (details) {
          widget.entry.controller.bringToFront();
          _updateCursor(details.localPosition);
          _gestureActive = true;
        },
        onPanEnd: (details) {
          _reset();
          _updateCursor(details.localPosition);
        },
        onPanUpdate: _onPanUpdate,
        child: ValueListenableBuilder(
          valueListenable: _cursor,
          builder: (_, cursor, child) {
            return MouseRegion(
              cursor: cursor,
              onExit: (event) => _reset(),
              onHover: (event) {
                if (!_gestureActive) {
                  _updateCursor(event.localPosition);
                }
              },
              child: child,
            );
          },
          child: widget.entry.builder(context, widget.entry.controller),
        ),
      ),
    );
  }

  void _updateCursor(Offset localPosition) {
    for (final entry in _resizeZones.entries) {
      if (entry.value.contains(localPosition)) {
        _cursor.value = entry.key.cursor;
        _direction = entry.key;
        return;
      }
    }

    _cursor.value = MouseCursor.defer;
    _direction = null;
  }

  void _reset() {
    _cursor.value = MouseCursor.defer;
    _direction = null;
    _gestureActive = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final delta = details.delta;

    if (_direction == null) {
      widget.entry.controller.move(delta.dx, delta.dy);
    } else {
      widget.entry.controller.resize(delta, _direction!);
    }
  }
}

extension on ResizeDirection {
  MouseCursor get cursor {
    switch (this) {
      case ResizeDirection.up:
      case ResizeDirection.down:
        return SystemMouseCursors.resizeUpDown;
      case ResizeDirection.left:
      case ResizeDirection.right:
        return SystemMouseCursors.resizeLeftRight;
      case ResizeDirection.topLeft:
      case ResizeDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.topRight:
      case ResizeDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
    }
  }
}
