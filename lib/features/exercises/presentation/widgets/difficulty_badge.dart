import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Pillola colorata per il livello di difficoltà di un esercizio, usata
/// sia nella tile della lista sia nel dettaglio.
class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({required this.difficulty, super.key});

  final String difficulty;

  static Color colorFor(String difficulty) {
    switch (difficulty) {
      case ExerciseEntity.difficultyBeginner:
        return Colors.green;
      case ExerciseEntity.difficultyIntermediate:
        return Colors.orange;
      case ExerciseEntity.difficultyAdvanced:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
