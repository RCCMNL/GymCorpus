import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Pillola colorata per il livello di difficoltà di un esercizio, usata
/// sia nella tile della lista sia nel dettaglio.
class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({required this.difficulty, super.key});

  final String difficulty;

  /// Scala semantica della difficolta', volutamente distinta dagli
  /// accenti del brand: qui il colore deve dire "facile / medio /
  /// difficile", non richiamare la palette. Sono comunque tarati sul
  /// fondo navy dell'app invece di essere i Colors.green/orange/red di
  /// Material, che su questo sfondo risultano spenti.
  static const Color _beginner = Color(0xFF6FE39B);
  static const Color _intermediate = Color(0xFFFFC46B);
  static const Color _advanced = Color(0xFFFF7A73);
  static const Color _unknown = Color(0xFF71729D);

  static Color colorFor(String difficulty) {
    switch (difficulty) {
      case ExerciseEntity.difficultyBeginner:
        return _beginner;
      case ExerciseEntity.difficultyIntermediate:
        return _intermediate;
      case ExerciseEntity.difficultyAdvanced:
        return _advanced;
      default:
        return _unknown;
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
