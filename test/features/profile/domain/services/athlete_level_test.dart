import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/services/achievement_catalog.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_level.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

AchievementProgress _trophy({
  required AchievementRarity rarity,
  String id = 'trofeo',
  String groupId = 'serie',
  bool unlocked = true,
}) {
  return AchievementProgress(
    definition: AchievementDefinition(
      id: id,
      metric: AthleteMetric.completedWorkouts,
      groupId: groupId,
      tier: 1,
      title: id,
      description: id,
      category: AchievementCategory.consistency,
      rarity: rarity,
      target: 1,
    ),
    current: unlocked ? 1 : 0,
  );
}

AthleteMetrics _metrics({
  List<WorkoutSessionEntity> sessions = const [],
  List<WorkoutSetEntity> sets = const [],
  List<CardioSessionEntity> cardio = const [],
}) {
  return AthleteMetrics.from(
    workoutSessions: sessions,
    workoutSets: sets,
    cardioSessions: cardio,
    exercises: const [],
  );
}

WorkoutSessionEntity _session(int id) {
  return WorkoutSessionEntity(
    id: id,
    date: DateTime(2026, 5, id),
    name: 'Sessione',
    completedAt: DateTime(2026, 5, id),
  );
}

void main() {
  group('AthleteLevel.from', () {
    test('senza attivita si resta recluta al primo livello', () {
      final level = AthleteLevel.from(
        metrics: AthleteMetrics.empty,
        achievements: const [],
      );

      expect(level.xp, 0);
      expect(level.level, 1);
      expect(level.title, 'Recluta');
      expect(level.currentLevelXp, 0);
      expect(level.nextLevelXp, 500);
    });

    test('ogni allenamento completato vale cento xp', () {
      final level = AthleteLevel.from(
        metrics: _metrics(sessions: [_session(1), _session(2)]),
        achievements: const [],
      );

      expect(level.xp, 200);
    });

    test('una sessione cardio vale cinquanta xp piu distanza e minuti', () {
      final level = AthleteLevel.from(
        metrics: _metrics(
          cardio: [
            CardioSessionEntity(
              id: 1,
              type: 'run',
              distance: 5,
              duration: 1800,
              avgSpeed: 10,
              pace: '06:00',
              calories: 300,
              date: DateTime(2026, 5, 4),
            ),
          ],
        ),
        achievements: const [],
      );

      // 50 per la sessione + 30 minuti + 5 km * 10.
      expect(level.xp, 130);
    });

    test('un trofeo bloccato non porta xp', () {
      final level = AthleteLevel.from(
        metrics: AthleteMetrics.empty,
        achievements: [
          _trophy(rarity: AchievementRarity.platinum, unlocked: false),
        ],
      );

      expect(level.xp, 0);
    });

    test('il bonus di un trofeo cresce con la sua rarita', () {
      int xpFor(AchievementRarity rarity) {
        return AthleteLevel.from(
          metrics: AthleteMetrics.empty,
          achievements: [_trophy(rarity: rarity)],
        ).xp;
      }

      expect(xpFor(AchievementRarity.bronze), 50);
      expect(xpFor(AchievementRarity.silver), 150);
      expect(xpFor(AchievementRarity.gold), 400);
      expect(xpFor(AchievementRarity.platinum), 1000);
    });

    test('completare una serie intera vale cinquecento xp in piu', () {
      final level = AthleteLevel.from(
        metrics: AthleteMetrics.empty,
        achievements: [
          _trophy(rarity: AchievementRarity.bronze, id: 'uno'),
          _trophy(rarity: AchievementRarity.bronze, id: 'due'),
        ],
      );

      expect(level.xp, 50 + 50 + 500);
    });

    test('una serie con un trofeo solo non da il bonus', () {
      final level = AthleteLevel.from(
        metrics: AthleteMetrics.empty,
        achievements: [_trophy(rarity: AchievementRarity.bronze)],
      );

      expect(level.xp, 50);
    });

    test('una serie incompleta non da il bonus', () {
      final level = AthleteLevel.from(
        metrics: AthleteMetrics.empty,
        achievements: [
          _trophy(rarity: AchievementRarity.bronze, id: 'uno'),
          _trophy(rarity: AchievementRarity.bronze, id: 'due', unlocked: false),
        ],
      );

      expect(level.xp, 50);
    });

    test('a cinquecento xp si sale di livello e la soglia cresce', () {
      final level = AthleteLevel.from(
        metrics: _metrics(sessions: [for (var i = 1; i <= 5; i++) _session(i)]),
        achievements: const [],
      );

      expect(level.xp, 500);
      expect(level.level, 2);
      expect(level.currentLevelXp, 0);
      expect(level.nextLevelXp, 750);
    });
  });

  group('AthleteLevel.titleFor', () {
    test('il titolo cambia a undici, trentuno e sessantuno', () {
      expect(AthleteLevel.titleFor(10), 'Recluta');
      expect(AthleteLevel.titleFor(11), 'Atleta');
      expect(AthleteLevel.titleFor(30), 'Atleta');
      expect(AthleteLevel.titleFor(31), 'Elite');
      expect(AthleteLevel.titleFor(60), 'Elite');
      expect(AthleteLevel.titleFor(61), 'Leggenda');
    });
  });
}
