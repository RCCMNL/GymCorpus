import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_activity_style.dart';
import 'package:gym_corpus/features/training/presentation/widgets/stat_column.dart';

/// Pannello inferiore semi-trasparente del CardioTrackerScreen: statistiche
/// live (distanza, durata, velocita', passi, calorie) e i controlli di
/// avvio/pausa/fine sessione.
class CardioStatsPanel extends StatelessWidget {
  const CardioStatsPanel({
    required this.activity,
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

  final CardioActivity activity;
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
  int get _calories => activity
      .caloriesFor(
        speedKmh: CardioActivity.averageSpeed(
          distanceKm: distanceKm,
          seconds: elapsedSeconds,
        ),
        weightKg: userWeightKg,
        seconds: elapsedSeconds,
      )
      .round();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Lo stesso colore che l'attivita' ha nel selettore e nello sfondo
    // della sessione: qui erano tutte arancioni tranne la corsa.
    final accent = activity.accent(theme);

    return ClipRRect(
      borderRadius: AppRadius.topXxl,
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
                        colors: [accent, accent.withValues(alpha: 0.6)],
                      ),
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    activity.label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 10,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Stats. Le colonne si dividono la larghezza in parti
              // uguali: a spaziatura libera i numeri piu' lunghi
              // spingevano la riga fuori dal pannello.
              Row(
                children: [
                  Expanded(
                    child: StatColumn(
                      label: 'DISTANZA',
                      value: '${distanceKm.toStringAsFixed(2)} km',
                      theme: theme,
                    ),
                  ),
                  Expanded(
                    child: StatColumn(
                      label: 'DURATA',
                      value: formatClock(elapsedSeconds),
                      theme: theme,
                    ),
                  ),
                  Expanded(
                    child: StatColumn(
                      label: 'VEL. MEDIA',
                      value:
                          '${(elapsedSeconds > 0 ? (distanceKm / (elapsedSeconds / 3600)) : 0).toStringAsFixed(1)} km/h',
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // La seconda riga e' il contorno: velocita' istantanea,
              // passi e calorie si guardano dopo, non mentre si corre.
              // Con lo stesso peso della prima erano sei numeri fra cui
              // scegliere ogni volta.
              Row(
                children: [
                  Expanded(
                    child: StatColumn(
                      label: 'VELOCITÀ',
                      value: '${currentSpeedKmh.toStringAsFixed(1)} km/h',
                      theme: theme,
                      prominence: StatProminence.secondary,
                    ),
                  ),
                  Expanded(
                    child: StatColumn(
                      label: 'PASSI',
                      value: '$currentSteps',
                      theme: theme,
                      prominence: StatProminence.secondary,
                    ),
                  ),
                  Expanded(
                    child: StatColumn(
                      label: 'CALORIE',
                      value: '$_calories kcal',
                      theme: theme,
                      prominence: StatProminence.secondary,
                    ),
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
                  accentColor: accent,
                ),
              ],
              const SizedBox(height: 28),

              // Controls
              if (!isTracking && !isLocating)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStart,
                    icon: Icon(activity.icon),
                    label: Text(
                      activity.startLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lg,
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
                        // Con il testo ingrandito l'etichetta non stava
                        // accanto all'icona: si stringe invece di uscire.
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isPaused ? 'RIPRENDI' : 'PAUSA',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHigh,
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.lg,
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
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isSaving ? 'SALVO...' : 'FINE',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.coral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.lg,
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
        // "Obiettivo 10 km" e "Obiettivo raggiunto" affiancati non
        // stavano in una riga stretta: cede l'obiettivo, che e' la parte
        // che si puo' accorciare senza perdere il senso.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Obiettivo ${goal.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                reached
                    ? 'Obiettivo raggiunto'
                    : '${(progress * 100).round()}%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: reached ? accentColor : theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppRadius.xs,
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
