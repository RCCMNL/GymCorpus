import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/skeleton.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_history_group.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_history_header.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class CardioHistoryScreen extends StatefulWidget {
  const CardioHistoryScreen({super.key});

  @override
  State<CardioHistoryScreen> createState() => _CardioHistoryScreenState();
}

class _CardioHistoryScreenState extends State<CardioHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrainingBloc>().add(LoadCardioSessionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            if (state is TrainingError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppPalette.coral,
                        size: 46,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is! TrainingLoaded) {
              return const SkeletonList(rows: 6);
            }

            final sessions = List<CardioSessionEntity>.from(
              state.cardioSessions,
            )..sort((a, b) => b.date.compareTo(a.date));

            if (sessions.isEmpty) {
              return EmptyCardioHistoryView(theme: theme);
            }

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final recentThreshold = today.subtract(const Duration(days: 7));

            final recentSessions = sessions
                .where((session) => session.date.isAfter(recentThreshold))
                .toList();
            final olderSessions = sessions
                .where(
                  (session) =>
                      session.date.isBefore(recentThreshold) ||
                      session.date.isAtSameMomentAs(recentThreshold),
                )
                .toList();

            final totalDistance = sessions.fold<double>(
              0,
              (sum, session) => sum + session.distance,
            );
            final totalCalories = sessions.fold<int>(
              0,
              (sum, session) => sum + session.calories,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              children: [
                CardioHistoryOverview(
                  totalSessions: sessions.length,
                  totalDistance: totalDistance,
                  totalCalories: totalCalories,
                ),
                const SizedBox(height: 24),
                if (recentSessions.isNotEmpty) ...[
                  CardioHistoryGroup(
                    title: 'RECENTI',
                    subtitle: 'Ultimi 7 giorni',
                    accentColor: theme.colorScheme.primary,
                    sessions: recentSessions,
                  ),
                  const SizedBox(height: 20),
                ],
                if (olderSessions.isNotEmpty)
                  CardioHistoryGroup(
                    title: 'PRECEDENTI',
                    subtitle: 'Archivio sessioni',
                    accentColor: theme.colorScheme.tertiary,
                    sessions: olderSessions,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
