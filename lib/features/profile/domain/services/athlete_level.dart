import 'package:gym_corpus/features/profile/domain/services/achievement_catalog.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';

/// Esperienza accumulata e livello raggiunto.
///
/// Gli XP arrivano da tre parti che qui restano distinte e leggibili: le
/// attivita' svolte, la rarita' dei trofei sbloccati e il bonus per aver
/// chiuso una serie intera.
class AthleteLevel {
  const AthleteLevel({
    required this.xp,
    required this.level,
    required this.title,
    required this.currentLevelXp,
    required this.nextLevelXp,
  });

  factory AthleteLevel.from({
    required AthleteMetrics metrics,
    required List<AchievementProgress> achievements,
  }) {
    final xp =
        (_activityXp(metrics) +
                _trophyXp(achievements) +
                _completedSeriesXp(achievements))
            .round();

    var level = 1;
    var remaining = xp;
    var required = _xpForLevel(level);

    while (remaining >= required) {
      remaining -= required;
      level++;
      required = _xpForLevel(level);
    }

    return AthleteLevel(
      xp: xp,
      level: level,
      title: titleFor(level),
      currentLevelXp: remaining,
      nextLevelXp: required,
    );
  }

  static const start = AthleteLevel(
    xp: 0,
    level: 1,
    title: 'Recluta',
    currentLevelXp: 0,
    nextLevelXp: 500,
  );

  static const _seriesBonusXp = 500;

  final int xp;
  final int level;
  final String title;

  /// XP gia' accumulati dentro il livello corrente.
  final int currentLevelXp;

  /// XP che il livello corrente richiede per passare al successivo.
  final int nextLevelXp;

  double get ratio =>
      nextLevelXp == 0 ? 1 : (currentLevelXp / nextLevelXp).clamp(0, 1);

  /// Il grado che l'app mostra accanto al livello.
  static String titleFor(int level) {
    if (level >= 61) return 'Leggenda';
    if (level >= 31) return 'Elite';
    if (level >= 11) return 'Atleta';
    return 'Recluta';
  }

  /// Soglia del livello [level]: 500 XP, poi 250 in piu' a ogni livello.
  static int _xpForLevel(int level) => 500 + (level - 1) * 250;

  static double _activityXp(AthleteMetrics metrics) {
    return (metrics.completedWorkouts * 100) +
        (metrics.totalSets * 5) +
        (metrics.cardioSessions * 50) +
        metrics.cardioMinutes +
        (metrics.cardioKilometers * 10) +
        (metrics.totalVolume / 200); // 1 XP ogni 200 kg sollevati
  }

  static double _trophyXp(List<AchievementProgress> achievements) {
    var xp = 0.0;
    for (final achievement in achievements) {
      if (!achievement.isUnlocked) continue;
      xp += switch (achievement.definition.rarity) {
        AchievementRarity.bronze => 50,
        AchievementRarity.silver => 150,
        AchievementRarity.gold => 400,
        AchievementRarity.platinum => 1000,
      };
    }
    return xp;
  }

  /// Bonus per ogni serie di piu' trofei sbloccata al completo.
  static double _completedSeriesXp(List<AchievementProgress> achievements) {
    final bySeries = <String, List<AchievementProgress>>{};
    for (final achievement in achievements) {
      bySeries
          .putIfAbsent(achievement.definition.groupId, () => [])
          .add(achievement);
    }

    var xp = 0.0;
    for (final series in bySeries.values) {
      if (series.length > 1 && series.every((a) => a.isUnlocked)) {
        xp += _seriesBonusXp;
      }
    }
    return xp;
  }
}
