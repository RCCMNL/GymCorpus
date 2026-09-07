import 'package:flutter/material.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/difficulty_badge.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_thumbnail.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Il pulsante tondo e velato della barra di ExerciseDetailScreen.
///
/// Indietro, modifica, elimina e preferito lo riscrivevano uguale, quattro
/// volte nello stesso `build`.
class CircleActionButton extends StatelessWidget {
  const CircleActionButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      child: IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        onPressed: onPressed,
      ),
    );
  }
}

/// L'apertura della scheda esercizio: immagine a tutta larghezza, sfumatura
/// verso lo sfondo, muscolo, difficolta' e nome.
class ExerciseHero extends StatelessWidget {
  const ExerciseHero({required this.exercise, super.key});

  static const _height = 380.0;

  /// Sopra i venti caratteri il nome scende da 48 a 32: e' la soglia oltre
  /// la quale andava a capo sull'immagine.
  static const _longNameLength = 20;

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difficulty = exercise.difficulty;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: _height,
          child: ExerciseThumbnail.expand(exercise: exercise),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.1),
                  Colors.transparent,
                  theme.colorScheme.surface.withValues(alpha: 0.6),
                  theme.colorScheme.surface,
                ],
                stops: const [0, 0.4, 0.8, 1],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      exercise.targetMuscle.toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  if (difficulty != null) ...[
                    const SizedBox(width: 8),
                    DifficultyBadge(difficulty: difficulty),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exercise.name,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: exercise.name.length > _longNameLength ? 32 : 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
