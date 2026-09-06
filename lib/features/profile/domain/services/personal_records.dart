import 'package:gym_corpus/features/profile/domain/services/achievement_catalog.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';

/// Un primato dell'atleta, gia' pronto da mostrare in scheda.
class PersonalRecord {
  const PersonalRecord({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.category,
  });

  final String title;
  final String value;
  final String subtitle;
  final AchievementCategory category;
}

/// Traduce le metriche nei primati mostrati da RecordsScreen.
///
/// Qui vive solo la formattazione: quale numero e' un primato lo decide
/// [AthleteMetrics], che non conosce ne' unita' di misura ne' testi.
class PersonalRecords {
  const PersonalRecords._();

  static List<PersonalRecord> from(AthleteMetrics metrics) {
    final hasSets = metrics.heaviestSetExerciseId != null;
    final hasCardio = metrics.cardioSessions > 0;

    return [
      PersonalRecord(
        title: 'Allenamenti completati',
        value: metrics.completedWorkouts.toString(),
        subtitle: 'Sessioni registrate',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Volume massimo',
        value: '${metrics.bestSessionVolume.round()} kg',
        subtitle: 'Miglior sessione',
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Set piu pesante',
        value: hasSets
            ? '${metrics.heaviestWeight.toStringAsFixed(1)} kg'
            : '-',
        subtitle: exerciseLabel(metrics, metrics.heaviestSetExerciseId),
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: '1RM stimato',
        value: metrics.bestOneRepMaxExerciseId == null
            ? '-'
            : '${metrics.bestOneRepMax.toStringAsFixed(1)} kg',
        subtitle: exerciseLabel(metrics, metrics.bestOneRepMaxExerciseId),
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Distanza cardio',
        value: hasCardio
            ? '${metrics.longestCardioDistance.toStringAsFixed(2)} km'
            : '-',
        subtitle: hasCardio ? 'Sessione piu lunga' : 'Nessuna sessione',
        category: AchievementCategory.cardio,
      ),
      PersonalRecord(
        title: 'Velocita media',
        value: hasCardio
            ? '${metrics.fastestCardioSpeed.toStringAsFixed(1)} km/h'
            : '-',
        subtitle: hasCardio ? 'Miglior media' : 'Nessuna sessione',
        category: AchievementCategory.cardio,
      ),
      PersonalRecord(
        title: 'Esercizi provati',
        value: metrics.exercisesTried.toString(),
        subtitle: 'Varieta nel catalogo',
        category: AchievementCategory.variety,
      ),
      PersonalRecord(
        title: 'Volume Totale',
        value: '${formatLargeNumber(metrics.totalVolume)} kg',
        subtitle: 'Lifetime record',
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Ripetizioni Totali',
        value: formatLargeNumber(metrics.totalReps.toDouble()),
        subtitle: 'Ogni ripetizione conta',
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Set Totali',
        value: formatLargeNumber(metrics.totalSets.toDouble()),
        subtitle: 'Serie completate',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Tempo allenamento',
        value: '${(metrics.totalWorkoutSeconds / 3600).toStringAsFixed(1)} h',
        subtitle: 'Tempo totale sotto sforzo',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Settimana Record',
        value: '${metrics.bestWeeklyWorkouts} sessioni',
        subtitle: 'Massimo in 7 giorni',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Esercizio Preferito',
        value: metrics.favoriteExerciseId == null
            ? 'Nessuno'
            : metrics.exerciseNames[metrics.favoriteExerciseId] ?? 'Nessuno',
        subtitle: 'Piu serie eseguite',
        category: AchievementCategory.variety,
      ),
      PersonalRecord(
        title: 'Cardio Record (Tempo)',
        value: formatDuration(metrics.longestCardioSeconds),
        subtitle: 'Sessione piu lunga',
        category: AchievementCategory.cardio,
      ),
      PersonalRecord(
        title: 'Calorie Record',
        value: '${metrics.bestSessionCalories} kcal',
        subtitle: 'Massimo bruciato',
        category: AchievementCategory.cardio,
      ),
    ];
  }

  /// Il nome dell'esercizio dietro un primato, o perche' non c'e'.
  static String exerciseLabel(AthleteMetrics metrics, int? exerciseId) {
    if (exerciseId == null) return 'Nessun set registrato';
    return metrics.exerciseNames[exerciseId] ?? 'Esercizio registrato';
  }

  /// `1h 15m` oppure `45m`.
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Accorcia i numeri da vetrina: `20.0k`, `2.00M`.
  static String formatLargeNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 10000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.round().toString();
  }
}
