import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/services/achievement_catalog.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

AthleteMetrics _metricsWithWorkouts(int count) {
  return AthleteMetrics.from(
    workoutSessions: const [],
    workoutSets: [
      for (var i = 0; i < count; i++)
        WorkoutSetEntity(
          id: i,
          workoutId: i,
          exerciseId: 1,
          reps: 1,
          weight: 1,
          timestamp: DateTime(2026, 5, 4),
        ),
    ],
    cardioSessions: const [],
    exercises: const [],
  );
}

void main() {
  group('AchievementCatalog', () {
    test('ogni trofeo ha un identificativo unico', () {
      final ids = AchievementCatalog.definitions.map((d) => d.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('i trofei che misurano la stessa cosa alzano l obiettivo', () {
      final byMetric = <AthleteMetric, List<AchievementDefinition>>{};
      for (final definition in AchievementCatalog.definitions) {
        byMetric.putIfAbsent(definition.metric, () => []).add(definition);
      }

      for (final entry in byMetric.entries) {
        final byTier = [...entry.value]
          ..sort((a, b) => a.tier.compareTo(b.tier));
        for (var i = 1; i < byTier.length; i++) {
          expect(
            byTier[i].target,
            greaterThan(byTier[i - 1].target),
            reason: entry.key.name,
          );
        }
      }
    });
  });

  group('AchievementCatalog.measure', () {
    test('assegna a ogni trofeo la metrica che ha dichiarato', () {
      const metrics = AthleteMetrics.empty;

      final measured = AchievementCatalog.measure(metrics);

      expect(measured, hasLength(AchievementCatalog.definitions.length));
      for (final achievement in measured) {
        expect(
          achievement.current,
          metrics.valueOf(achievement.definition.metric),
          reason: achievement.definition.id,
        );
      }
    });

    test('un trofeo scatta quando la metrica raggiunge il suo obiettivo', () {
      final measured = AchievementCatalog.measure(_metricsWithWorkouts(10));

      final raggiunto = measured.firstWhere(
        (a) => a.definition.id == 'veterano_10',
      );
      final successivo = measured.firstWhere(
        (a) => a.definition.id == 'veterano_50',
      );

      expect(raggiunto.isUnlocked, isTrue);
      expect(successivo.isUnlocked, isFalse);
      expect(successivo.ratio, closeTo(0.2, 0.001));
    });
  });
}
