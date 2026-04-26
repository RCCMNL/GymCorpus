import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_progress_service.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class TrophyBoardScreen extends StatefulWidget {
  const TrophyBoardScreen({super.key});

  @override
  State<TrophyBoardScreen> createState() => _TrophyBoardScreenState();
}

class _TrophyBoardScreenState extends State<TrophyBoardScreen> {
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
                _LevelHero(progress: progress, theme: theme),
                const SizedBox(height: 24),
                Text(
                  'Bacheca Trofei',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${progress.unlockedAchievements}/${progress.achievements.length} trofei sbloccati',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20),
                ...progress.achievements.map(
                  (achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementTile(
                      achievement: achievement,
                      theme: theme,
                    ),
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

class _LevelHero extends StatelessWidget {
  const _LevelHero({
    required this.progress,
    required this.theme,
  });

  final AthleteProgress progress;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.16),
            theme.colorScheme.tertiary.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.14),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Livello ${progress.level}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      progress.levelTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${progress.xp} XP',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.levelRatio,
              minHeight: 8,
              backgroundColor:
                  theme.colorScheme.surface.withValues(alpha: 0.45),
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.tertiary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.currentLevelXp}/${progress.nextLevelXp} XP al prossimo livello',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.theme,
  });

  final AchievementProgress achievement;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(achievement.definition.category, theme);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.35)
              : theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: isUnlocked ? 0.16 : 0.08),
            ),
            child: Icon(
              isUnlocked
                  ? _categoryIcon(achievement.definition.category)
                  : Icons.lock_rounded,
              color: isUnlocked ? color : theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.definition.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isUnlocked ? null : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                    _RarityPill(
                      rarity: achievement.definition.rarity,
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.definition.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: achievement.ratio,
                    minHeight: 6,
                    backgroundColor:
                        theme.colorScheme.outline.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${achievement.current.toStringAsFixed(achievement.current % 1 == 0 ? 0 : 1)} / ${achievement.definition.target.toStringAsFixed(achievement.definition.target % 1 == 0 ? 0 : 1)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityPill extends StatelessWidget {
  const _RarityPill({
    required this.rarity,
    required this.theme,
  });

  final AchievementRarity rarity;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = switch (rarity) {
      AchievementRarity.bronze => 'Bronzo',
      AchievementRarity.silver => 'Argento',
      AchievementRarity.gold => 'Oro',
      AchievementRarity.platinum => 'Platino',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
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
  };
}

Color _categoryColor(AchievementCategory category, ThemeData theme) {
  return switch (category) {
    AchievementCategory.consistency => Colors.orangeAccent,
    AchievementCategory.performance => theme.colorScheme.primary,
    AchievementCategory.cardio => theme.colorScheme.tertiary,
    AchievementCategory.variety => Colors.tealAccent,
  };
}
