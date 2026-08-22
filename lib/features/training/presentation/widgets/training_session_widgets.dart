import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Chip "vetro smerigliato" con etichetta e valore in evidenza, usato nella
/// card dell'esercizio corrente per mostrare ripetizioni e peso.
class GlassChip extends StatelessWidget {
  const GlassChip({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    super.key,
  });
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 7,
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsante a pillola pieno o outline, usato nell'overlay di recupero e
/// nell'overlay di pausa.
class ActionPill extends StatelessWidget {
  const ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
    required this.theme,
    super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFF94AAFF), Color(0xFF3367FF)],
                )
              : null,
          color: filled ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: filled
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: filled ? Colors.white : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                fontFamily: 'Lexend',
                color: filled ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Disegna l'anello di progresso del countdown di recupero.
class TimerRingPainter extends CustomPainter {
  const TimerRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });
  final double progress;
  final Color color;
  final Color trackColor;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sw = 8.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
    final sweep = 2 * math.pi * progress;
    canvas
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw + 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
