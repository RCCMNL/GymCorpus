import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Indicatore settimanale (lun-dom) dei giorni con almeno una serie
/// registrata.
class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({required this.weightLogs, super.key});
  final List<WorkoutSetEntity> weightLogs;

  // Calcola quali giorni della settimana corrente (lun-dom) hanno sessioni
  List<bool> _getWeekActivity() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final result = List<bool>.filled(7, false);
    for (final log in weightLogs) {
      final ts = log.timestamp;
      final diff = DateTime(ts.year, ts.month, ts.day)
          .difference(
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          )
          .inDays;
      if (diff >= 0 && diff < 7) result[diff] = true;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0=lun, 6=dom
    final completed = _getWeekActivity();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.md,
        border: Border(
          left: BorderSide(color: theme.colorScheme.secondary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATTIVITÀ SETTIMANALE',
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              final isToday = index == todayIndex;
              final isDone = completed[index];
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : (isDone
                                ? null
                                : Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.2,
                                    ),
                                  )),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: isDone ? 1 : 0.6,
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
