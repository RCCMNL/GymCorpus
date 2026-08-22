import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/presentation/widgets/header_tag.dart';

/// Card riassuntiva della routine in cima a WorkoutDetailScreen: titolo,
/// numero di esercizi e durata stimata.
class RoutineDetailHeader extends StatelessWidget {
  const RoutineDetailHeader({
    required this.title,
    required this.exerciseCount,
    required this.estimatedDuration,
    super.key,
  });

  final String title;
  final int exerciseCount;
  final int? estimatedDuration;

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
        borderRadius: BorderRadius.circular(28),
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
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.orangeAccent, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ROUTINE ATTUALE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
            ).createShader(bounds),
            child: Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                fontFamily: 'Lexend',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              HeaderTag(
                icon: Icons.fitness_center_rounded,
                label: '$exerciseCount ESERCIZI',
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                textColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              HeaderTag(
                icon: Icons.timer_outlined,
                label: '${estimatedDuration ?? "--"} MIN',
                color: Colors.orangeAccent.withValues(alpha: 0.08),
                textColor: Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
