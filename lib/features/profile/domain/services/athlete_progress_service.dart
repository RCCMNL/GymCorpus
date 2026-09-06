import 'package:gym_corpus/features/profile/domain/services/achievement_catalog.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_level.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';
import 'package:gym_corpus/features/profile/domain/services/personal_records.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

export 'package:gym_corpus/features/profile/domain/services/achievement_catalog.dart';
export 'package:gym_corpus/features/profile/domain/services/athlete_level.dart';
export 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';
export 'package:gym_corpus/features/profile/domain/services/personal_records.dart';

/// Quello che l'app mostra della carriera dell'atleta: livello, trofei,
/// primati.
class AthleteProgress {
  const AthleteProgress({
    required this.xp,
    required this.level,
    required this.levelTitle,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.achievements,
    required this.records,
  });

  factory AthleteProgress.empty() => const AthleteProgress(
    xp: 0,
    level: 1,
    levelTitle: 'Recluta',
    currentLevelXp: 0,
    nextLevelXp: 500,
    achievements: [],
    records: [],
  );

  final int xp;
  final int level;
  final String levelTitle;
  final int currentLevelXp;
  final int nextLevelXp;
  final List<AchievementProgress> achievements;
  final List<PersonalRecord> records;

  int get unlockedAchievements =>
      achievements.where((achievement) => achievement.isUnlocked).length;

  double get levelRatio => nextLevelXp == 0
      ? 1
      : (currentLevelXp / nextLevelXp).clamp(0, 1).toDouble();
}

/// Mette insieme i tre calcoli sulla carriera dell'atleta.
///
/// Ognuno vive per conto suo ed e' verificabile da solo: [AthleteMetrics]
/// legge lo storico una volta e ne ricava i numeri, [AchievementCatalog]
/// confronta i trofei con quei numeri, [AthleteLevel] ne ricava gli XP e
/// [PersonalRecords] li traduce in schede. Qui resta solo l'ordine in cui
/// si chiamano.
class AthleteProgressService {
  const AthleteProgressService._();

  /// I trofei dell'app, per chi vuole l'elenco senza calcolare nulla.
  static const definitions = AchievementCatalog.definitions;

  static AthleteProgress calculate({
    required List<WorkoutSessionEntity> workoutSessions,
    required List<WorkoutSetEntity> workoutSets,
    required List<CardioSessionEntity> cardioSessions,
    required List<ExerciseEntity> exercises,
  }) {
    final metrics = AthleteMetrics.from(
      workoutSessions: workoutSessions,
      workoutSets: workoutSets,
      cardioSessions: cardioSessions,
      exercises: exercises,
    );
    final achievements = AchievementCatalog.measure(metrics);
    final level = AthleteLevel.from(
      metrics: metrics,
      achievements: achievements,
    );

    return AthleteProgress(
      xp: level.xp,
      level: level.level,
      levelTitle: level.title,
      currentLevelXp: level.currentLevelXp,
      nextLevelXp: level.nextLevelXp,
      achievements: achievements,
      records: PersonalRecords.from(metrics),
    );
  }
}
