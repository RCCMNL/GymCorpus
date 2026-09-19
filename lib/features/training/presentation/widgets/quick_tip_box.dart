import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

/// Riquadro "PRO TIP" statico mostrato in fondo a WorkoutDetailScreen.
class QuickTipBox extends StatelessWidget {
  const QuickTipBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.gold.withValues(alpha: 0.1),
            AppPalette.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppRadius.xxl,
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.2)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.bolt_rounded,
              size: 80,
              color: AppPalette.gold.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    size: 20,
                    color: AppPalette.gold,
                  ),
                  SizedBox(width: 10),
                  Eyebrow('PRO TIP', color: AppPalette.gold),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Focus on explosive concentric movements and 2-second eccentric phases to maximize hypertrophy and power output for this routine.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
