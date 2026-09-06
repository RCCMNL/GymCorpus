import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/presentation/widgets/stat_column.dart';

/// Pannello inferiore semi-trasparente del CardioTrackerScreen: statistiche
/// live (distanza, durata, velocita', passi, calorie) e i controlli di
/// avvio/pausa/fine sessione.
class CardioStatsPanel extends StatelessWidget {
  const CardioStatsPanel({
    required this.isRun,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.currentSpeedKmh,
    required this.currentSteps,
    required this.userWeightKg,
    required this.isTracking,
    required this.isLocating,
    required this.isPaused,
    required this.isSaving,
    required this.onStart,
    required this.onPauseResume,
    required this.onStop,
    this.goal,
    super.key,
  });

  final bool isRun;
  final double distanceKm;
  final int elapsedSeconds;
  final double currentSpeedKmh;
  final int currentSteps;
  final double userWeightKg;
  final bool isTracking;
  final bool isLocating;
  final bool isPaused;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;

  /// Obiettivo scelto prima di partire, se c'e'.
  final CardioGoal? goal;

  /// Stessa stima MET usata nella colonna calorie e al salvataggio.
  int get _calories =>
      (userWeightKg * (isRun ? 9.8 : 3.8) * (elapsedSeconds / 3600)).round();

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Activity Type Label
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isRun
                            ? [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ]
                            : [Colors.orangeAccent, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isRun ? 'CORSA' : 'CAMMINATA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 10,
                      color: isRun
                          ? theme.colorScheme.primary
                          : Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatColumn(
                    label: 'DISTANZA',
                    value: '${distanceKm.toStringAsFixed(2)} km',
                    theme: theme,
                  ),
                  StatColumn(
                    label: 'DURATA',
                    value: _formatDuration(elapsedSeconds),
                    theme: theme,
                  ),
                  StatColumn(
                    label: 'VEL. MEDIA',
                    value:
                        '${(elapsedSeconds > 0 ? (distanceKm / (elapsedSeconds / 3600)) : 0).toStringAsFixed(1)} km/h',
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatColumn(
                    label: 'VELOCITÀ',
                    value: '${currentSpeedKmh.toStringAsFixed(1)} km/h',
                    theme: theme,
                  ),
                  StatColumn(
                    label: 'PASSI',
                    value: '$currentSteps',
                    theme: theme,
                  ),
                  StatColumn(
                    label: 'CALORIE',
                    value:
                        '${(userWeightKg * (isRun ? 9.8 : 3.8) * (elapsedSeconds / 3600)).round()} kcal',
                    theme: theme,
                  ),
                ],
              ),
              if (goal != null) ...[
                const SizedBox(height: 20),
                _GoalProgress(
                  goal: goal!,
                  distanceKm: distanceKm,
                  elapsedSeconds: elapsedSeconds,
                  calories: _calories,
                  accentColor: isRun
                      ? theme.colorScheme.primary
                      : Colors.orangeAccent,
                ),
              ],
              const SizedBox(height: 28),

              // Controls
              if (!isTracking && !isLocating)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStart,
                    icon: Icon(
                      isRun ? Icons.directions_run : Icons.directions_walk,
                    ),
                    label: Text(
                      'INIZIA ${isRun ? "CORSA" : "CAMMINATA"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRun
                          ? theme.colorScheme.primary
                          : Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPauseResume,
                        icon: Icon(
                          isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                        ),
                        label: Text(
                          isPaused ? 'RIPRENDI' : 'PAUSA',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHigh,
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : onStop,
                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.stop_rounded),
                        label: Text(
                          isSaving ? 'SALVO...' : 'FINE',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avanzamento verso l'obiettivo scelto per la sessione.
class _GoalProgress extends StatelessWidget {
  const _GoalProgress({
    required this.goal,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.calories,
    required this.accentColor,
  });

  final CardioGoal goal;
  final double distanceKm;
  final int elapsedSeconds;
  final int calories;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progress(
      distanceKm: distanceKm,
      seconds: elapsedSeconds,
      calories: calories,
    );
    final reached = goal.isReached(
      distanceKm: distanceKm,
      seconds: elapsedSeconds,
      calories: calories,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Obiettivo ${goal.label}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              reached ? 'Obiettivo raggiunto' : '${(progress * 100).round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: reached ? accentColor : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      ],
    );
  }
}
