import 'package:flutter/widgets.dart';

/// Material 3 window size classes. The app is built for a phone in one hand
/// and an 11" tablet on the counter, and those are genuinely different
/// layouts — not the same layout stretched.
///
/// | class     | width      | typical                        |
/// |-----------|------------|--------------------------------|
/// | compact   | < 600dp    | phone, either orientation      |
/// | medium    | 600–839dp  | 11" tablet portrait, foldable  |
/// | expanded  | ≥ 840dp    | 11" tablet landscape           |
enum WindowClass {
  compact,
  medium,
  expanded;

  static WindowClass of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return WindowClass.compact;
    if (w < 840) return WindowClass.medium;
    return WindowClass.expanded;
  }

  bool get isCompact => this == WindowClass.compact;
  bool get isWide => this != WindowClass.compact;

  /// Navigation moves to the side once there is room, so the thumb reach
  /// argument for a bottom bar stops applying.
  bool get usesRail => this == WindowClass.expanded;

  /// Cards per row in a list of orders.
  int get columns => switch (this) {
        WindowClass.compact => 1,
        WindowClass.medium => 2,
        WindowClass.expanded => 2,
      };
}

extension WindowClassX on BuildContext {
  WindowClass get window => WindowClass.of(this);
}

/// Caps and centres a column of content.
///
/// A form stretched across 1,200 logical pixels is not more usable, it is just
/// further for the eye to travel between a label and its field. Lists and forms
/// keep a comfortable measure and sit in the middle of the space.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.max = 720});

  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: max),
          child: child,
        ),
      );
}

/// Lays children out in [WindowClass.columns] columns, filling row by row.
/// One column is a plain list, so the phone path is unchanged.
class CardGrid extends StatelessWidget {
  const CardGrid({super.key, required this.children, this.spacing = 12});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final columns = context.window.columns;
    if (children.isEmpty) return const SizedBox.shrink();

    // [spacing] used to apply only *between columns*, so on a phone — where
    // there is one column — every card butted against the next and a list of
    // them read as one long slab.
    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            children[i],
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.sublist(
          i, i + columns > children.length ? children.length : i + columns);
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) SizedBox(width: spacing),
            Expanded(
              child: j < slice.length ? slice[j] : const SizedBox.shrink(),
            ),
          ],
        ],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          rows[i],
        ],
      ],
    );
  }
}
