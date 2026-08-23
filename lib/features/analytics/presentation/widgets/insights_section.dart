import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Fino a tre osservazioni generate dai dati di allenamento recenti
/// (stabilita' del peso, variazione di volume, distanza cardio percorsa).
class InsightsSection extends StatelessWidget {
  const InsightsSection({
    required this.state,
    required this.isImperial,
    super.key,
  });
  final TrainingState state;
  final bool isImperial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = _generateInsights(context);
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.tertiary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'INSIGHTS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 11,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(insight.icon, size: 16, color: insight.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight.text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Insight> _generateInsights(BuildContext context) {
    final insights = <Insight>[];
    final theme = Theme.of(context);

    if (state is! TrainingLoaded) return insights;
    final loaded = state as TrainingLoaded;

    // Weight stability insight
    if (loaded.bodyWeightLogs.length >= 3) {
      final recent3 = loaded.bodyWeightLogs
          .take(3)
          .map((e) => e.weight)
          .toList();
      final range =
          recent3.reduce((a, b) => a > b ? a : b) -
          recent3.reduce((a, b) => a < b ? a : b);
      if (range < 0.5) {
        insights.add(
          Insight(
            icon: Icons.balance,
            text:
                'Il tuo peso è stabile da ${loaded.bodyWeightLogs.length >= 7 ? "3" : "2"} settimane. Ottimo lavoro!',
            color: theme.colorScheme.tertiary,
          ),
        );
      }
    }

    // Volume trend insight
    final logs = loaded.weightLogs;
    if (logs.isNotEmpty) {
      final now = DateTime.now();
      final last30 = logs
          .where(
            (e) => e.timestamp.isAfter(now.subtract(const Duration(days: 30))),
          )
          .toList();
      final prev30 = logs
          .where(
            (e) =>
                e.timestamp.isAfter(now.subtract(const Duration(days: 60))) &&
                e.timestamp.isBefore(now.subtract(const Duration(days: 30))),
          )
          .toList();

      if (last30.isNotEmpty && prev30.isNotEmpty) {
        final volLast = last30.fold<double>(
          0,
          (sum, e) => sum + e.weight * e.reps,
        );
        final volPrev = prev30.fold<double>(
          0,
          (sum, e) => sum + e.weight * e.reps,
        );
        if (volPrev > 0) {
          final change = ((volLast - volPrev) / volPrev * 100).round();
          if (change > 0) {
            insights.add(
              Insight(
                icon: Icons.trending_up,
                text:
                    'Hai aumentato il volume totale del $change% negli ultimi 30 giorni.',
                color: theme.colorScheme.primary,
              ),
            );
          } else if (change < -5) {
            insights.add(
              Insight(
                icon: Icons.trending_down,
                text:
                    'Il volume totale è calato del ${change.abs()}% rispetto al mese precedente.',
                color: Colors.orangeAccent,
              ),
            );
          }
        }
      }
    }

    // Cardio sessions insight
    if (loaded.cardioSessions.isNotEmpty) {
      final totalKm = loaded.cardioSessions.fold<double>(
        0,
        (sum, e) => sum + e.distance,
      );
      insights.add(
        Insight(
          icon: Icons.directions_run,
          text:
              'Hai percorso ${totalKm.toStringAsFixed(1)} km in ${loaded.cardioSessions.length} sessioni cardio.',
          color: const Color(0xFFFF9494),
        ),
      );
    }

    return insights.take(3).toList();
  }
}

class Insight {
  const Insight({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;
}
