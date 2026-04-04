import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Material Design usa ripple nativo con InkWell su cards
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  Text(
                    exercise.targetMuscle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  if (exercise.isVector)
                    const Chip(
                      label: Text("Vector"),
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
