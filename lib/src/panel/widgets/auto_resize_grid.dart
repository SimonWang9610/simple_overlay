import 'dart:math' as math;
import 'package:flutter/material.dart';

class AutoResizeGrid extends StatelessWidget {
  final List<Widget> children;
  final WidgetBuilder? emptyBuilder;
  final double horizontalSpacing;
  final double verticalSpacing;
  final bool expandLastRow;
  const AutoResizeGrid({
    super.key,
    required this.children,
    this.emptyBuilder,
    this.horizontalSpacing = 4,
    this.verticalSpacing = 4,
    this.expandLastRow = false,
  });

  @override
  Widget build(BuildContext context) {
    final column = children.isNotEmpty ? math.sqrt(children.length).ceil() : 0;
    final row = children.isNotEmpty ? (children.length / column).ceil() : 0;

    final grid = <List<Widget>>[];

    for (int i = 0; i < row; i++) {
      final rowWidgets = <Widget>[];
      for (int j = 0; j < column; j++) {
        final index = i * column + j;
        if (index < children.length) {
          rowWidgets.add(children[index]);
        } else if (expandLastRow) {
          rowWidgets.add(const SizedBox.expand());
        }
      }
      grid.add(rowWidgets);
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        assert(
          constraints.maxHeight.isFinite,
          'AutoResizeGrid requires a finite height constraint to calculate item height.',
        );

        if (children.isEmpty) {
          return emptyBuilder?.call(context) ?? const SizedBox.shrink();
        }

        final itemHeight = (constraints.maxHeight - verticalSpacing * (row - 1)) / (row == 0 ? 1 : row);

        final itemWidths = <int, double>{};

        for (int i = 0; i < row; i++) {
          final availableWidth = constraints.maxWidth - horizontalSpacing * (grid[i].length - 1);
          final itemWidth = availableWidth / (grid[i].isEmpty ? 1 : grid[i].length);
          itemWidths[i] = itemWidth;
        }

        return Column(
          spacing: verticalSpacing,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < grid.length; i++)
              SizedBox(
                height: itemHeight,
                child: Row(
                  spacing: horizontalSpacing,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int j = 0; j < grid[i].length; j++)
                      SizedBox(
                        width: itemWidths[i],
                        child: grid[i][j],
                      )
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
