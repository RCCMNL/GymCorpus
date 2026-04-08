import 'dart:math';
import 'package:flutter/material.dart';

class RadialTimerPicker extends StatefulWidget {
  const RadialTimerPicker({
    required this.initialSeconds,
    required this.onChanged,
    super.key,
    this.size = 240,
  });

  final int initialSeconds;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  State<RadialTimerPicker> createState() => _RadialTimerPickerState();
}

class _RadialTimerPickerState extends State<RadialTimerPicker> {
  late double _angle;
  late int _laps;
  double _lastAngle = 0;

  @override
  void initState() {
    super.initState();
    // 1 lap = 60 seconds
    _laps = widget.initialSeconds ~/ 60;
    _angle = ((widget.initialSeconds % 60) / 60.0) * 2 * pi;
    _lastAngle = _angle;
  }

  void _updateAngle(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final position = localPosition - center;
    
    var angle = atan2(position.dy, position.dx) + pi / 2;
    if (angle < 0) angle += 2 * pi;

    // Detect lap crossing
    // If moving from nearly 2pi to nearly 0 -> Clockwise lap end (lap + 1)
    // If moving from nearly 0 to nearly 2pi -> Counter-clockwise lap start (lap - 1)
    if ((_lastAngle - angle).abs() > pi) {
      if (_lastAngle < angle) {
        if (_laps > 0) _laps--;
      } else {
        if (_laps < 10) _laps++; // Cap at 10 mins (600s)
      }
    }
    
    _lastAngle = angle;
    
    setState(() {
      _angle = angle;
    });

    final currentSeconds = ((angle / (2 * pi)) * 60).round() % 60;
    final totalSeconds = (_laps * 60) + currentSeconds;
    
    widget.onChanged(max(1, totalSeconds));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentSeconds = ((_angle / (2 * pi)) * 60).round() % 60;
    final totalSeconds = (_laps * 60) + currentSeconds;
    final displayValue = max(1, totalSeconds);

    return GestureDetector(
      onPanUpdate: (details) => _updateAngle(details.localPosition, Size(widget.size, widget.size)),
      onPanDown: (details) => _updateAngle(details.localPosition, Size(widget.size, widget.size)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RadialPainter(
              angle: _angle,
              color: theme.colorScheme.primary,
              trackColor: theme.colorScheme.surfaceContainerHighest,
              laps: _laps,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayValue.toString(),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  color: theme.colorScheme.onSurface,
                  fontSize: displayValue > 99 ? 56 : 64,
                ),
              ),
              Text(
                'SECONDI',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.outline,
                ),
              ),
              if (_laps > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${_laps} min ${currentSeconds}s',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  _RadialPainter({
    required this.angle,
    required this.color,
    required this.trackColor,
    required this.laps,
  });

  final double angle;
  final Color color;
  final Color trackColor;
  final int laps;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 12.0;

    // Draw Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth, trackPaint);

    // If we have more than 0 laps, we might want to show the underlying full circle
    if (laps > 0) {
       final fullCirclePaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
       canvas.drawCircle(center, radius - strokeWidth, fullCirclePaint);
    }

    // Draw Progress
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      -pi / 2, // Start from top
      angle == 0 && laps > 0 ? 2 * pi : angle,
      false,
      progressPaint,
    );

    // Draw Handle
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final handleBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final handleCenter = Offset(
      center.dx + (radius - strokeWidth) * cos(angle - pi / 2),
      center.dy + (radius - strokeWidth) * sin(angle - pi / 2),
    );

    canvas.drawCircle(handleCenter, 14, handlePaint);
    canvas.drawCircle(handleCenter, 14, handleBorderPaint);
    
    // Lap counter inside handle or indicator
    if (laps > 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: laps.toString(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, handleCenter - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadialPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.laps != laps;
  }
}
