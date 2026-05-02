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

            // Raggruppamento per GroupId
            final groupedAchievements = <String, List<AchievementProgress>>{};
            for (final achievement in progress.achievements) {
              groupedAchievements
                  .putIfAbsent(achievement.definition.groupId, () => [])
                  .add(achievement);
            }

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
                  '${progress.unlockedAchievements}/${progress.achievements.length} obiettivi completati',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20),
                ...groupedAchievements.values.map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _GroupedAchievementCard(
                      group: group,
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

class _GroupedAchievementCard extends StatelessWidget {
  const _GroupedAchievementCard({
    required this.group,
    required this.theme,
  });

  final List<AchievementProgress> group;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Ordina per tier
    final sortedGroup = [...group]..sort((a, b) => a.definition.tier.compareTo(b.definition.tier));
    
    final highestUnlocked = sortedGroup.where((a) => a.isUnlocked).lastOrNull;
    final nextToUnlock = sortedGroup.where((a) => !a.isUnlocked).firstOrNull;
    
    // Se tutti sono sbloccati, mostra l'ultimo. Se nessuno è sbloccato, mostra il primo.
    final displayAchievement = nextToUnlock ?? highestUnlocked ?? sortedGroup.first;
    final isMastered = nextToUnlock == null;
    
    final color = _categoryColor(displayAchievement.definition.category, theme);
    final rarityColor = highestUnlocked != null 
        ? _rarityColor(highestUnlocked.definition.rarity)
        : theme.colorScheme.outline.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMastered 
              ? Colors.amber.withValues(alpha: 0.5) 
              : rarityColor.withValues(alpha: 0.2),
          width: isMastered ? 2 : 1,
        ),
        boxShadow: isMastered ? [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Icon(
                  _categoryIcon(displayAchievement.definition.category),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayAchievement.definition.title.split(' ').first, // Nome del gruppo
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: sortedGroup.map((a) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _TierIndicator(
                          rarity: a.definition.rarity,
                          isUnlocked: a.isUnlocked,
                          theme: theme,
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              if (isMastered)
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isMastered 
              ? 'Sfida Completata! Hai raggiunto il grado massimo.'
              : displayAchievement.definition.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          if (!isMastered) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: displayAchievement.ratio,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso ${displayAchievement.definition.title}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  '${_formatValue(displayAchievement.current)} / ${_formatValue(displayAchievement.definition.target)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatValue(double v) {
    if (v >= 1000000) return '${(v/1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v/1000).toStringAsFixed(1)}k';
    return v.round().toString();
  }
}

class _TierIndicator extends StatelessWidget {
  const _TierIndicator({
    required this.rarity,
    required this.isUnlocked,
    required this.theme,
  });

  final AchievementRarity rarity;
  final bool isUnlocked;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(rarity);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUnlocked ? color : theme.colorScheme.outline.withValues(alpha: 0.2),
        boxShadow: isUnlocked ? [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4)
        ] : null,
      ),
    );
  }
}

Color _rarityColor(AchievementRarity rarity) {
  return switch (rarity) {
    AchievementRarity.bronze => const Color(0xFFCD7F32),
    AchievementRarity.silver => const Color(0xFFC0C0C0),
    AchievementRarity.gold => const Color(0xFFFFD700),
    AchievementRarity.platinum => const Color(0xFFE5E4E2),
  };
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
