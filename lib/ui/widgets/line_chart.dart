import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';

/// One measure over time.
///
/// **One series, one scale, one chart.** Orders and money are measures of
/// different kinds — a count against rupees — and drawing them against a
/// shared axis makes the smaller one a flat line along the bottom. Drawing
/// them against *two* axes is worse: the shape of the correlation then depends
/// on where the two scales are pinned, so the chart can be made to say almost
/// anything. Two of these stacked, sharing a month axis, says the true thing.
///
/// No chart package. Three of these are a `CustomPainter`, not a dependency on
/// an APK that was worked down from 68 MB to 25 MB.
class LineChart extends StatefulWidget {
  const LineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.format,
    this.height = 132,
  });

  /// Oldest first, one per point. Empty months are zeros, not gaps.
  final List<double> values;

  /// What each point is called, for the readout and the ends of the axis.
  final List<String> labels;

  /// How a value is written for a person.
  final String Function(double) format;

  final double height;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  /// The point being touched, if any. A chart on a phone has no room to label
  /// every month, so the labels are the two ends and whatever is under a
  /// finger.
  int? _touched;

  void _touch(Offset local, double width) {
    if (widget.values.length < 2) return;
    final step = width / (widget.values.length - 1);
    final i = (local.dx / step).round().clamp(0, widget.values.length - 1);
    if (i != _touched) setState(() => _touched = i);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shown = _touched;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The readout sits above the plot so a finger never covers it.
        SizedBox(
          height: 18,
          child: shown == null
              ? const SizedBox.shrink()
              : Text(
                  '${widget.labels[shown]} · ${widget.format(widget.values[shown])}',
                  style: context.text.bodySmall!.copyWith(color: c.ink2),
                ),
        ),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, box) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _touch(d.localPosition, box.maxWidth),
              onHorizontalDragUpdate: (d) =>
                  _touch(d.localPosition, box.maxWidth),
              onHorizontalDragEnd: (_) => setState(() => _touched = null),
              onTapUp: (_) => setState(() => _touched = null),
              child: CustomPaint(
                size: Size.infinite,
                painter: _LinePainter(
                  values: widget.values,
                  touched: _touched,
                  line: c.accent2,
                  grid: c.ruleSoft,
                  dot: c.accent2,
                  surface: c.surface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.xs),
        // The ends of the axis, and nothing between them: a label under every
        // month is unreadable at three years and unnecessary at three months.
        if (widget.labels.length >= 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.labels.first,
                  style: context.text.bodySmall!.copyWith(color: c.ink3)),
              Text(widget.labels.last,
                  style: context.text.bodySmall!.copyWith(color: c.ink3)),
            ],
          ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.values,
    required this.touched,
    required this.line,
    required this.grid,
    required this.dot,
    required this.surface,
  });

  final List<double> values;
  final int? touched;
  final Color line, grid, dot, surface;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Always from zero. A line chart of money that starts at its own minimum
    // turns a quiet month into a cliff.
    final peak = values.reduce((a, b) => a > b ? a : b);
    final top = peak <= 0 ? 1.0 : peak;

    final stroke = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // A baseline and a top rule: enough to read height against, recessive
    // enough not to compete with the data.
    final rule = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), rule);
    canvas.drawLine(Offset.zero, Offset(size.width, 0), rule);

    Offset at(int i) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = size.height - (values[i] / top) * size.height;
      return Offset(x, y.clamp(0.0, size.height));
    }

    if (values.length == 1) {
      canvas.drawCircle(at(0), 4, Paint()..color = dot);
      return;
    }

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(path, stroke);

    // The last point is labelled by the figure above the chart, so it gets a
    // marker; the touched one gets a bigger one and a line down to the axis.
    final t = touched;
    if (t != null) {
      canvas.drawLine(Offset(at(t).dx, 0), Offset(at(t).dx, size.height),
          Paint()..color = grid..strokeWidth = 1);
    }
    for (final i in {values.length - 1, if (t != null) t}) {
      // A ring in the surface colour, so a marker sitting on the line still
      // reads as a point rather than a thickening.
      canvas.drawCircle(at(i), i == t ? 5 : 4, Paint()..color = surface);
      canvas.drawCircle(at(i), i == t ? 4 : 3, Paint()..color = dot);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.values != values || old.touched != touched || old.line != line;
}
