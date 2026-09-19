import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/training/presentation/widgets/header_tag.dart';

/// Card riassuntiva della routine in cima a WorkoutDetailScreen: titolo,
/// numero di esercizi e durata stimata.
class RoutineDetailHeader extends StatelessWidget {
  const RoutineDetailHeader({
    required this.title,
    required this.exerciseCount,
    required this.estimatedDuration,
    this.isSystem = false,
    super.key,
  });

  final String title;
  final int exerciseCount;
  final int? estimatedDuration;
  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.tertiary.withValues(alpha: 0.05),
            Colors.orangeAccent.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: AppRadius.xl,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.orangeAccent, Colors.deepOrange],
                  ),
                  borderRadius: AppRadius.pill,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Eyebrow(
                  'ROUTINE ATTUALE',
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GradientTitle(
            title,
            scale: GradientTitleScale.hero,
            style: const TextStyle(height: 1.1),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          // Le targhette vanno a capo invece di stare in fila per forza:
          // tre su uno schermo stretto uscivano dal riquadro.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HeaderTag(
                icon: Icons.fitness_center_rounded,
                label: '$exerciseCount ESERCIZI',
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                textColor: theme.colorScheme.primary,
              ),
              HeaderTag(
                icon: Icons.timer_outlined,
                label: '${estimatedDuration ?? "--"} MIN',
                color: Colors.orangeAccent.withValues(alpha: 0.08),
                textColor: Colors.orangeAccent,
              ),
              if (isSystem)
                HeaderTag(
                  icon: Icons.verified_rounded,
                  label: 'DI SISTEMA',
                  color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                  textColor: theme.colorScheme.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
