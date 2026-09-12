import 'package:flutter/material.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_thumbnail.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/set_specs.dart';

/// Anteprima della prossima serie o del prossimo esercizio nella sessione
/// di allenamento in corso.
class NextUpCard extends StatelessWidget {
  const NextUpCard({
    required this.isLastSet,
    required this.currentExercise,
    required this.nextExercise,
    required this.setIndex,
    required this.totalSets,
    required this.unit,
    required this.accent,
    super.key,
  });

  final bool isLastSet;
  final RoutineExerciseEntity currentExercise;

  /// Esercizio successivo nella routine, o null se [currentExercise] e'
  /// l'ultimo.
  final RoutineExerciseEntity? nextExercise;
  final int setIndex;
  final int totalSets;
  final WeightUnit unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNextExercise = nextExercise != null;

    String nextName;
    String nextInfo;
    IconData nextIcon;
    if (!isLastSet) {
      nextName = currentExercise.exercise.name;
      final ns = setIndex + 2;
      final nextSpecs = getSetSpecs(currentExercise, setIndex + 1);
      nextInfo =
          'Prossima: ${formatSetSummary(currentExercise, nextSpecs, unit)} (Serie $ns di $totalSets)';
      nextIcon = Icons.replay_rounded;
    } else if (hasNextExercise) {
      final ne = nextExercise!;
      nextName = ne.exercise.name;
      final firstSpecs = getSetSpecs(ne, 0);
      nextInfo =
          'Inizio: ${formatSetSummary(ne, firstSpecs, unit)} (${ne.sets} serie totali)';
      nextIcon = Icons.arrow_forward_rounded;
    } else {
      nextName = 'Ultimo esercizio!';
      nextInfo = 'Dopo questa serie hai finito';
      nextIcon = Icons.emoji_events_rounded;
    }

    final showImage = nextName != 'Ultimo esercizio!' && hasNextExercise;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          if (showImage)
            ExerciseThumbnail(
              exercise: (isLastSet ? nextExercise! : currentExercise).exercise,
              size: 48,
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 48,
                height: 48,
                color: accent.withValues(alpha: 0.1),
                child: Icon(nextIcon, color: accent, size: 22),
              ),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('PROSSIMO'),
                const SizedBox(height: 4),
                Text(
                  nextName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nextInfo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            size: 20,
          ),
        ],
      ),
    );
  }
}
