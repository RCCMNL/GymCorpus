import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrainingBloc>()
      ..add(LoadWeightLogsEvent())
      ..add(LoadBodyWeightLogsEvent())
      ..add(LoadCardioSessionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            var sessionsCount = 0;
            double totalWeight = 0;
            var monthSessions = 0;
            double monthWeight = 0;
            var totalRealMinutes = 0;
            var monthRealMinutes = 0;

            var currentUnit = 'KG';
            if (state is TrainingLoaded) {
              currentUnit = state.settings['units'] ?? 'KG';
              final logs = state.weightLogs;
              sessionsCount = logs.map((e) => e.workoutId).toSet().length;
              totalWeight = logs.fold(0, (sum, e) => sum + (e.weight * e.reps));

              // Calcolo durata reale per workoutId:
              // - se l'ultimo set ha rpe != null → è la durata reale in secondi
              // - altrimenti fallback: max(timestamp) - workoutId (start ms)
              final workoutIds = logs.map((e) => e.workoutId).toSet();
              for (final wid in workoutIds) {
                final sessionLogs = logs.where((e) => e.workoutId == wid).toList();
                // Cerca il set con rpe (durata salvata)
                final withRpe = sessionLogs.where((e) => e.rpe != null).toList();
                int durationSec;
                if (withRpe.isNotEmpty) {
                  durationSec = withRpe.last.rpe!;
                } else {
                  // Fallback: differenza tra ultimo timestamp e inizio sessione
                  final maxTs = sessionLogs
                      .map((e) => e.timestamp.millisecondsSinceEpoch)
                      .reduce((a, b) => a > b ? a : b);
                  durationSec = ((maxTs - wid) / 1000).round();
                  if (durationSec < 0) durationSec = sessionLogs.length * 180;
                }
                totalRealMinutes += (durationSec / 60).round();
              }

              final now = DateTime.now();
              final monthLogs = logs
                  .where(
                    (e) =>
                        e.timestamp.month == now.month &&
                        e.timestamp.year == now.year,
                  )
                  .toList();
              monthSessions = monthLogs.map((e) => e.workoutId).toSet().length;
              monthWeight =
                  monthLogs.fold(0, (sum, e) => sum + (e.weight * e.reps));
              // Durata reale solo per sessioni del mese
              final monthWorkoutIds = monthLogs.map((e) => e.workoutId).toSet();
              for (final wid in monthWorkoutIds) {
                final sessionLogs = logs.where((e) => e.workoutId == wid).toList();
                final withRpe = sessionLogs.where((e) => e.rpe != null).toList();
                int durationSec;
                if (withRpe.isNotEmpty) {
                  durationSec = withRpe.last.rpe!;
                } else {
                  final maxTs = sessionLogs
                      .map((e) => e.timestamp.millisecondsSinceEpoch)
                      .reduce((a, b) => a > b ? a : b);
                  durationSec = ((maxTs - wid) / 1000).round();
                  if (durationSec < 0) durationSec = sessionLogs.length * 180;
                }
                monthRealMinutes += (durationSec / 60).round();
              }
            }
            final isImperial = currentUnit == 'LB';

            String _fmtDuration(int minutes) {
              if (minutes < 60) return '${minutes}min';
              final h = minutes ~/ 60;
              final m = minutes % 60;
              return m == 0 ? '${h}h' : '${h}h${m}m';
            }

            String _fmtVolume(double kg) {
              if (kg < 1000) return '${kg.toStringAsFixed(0)} kg';
              return '${(kg / 1000).toStringAsFixed(1)}k kg';
            }

            String _fmtVolumeImperial(double kg) {
              final lb = UnitConverter.kgToLb(kg);
              if (lb < 1000) return '${lb.toStringAsFixed(0)} lb';
              return '${(lb / 1000).toStringAsFixed(1)}k lb';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics Dashboard',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PERFORMANCE TRACKING & VOLUME INSIGHTS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Insights Section
                  _InsightsSection(state: state, isImperial: isImperial),
                  const SizedBox(height: 24),

                  // Stats Cards Grid
                  _StatSection(
                    title: 'Statistiche Totali',
                    color: theme.colorScheme.primary,
                    stats: [
                      _StatItem(
                        icon: Icons.fitness_center,
                        value: sessionsCount.toString(),
                        label: 'Allenamenti',
                      ),
                      _StatItem(
                        icon: Icons.schedule,
                        value: _fmtDuration(totalRealMinutes),
                        label: 'Tempo totale',
                      ),
                      _StatItem(
                        icon: Icons.scale,
                        value: isImperial
                            ? _fmtVolumeImperial(totalWeight)
                            : _fmtVolume(totalWeight),
                        label: 'Volume',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StatSection(
                    title: 'Questo Mese',
                    color: theme.colorScheme.tertiary,
                    stats: [
                      _StatItem(
                        icon: Icons.calendar_month,
                        value: monthSessions.toString(),
                        label: 'Allenamenti',
                      ),
                      _StatItem(
                        icon: Icons.timer,
                        value: _fmtDuration(monthRealMinutes),
                        label: 'Tempo trascorso',
                      ),
                      _StatItem(
                        icon: Icons.trending_up,
                        value: isImperial
                            ? _fmtVolumeImperial(monthWeight)
                            : _fmtVolume(monthWeight),
                        label: 'Volume',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // This Week Activity Card
                  _ActivityCard(
                    weightLogs: state is TrainingLoaded
                        ? state.weightLogs
                        : [],
                  ),

                  const SizedBox(height: 24),

                  // Weight Tracking Card
                  const _WeightTrackingCard(),

                  const SizedBox(height: 24),

                  // BMI Card
                  const _BMICard(),

                  const SizedBox(height: 24),

                  // Cardio History Section
                  _CardioHistorySection(state: state),

                  const SizedBox(height: 100), // Bottom padding for navbar
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── INSIGHTS ──────────────────────────────────────────────────────────────

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.state, required this.isImperial});
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
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
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

  List<_Insight> _generateInsights(BuildContext context) {
    final insights = <_Insight>[];
    final theme = Theme.of(context);

    if (state is! TrainingLoaded) return insights;
    final loaded = state as TrainingLoaded;

    // Weight stability insight
    if (loaded.bodyWeightLogs.length >= 3) {
      final recent3 =
          loaded.bodyWeightLogs.take(3).map((e) => e.weight).toList();
      final range = recent3.reduce((a, b) => a > b ? a : b) -
          recent3.reduce((a, b) => a < b ? a : b);
      if (range < 0.5) {
        insights.add(
          _Insight(
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
            (e) => e.timestamp.isAfter(
              now.subtract(const Duration(days: 30)),
            ),
          )
          .toList();
      final prev30 = logs
          .where(
            (e) =>
                e.timestamp.isAfter(now.subtract(const Duration(days: 60))) &&
                e.timestamp.isBefore(
                  now.subtract(const Duration(days: 30)),
                ),
          )
          .toList();

      if (last30.isNotEmpty && prev30.isNotEmpty) {
        final volLast =
            last30.fold<double>(0, (sum, e) => sum + e.weight * e.reps);
        final volPrev =
            prev30.fold<double>(0, (sum, e) => sum + e.weight * e.reps);
        if (volPrev > 0) {
          final change = ((volLast - volPrev) / volPrev * 100).round();
          if (change > 0) {
            insights.add(
              _Insight(
                icon: Icons.trending_up,
                text:
                    'Hai aumentato il volume totale del $change% negli ultimi 30 giorni.',
                color: theme.colorScheme.primary,
              ),
            );
          } else if (change < -5) {
            insights.add(
              _Insight(
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
      final totalKm =
          loaded.cardioSessions.fold<double>(0, (sum, e) => sum + e.distance);
      insights.add(
        _Insight(
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

class _Insight {
  const _Insight({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;
}

// ─── STATS ─────────────────────────────────────────────────────────────────

class _StatSection extends StatelessWidget {
  const _StatSection({
    required this.title,
    required this.color,
    required this.stats,
  });

  final String title;
  final Color color;
  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ─── ACTIVITY ──────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.weightLogs});
  final List<WorkoutSetEntity> weightLogs;

  // Calcola quali giorni della settimana corrente (lun-dom) hanno sessioni
  List<bool> _getWeekActivity() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final result = List<bool>.filled(7, false);
    for (final log in weightLogs) {
      final ts = log.timestamp;
      final diff = DateTime(ts.year, ts.month, ts.day)
          .difference(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day))
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
        borderRadius: BorderRadius.circular(16),
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
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                                )),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.secondary
                                    .withValues(alpha: 0.4),
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
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: isDone ? 1 : 0.6),
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

// ─── WEIGHT TRACKING ───────────────────────────────────────────────────────

class _WeightTrackingCard extends StatefulWidget {
  const _WeightTrackingCard();

  @override
  State<_WeightTrackingCard> createState() => _WeightTrackingCardState();
}

class _WeightTrackingCardState extends State<_WeightTrackingCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        var current = '--';
        var max = '--';
        var min = '--';
        var trendPoints = <double>[];

        final trainingState = context.read<TrainingBloc>().state;
        final settings = trainingState is TrainingLoaded
            ? trainingState.settings
            : <String, String>{};
        final isImperial = (settings['units'] ?? 'KG') == 'LB';
        final unitText = isImperial ? 'lb' : 'kg';

        if (state is TrainingLoaded) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final startDate = today.subtract(const Duration(days: 29));

          final logs = state.bodyWeightLogs;
          final dayMap = <DateTime, double>{};
          final actualDataDays = <int>{};
          final dates = <DateTime>[];
          final points = <double>[];

          if (logs.isNotEmpty) {
            for (final log in logs) {
              final d = DateTime(log.date.year, log.date.month, log.date.day);
              if (!dayMap.containsKey(d)) {
                dayMap[d] = log.weight;
              }
            }

            var lastWeight =
                logs.reduce((a, b) => a.date.isBefore(b.date) ? a : b).weight;

            for (var i = 0; i < 30; i++) {
              final d = startDate.add(Duration(days: i));
              dates.add(d);
              if (dayMap.containsKey(d)) {
                lastWeight = dayMap[d] ?? lastWeight;
                actualDataDays.add(i);
              }

              points.add(
                isImperial ? UnitConverter.kgToLb(lastWeight) : lastWeight,
              );
            }
            trendPoints = points;

            // Stats
            final latestWeightValue = logs.first.weight;
            current = (isImperial
                    ? UnitConverter.kgToLb(latestWeightValue)
                    : latestWeightValue)
                .toStringAsFixed(1);

            final allProcessedWeights = logs
                .map(
                  (e) => isImperial ? UnitConverter.kgToLb(e.weight) : e.weight,
                )
                .toList();
            max = allProcessedWeights
                .reduce((a, b) => a > b ? a : b)
                .toStringAsFixed(1);
            min = allProcessedWeights
                .reduce((a, b) => a < b ? a : b)
                .toStringAsFixed(1);
          } else {
            // Empty state defaults
            for (var i = 0; i < 30; i++) {
              dates.add(startDate.add(Duration(days: i)));
              points.add(0);
            }
            trendPoints = points;
          }

          // Calculate change
          double change = 0;
          if (points.length >= 2) {
            change = points.last - points.first;
          }
          final changeText =
              (change >= 0 ? '+' : '') + change.toStringAsFixed(1);
          final changeColor = change <= 0
              ? theme.colorScheme.tertiary
              : theme.colorScheme.error;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progresso Peso',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: changeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$changeText $unitText',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: changeColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ULTIMI 30 GIORNI',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(fontSize: 9, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: () => _showAddWeightDialog(context),
                          icon: const Icon(Icons.add_rounded, size: 24),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _WeightItem(
                      label: 'Attuale',
                      value: current,
                      unit: unitText,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    _WeightItem(
                      label: 'Max',
                      value: max,
                      unit: unitText,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    _WeightItem(
                      label: 'Min',
                      value: min,
                      unit: unitText,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final graphWidth = constraints.maxWidth;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) => _handleTouch(
                        details.localPosition,
                        trendPoints.length,
                        graphWidth,
                        isDrag: true,
                        actualIndices: actualDataDays,
                      ),
                      onTapDown: (details) => _handleTouch(
                        details.localPosition,
                        trendPoints.length,
                        graphWidth,
                        isTap: true,
                        actualIndices: actualDataDays,
                      ),
                      child: Stack(
                        children: [
                          // Grid lines
                          Column(
                            children: List.generate(
                              4,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 22),
                                child: Divider(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.05),
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _TrendLinePainter(
                                color: theme.colorScheme.primary,
                                dataPoints: trendPoints,
                                actualDataIndices: actualDataDays,
                                accentColor: theme.colorScheme.tertiary,
                                selectedIndex: _selectedIndex,
                                selectedDate: _selectedIndex != null
                                    ? dates[_selectedIndex!]
                                    : null,
                                unitText: unitText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${startDate.day} ${UnitConverter.monthName(startDate.month)}'
                          .toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    // Week indicators
                    ...List.generate(3, (index) {
                      final weekNum = 3 - index;
                      return Text(
                        '-$weekNum SET',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 7,
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.4),
                        ),
                      );
                    }),
                    Text(
                      'OGGI',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleTouch(
    Offset localPosition,
    int pointsCount,
    double graphWidth, {
    required Set<int> actualIndices,
    bool isTap = false,
    bool isDrag = false,
  }) {
    if (pointsCount == 0 || graphWidth <= 0 || actualIndices.isEmpty) return;
    final stepX = graphWidth / (pointsCount - 1);
    final touchX = localPosition.dx;

    // Magnetic logic: find the NEAREST point that actually has data
    var closestActualIndex = -1;
    var minDistance = double.infinity;

    for (final i in actualIndices) {
      final pointX = i * stepX;
      final distance = (touchX - pointX).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestActualIndex = i;
      }
    }

    // Always include the last point (Today) in the magnetic search if it's not already in actualIndices
    // (In case the last point is always shown but doesn't have a "log" for today yet,
    // though usually today is part of the plot)
    final lastPointX = (pointsCount - 1) * stepX;
    final distToLast = (touchX - lastPointX).abs();
    if (distToLast < minDistance) {
      minDistance = distToLast;
      closestActualIndex = pointsCount - 1;
    }

    // Threshold for activation (increased to 45 for better UX)
    if (closestActualIndex != -1 && minDistance < 45) {
      if (isTap && _selectedIndex == closestActualIndex) {
        // Toggle off if tapping the same point
        setState(() => _selectedIndex = null);
      } else if (_selectedIndex != closestActualIndex) {
        HapticFeedback.selectionClick();
        setState(() => _selectedIndex = closestActualIndex);
      }
    } else {
      // Clear selection if tapping/dragging far away
      if (_selectedIndex != null) {
        setState(() => _selectedIndex = null);
      }
    }
  }

  void _showAddWeightDialog(BuildContext context) {
    _showWeightDialog(context);
  }

  void _showWeightDialog(BuildContext context, {BodyWeightLogEntity? log}) {
    final controller =
        TextEditingController(text: log != null ? log.weight.toString() : '');
    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    if (log != null) {
      final w = isImperial ? UnitConverter.kgToLb(log.weight) : log.weight;
      controller.text = w.toStringAsFixed(1);
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log == null ? 'Registra Peso' : 'Modifica Peso'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: isImperial ? 'Peso (lb)' : 'Peso (kg)',
            suffixText: isImperial ? 'lb' : 'kg',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final weightValue =
                  double.tryParse(controller.text.replaceAll(',', '.'));
              if (weightValue != null) {
                var weight = weightValue;
                if (isImperial) {
                  weight = UnitConverter.lbToKg(weight);
                }
                if (log == null) {
                  context
                      .read<TrainingBloc>()
                      .add(AddBodyWeightLogEvent(weight));
                } else {
                  context
                      .read<TrainingBloc>()
                      .add(UpdateBodyWeightLogEvent(log.id!, weight));
                }
                Navigator.pop(context);
              }
            },
            child: Text(log == null ? 'Salva' : 'Aggiorna'),
          ),
        ],
      ),
    );
  }
}

class _WeightItem extends StatelessWidget {
  const _WeightItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TREND PAINTER ─────────────────────────────────────────────────────────

class _TrendLinePainter extends CustomPainter {
  const _TrendLinePainter({
    required this.color,
    required this.dataPoints,
    required this.actualDataIndices,
    required this.accentColor,
    this.selectedIndex,
    this.selectedDate,
    this.unitText = 'kg',
  });

  final Color color;
  final Color accentColor;
  final List<double> dataPoints;
  final Set<int> actualDataIndices;
  final int? selectedIndex;
  final DateTime? selectedDate;
  final String unitText;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final stepX =
        size.width / (dataPoints.length > 1 ? dataPoints.length - 1 : 1);

    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs() < 0.1 ? 2.0 : (maxVal - minVal) * 1.2;
    final center = (maxVal + minVal) / 2;

    Offset getOffset(int i) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - (center - range / 2)) / range;
      final y = size.height - (normalizedY * size.height).clamp(0, size.height);
      return Offset(x, y);
    }

    for (var i = 0; i < dataPoints.length; i++) {
      final pos = getOffset(i);
      if (i == 0) {
        path.moveTo(pos.dx, pos.dy);
        fillPath
          ..moveTo(pos.dx, size.height)
          ..lineTo(pos.dx, pos.dy);
      } else {
        path.lineTo(pos.dx, pos.dy);
        fillPath.lineTo(pos.dx, pos.dy);
      }

      if (i == dataPoints.length - 1) {
        fillPath
          ..lineTo(pos.dx, size.height)
          ..close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);

    // Draw vertical day ticks
    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (var i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final isWeek = (dataPoints.length - 1 - i) % 7 == 0;
      if (isWeek) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          tickPaint..color = color.withValues(alpha: 0.2),
        );
      } else {
        canvas.drawLine(
          Offset(x, size.height - 5),
          Offset(x, size.height),
          tickPaint..color = color.withValues(alpha: 0.1),
        );
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots for actual data points
    for (final i in actualDataIndices) {
      final pos = getOffset(i);
      canvas
        ..drawCircle(pos, 4, Paint()..color = Colors.white)
        ..drawCircle(pos, 2.5, Paint()..color = color);
    }

    // Endpoint dot (Today)
    final lastPos = getOffset(dataPoints.length - 1);
    canvas
      ..drawCircle(lastPos, 5, Paint()..color = color)
      ..drawCircle(lastPos, 3, Paint()..color = Colors.white);

    // DRAW TOOLTIP IF SELECTED
    if (selectedIndex != null && selectedDate != null) {
      final pos = getOffset(selectedIndex!);

      // Vertical line
      canvas
        ..drawLine(
          Offset(pos.dx, 0),
          Offset(pos.dx, size.height),
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        )
        ..drawCircle(pos, 6, Paint()..color = color)
        ..drawCircle(pos, 4, Paint()..color = Colors.white);

      // Tooltip Box
      final textWeight =
          '${dataPoints[selectedIndex!].toStringAsFixed(1)} $unitText';
      final textDate =
          '${selectedDate!.day} ${UnitConverter.monthName(selectedDate!.month)}';

      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$textWeight\n',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                fontFamily: 'Lexend',
              ),
            ),
            TextSpan(
              text: textDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final tooltipWidth = textPainter.width + 16;
      final tooltipHeight = textPainter.height + 12;

      var tooltipX = pos.dx - tooltipWidth / 2;
      if (tooltipX < 0) tooltipX = 4;
      if (tooltipX + tooltipWidth > size.width) {
        tooltipX = size.width - tooltipWidth - 4;
      }

      // Draw tooltip above or below point
      var tooltipY = pos.dy - tooltipHeight - 12;
      if (tooltipY < 0) tooltipY = pos.dy + 12;

      final tooltipRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
        const Radius.circular(10),
      );

      canvas
        ..drawRRect(
          tooltipRRect,
          Paint()
            ..color = color
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        )
        ..drawRRect(tooltipRRect, Paint()..color = color);

      textPainter.paint(canvas, Offset(tooltipX + 8, tooltipY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) =>
      oldDelegate.dataPoints != dataPoints;
}

// ─── BMI ────────────────────────────────────────────────────────────────────

class _BMICard extends StatelessWidget {
  const _BMICard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainingState = context.watch<TrainingBloc>().state;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        double? bmi;
        var category = 'N/A';
        var categoryColor = theme.colorScheme.outline;

        final user = state.maybeWhen(
          authenticated: (u) => u,
          orElse: () => null,
        );

        final latestWeight = trainingState is TrainingLoaded &&
                trainingState.bodyWeightLogs.isNotEmpty
            ? trainingState.bodyWeightLogs.first.weight
            : user?.weight;

        if (user != null && latestWeight != null && user.height != null) {
          final hMetri = user.height! / 100;
          final calculatedBmi = latestWeight / (hMetri * hMetri);
          bmi = calculatedBmi;

          if (calculatedBmi < 18.5) {
            category = 'UNDERWEIGHT';
            categoryColor = Colors.lightBlue;
          } else if (calculatedBmi < 25) {
            category = 'NORMAL';
            categoryColor = theme.colorScheme.tertiary;
          } else if (calculatedBmi < 30) {
            category = 'OVERWEIGHT';
            categoryColor = Colors.orange;
          } else {
            category = 'OBESE';
            categoryColor = Colors.red;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_search, color: categoryColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indice BMI',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'BODY MASS INDEX',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bmi != null ? bmi.toStringAsFixed(1) : '--',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: categoryColor,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── CARDIO HISTORY ────────────────────────────────────────────────────────

class _CardioHistorySection extends StatelessWidget {
  const _CardioHistorySection({required this.state});
  final TrainingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var sessions = state is TrainingLoaded
        ? (state as TrainingLoaded).cardioSessions
        : <CardioSessionEntity>[];

    // Sort by date newest first
    sessions = List<CardioSessionEntity>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final displaySessions = sessions.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        colors: [Color(0xFFFF9494), Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'RECENTI CARDIO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              if (sessions.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/analytics/cardio-history'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GUARDA TUTTE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Nessuna sessione registrata',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            )
          else
            ...displaySessions
                .map((session) => _CompactCardioCard(session: session)),
        ],
      ),
    );
  }
}

class _CompactCardioCard extends StatelessWidget {
  const _CompactCardioCard({required this.session});
  final CardioSessionEntity session;

  String _formatDate(DateTime date) {
    final months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRun = session.type == 'run';
    final accentColor = isRun ? theme.colorScheme.primary : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isRun ? Icons.directions_run : Icons.directions_walk,
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRun ? 'Corsa' : 'Camminata',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    fontSize: 13,
                  ),
                ),
                Text(
                  _formatDate(session.date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.distance.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  fontFamily: 'Lexend',
                ),
              ),
              Text(
                '${session.calories} kcal',
                style: TextStyle(
                  fontSize: 10,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Elimina sessione',
            onPressed: () => _confirmDelete(context),
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elimina sessione'),
        content: const Text(
          'Vuoi eliminare definitivamente questa sessione di cardio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    context.read<TrainingBloc>().add(DeleteCardioSessionEvent(session.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sessione cardio eliminata'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
