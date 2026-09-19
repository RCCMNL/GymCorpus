import 'package:flutter/material.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_thumbnail.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/set_specs.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_session_widgets.dart';

/// Card dell'esercizio corrente durante una sessione di allenamento: nome,
/// immagine, contatore di serie e ripetizioni/peso della serie in corso.
class ExerciseProgressCard extends StatelessWidget {
  const ExerciseProgressCard({
    required this.exercise,
    required this.setIndex,
    required this.totalSets,
    required this.unit,
    super.key,
  });

  final RoutineExerciseEntity exercise;
  final int setIndex;
  final int totalSets;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentSpecs = getSetSpecs(exercise, setIndex);
    final isBodyweight = exercise.exercise.isBodyweight;

    return AppCard(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExerciseThumbnail.expand(exercise: exercise.exercise),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.4),
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.5, 0.9],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Eyebrow('ESERCIZIO CORRENTE'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exercise.exercise.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lexend',
                              height: 1.1,
                              fontSize: 22,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => showExerciseNotesDialog(
                            context,
                            exercise.exercise,
                            theme,
                          ),
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'SET',
                                style: TextStyle(
                                  color: theme.colorScheme.onTertiary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                              Text(
                                '${setIndex + 1}/$totalSets',
                                style: TextStyle(
                                  color: theme.colorScheme.onTertiary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: GlassChip(
                        label: 'RIPETIZIONI',
                        value: currentSpecs.reps.toString(),
                        color: theme.colorScheme.primary,
                        theme: theme,
                      ),
                    ),
                    if (!isBodyweight) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassChip(
                          label: 'PESO',
                          value: UnitConverter.formatWeight(
                            currentSpecs.weight,
                            unit,
                          ),
                          color: theme.colorScheme.secondary,
                          theme: theme,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog con le note personali salvate per [exercise].
void showExerciseNotesDialog(
  BuildContext context,
  ExerciseEntity exercise,
  ThemeData theme,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.notes, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Le tue note',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          (exercise.userNotes != null && exercise.userNotes!.trim().isNotEmpty)
              ? exercise.userNotes!
              : "Nessuna nota presente per questo esercizio.\n\nPuoi aggiungere appunti dalla schermata dei dettagli dell'esercizio.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                (exercise.userNotes != null &&
                    exercise.userNotes!.trim().isNotEmpty)
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline,
            fontStyle:
                (exercise.userNotes != null &&
                    exercise.userNotes!.trim().isNotEmpty)
                ? FontStyle.normal
                : FontStyle.italic,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CHIUDI',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      );
    },
  );
}
