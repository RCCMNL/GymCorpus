import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({required this.exercise, super.key, this.onTap});

  final ExerciseEntity exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Material Design usa ripple nativo con InkWell su cards
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.accessibility_new, size: 16),
                  const SizedBox(width: 4),
                  // Il nome del gruppo muscolare puo' essere lungo: cede
                  // invece di spingere la riga fuori dalla card.
                  Expanded(
                    child: Text(
                      exercise.targetMuscle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (exercise.isVector)
                    const Chip(
                      label: Text('Vector'),
                      visualDensity: VisualDensity.compact,
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
