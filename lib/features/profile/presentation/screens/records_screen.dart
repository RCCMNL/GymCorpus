import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_progress_service.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<TrainingBloc>();
    bloc
      ..add(LoadWeightLogsEvent())
      ..add(LoadWorkoutSessionsEvent())
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
            final progress = state is TrainingLoaded
                ? AthleteProgressService.calculate(
                    workoutSessions: state.workoutSessions,
                    workoutSets: state.weightLogs,
                    cardioSessions: state.cardioSessions,
                    exercises: state.exercises,
                  )
                : AthleteProgress.empty();

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Text(
                  'Record',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'I tuoi migliori risultati da workout e cardio.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),
                ...progress.records.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecordTile(record: record, theme: theme),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.theme,
  });

  final PersonalRecord record;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(record.category, theme);

    final isNumeric = RegExp(r'^\d').hasMatch(record.value) || record.value == '-';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(_categoryIcon(record.category), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  record.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (!isNumeric)
                  Text(
                    record.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  )
                else
                  Text(
                    record.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                if (!isNumeric)
                  const SizedBox(height: 2),
                if (!isNumeric)
                  Text(
                    record.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          if (isNumeric) ...[
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.4,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  record.value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

IconData _categoryIcon(AchievementCategory category) {
  return switch (category) {
    AchievementCategory.consistency => Icons.local_fire_department_rounded,
    AchievementCategory.performance => Icons.fitness_center_rounded,
    AchievementCategory.cardio => Icons.directions_run_rounded,
    AchievementCategory.variety => Icons.auto_awesome_mosaic_rounded,
    AchievementCategory.specialization => Icons.ads_click_rounded,
    AchievementCategory.streak => Icons.bolt_rounded,
  };
}

Color _categoryColor(AchievementCategory category, ThemeData theme) {
  return switch (category) {
    AchievementCategory.consistency => Colors.orangeAccent,
    AchievementCategory.performance => theme.colorScheme.primary,
    AchievementCategory.cardio => theme.colorScheme.tertiary,
    AchievementCategory.variety => Colors.tealAccent,
    AchievementCategory.specialization => Colors.purpleAccent,
    AchievementCategory.streak => Colors.yellowAccent,
  };
}
