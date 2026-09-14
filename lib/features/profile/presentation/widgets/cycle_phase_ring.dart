import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_info.dart';

/// Anello con il giorno del ciclo e la fase corrente.
///
/// Quando le registrazioni non bastano non mostra alcun numero: prima
/// esibiva sempre "Giorno 3", anche a chi non aveva mai segnato nulla.
class CyclePhaseRing extends StatefulWidget {
  const CyclePhaseRing({required this.summary, super.key});

  final CycleSummary summary;

  @override
  State<CyclePhaseRing> createState() => _CyclePhaseRingState();
}

class _CyclePhaseRingState extends State<CyclePhaseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = widget.summary;
    final phase = summary.phase;
    final info = phase == null ? null : CyclePhaseInfo.of(phase);
    final color = info?.color ?? theme.colorScheme.outline;
    final day = summary.dayOfCycle;

    return Center(
      child: SizedBox(
        height: 260,
        width: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, _) => Container(
                width: 220 + (_pulseCtrl.value * 20),
                height: 220 + (_pulseCtrl.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                ),
              ),
            ),
            CustomPaint(
              size: const Size(220, 220),
              painter: _RingPainter(
                day ?? 0,
                summary.cycleLength,
                color,
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    info?.icon ?? Icons.calendar_month_rounded,
                    color: color,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  if (day != null && info != null) ...[
                    Text(
                      'Giorno $day',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    Text(
                      info.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    _EmptyRingLabel(state: summary.state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRingLabel extends StatelessWidget {
  const _EmptyRingLabel({required this.state});

  final CycleDataState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStale = state == CycleDataState.stale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isStale ? 'Dati non aggiornati' : 'Nessun ciclo registrato',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontFamily: 'Lexend',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isStale
              ? 'Registra di nuovo per riprendere il conteggio'
              : "Registra l'inizio della prossima mestruazione",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.day, this.total, this.color, this.background);

  final int day;
  final int total;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final progress = total <= 0 ? 0.0 : (day / total).clamp(0.0, 1.0);

    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = background
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.day != day ||
      old.total != total ||
      old.color != color ||
      old.background != background;
}
