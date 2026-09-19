import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// Intestazione della sessione di allenamento: titolo routine, cronometro
/// di esecuzione, controlli pausa/termina e barra di avanzamento serie.
class TrainingHeader extends StatelessWidget {
  const TrainingHeader({
    required this.routineTitle,
    required this.execTimeStr,
    required this.accentColor,
    required this.isPaused,
    required this.onTogglePause,
    required this.onConfirmEnd,
    required this.exerciseIndex,
    required this.exerciseCount,
    required this.progress,
    super.key,
  });

  final String routineTitle;
  final String execTimeStr;
  final Color accentColor;
  final bool isPaused;
  final VoidCallback onTogglePause;
  final VoidCallback onConfirmEnd;
  final int exerciseIndex;
  final int exerciseCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.15),
            accentColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        border: Border.all(color: accentColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routineTitle.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      execTimeStr,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onTogglePause,
                    icon: Icon(
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      color: accentColor,
                      size: 28,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: isPaused ? 'Riprendi' : 'Pausa',
                  ),
                  IconButton(
                    onPressed: onConfirmEnd,
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Termina Allenamento',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Esercizio ${exerciseIndex + 1} di $exerciseCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppRadius.xs,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
