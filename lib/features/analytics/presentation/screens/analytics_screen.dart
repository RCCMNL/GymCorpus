import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/analytics/domain/analytics_formatters.dart';
import 'package:gym_corpus/features/analytics/domain/workout_stats_summary.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/bmi_card.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_history_section.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/daily_steps_section.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/insights_section.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/stat_section.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/weekly_activity_card.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/weight_tracking_card.dart';
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
            var stats = WorkoutStatsSummary.empty;
            var monthStats = WorkoutStatsSummary.empty;
            var currentUnit = 'KG';

            if (state is TrainingLoaded) {
              currentUnit = state.settings['units'] ?? 'KG';
              final logs = state.weightLogs;
              stats = WorkoutStatsSummary.fromLogs(
                logs,
                sessions: state.workoutSessions,
              );

              final now = DateTime.now();
              final monthLogs = logs
                  .where(
                    (e) =>
                        e.timestamp.month == now.month &&
                        e.timestamp.year == now.year,
                  )
                  .toList();
              monthStats = WorkoutStatsSummary.fromLogs(
                monthLogs,
                sessions: state.workoutSessions,
              );
            }
            final isImperial = currentUnit == 'LB';

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
                  InsightsSection(state: state, isImperial: isImperial),
                  const SizedBox(height: 24),

                  // Stats Cards Grid
                  StatSection(
                    title: 'Statistiche Totali',
                    color: theme.colorScheme.primary,
                    stats: [
                      StatItem(
                        icon: Icons.fitness_center,
                        value: stats.sessionsCount.toString(),
                        label: 'Allenamenti',
                      ),
                      StatItem(
                        icon: Icons.schedule,
                        value: formatWorkoutDuration(stats.totalMinutes),
                        label: 'Tempo totale',
                      ),
                      StatItem(
                        icon: Icons.scale,
                        value: isImperial
                            ? formatVolumeLb(stats.totalWeight)
                            : formatVolumeKg(stats.totalWeight),
                        label: 'Volume',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StatSection(
                    title: 'Questo Mese',
                    color: theme.colorScheme.tertiary,
                    stats: [
                      StatItem(
                        icon: Icons.calendar_month,
                        value: monthStats.sessionsCount.toString(),
                        label: 'Allenamenti',
                      ),
                      StatItem(
                        icon: Icons.timer,
                        value: formatWorkoutDuration(monthStats.totalMinutes),
                        label: 'Tempo trascorso',
                      ),
                      StatItem(
                        icon: Icons.trending_up,
                        value: isImperial
                            ? formatVolumeLb(monthStats.totalWeight)
                            : formatVolumeKg(monthStats.totalWeight),
                        label: 'Volume',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // This Week Activity Card
                  WeeklyActivityCard(
                    weightLogs: state is TrainingLoaded ? state.weightLogs : [],
                  ),

                  const SizedBox(height: 24),

                  // Weight Tracking Card
                  const WeightTrackingCard(),

                  const SizedBox(height: 24),

                  // BMI Card
                  const BMICard(),

                  const SizedBox(height: 24),

                  // Daily Steps & Activity Section
                  const DailyStepsSection(),

                  const SizedBox(height: 24),

                  // Cardio History Section
                  CardioHistorySection(state: state),

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
