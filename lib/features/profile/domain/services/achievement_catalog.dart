import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';

/// Le famiglie in cui la bacheca raggruppa i trofei.
enum AchievementCategory {
  consistency,
  performance,
  cardio,
  variety,
  specialization,
  streak,
}

/// Quanto vale un trofeo: decide colore sulla bacheca e XP bonus.
enum AchievementRarity { bronze, silver, gold, platinum }

/// Un trofeo del catalogo: cosa chiede, quanto chiede e cosa misura.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.metric,
    required this.groupId,
    required this.tier,
    required this.title,
    required this.description,
    required this.category,
    required this.rarity,
    required this.target,
  });

  final String id;

  /// La grandezza dello storico che questo trofeo guarda.
  ///
  /// Dichiararla qui e' cio' che tiene il catalogo indipendente dal calcolo:
  /// aggiungere un trofeo e' aggiungere una voce a questa lista, non anche un
  /// ramo a uno `switch` da qualche altra parte.
  final AthleteMetric metric;

  /// Identifica la serie: i trofei con lo stesso [groupId] stanno insieme
  /// sulla bacheca e, se completati tutti, valgono un bonus XP.
  final String groupId;
  final int tier;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final double target;
}

/// Un trofeo con quanto ne ha fatto l'utente finora.
class AchievementProgress {
  const AchievementProgress({required this.definition, required this.current});

  final AchievementDefinition definition;
  final double current;

  bool get isUnlocked => current >= definition.target;
  double get ratio => (current / definition.target).clamp(0, 1).toDouble();
}

/// L'elenco dei trofei dell'app.
class AchievementCatalog {
  const AchievementCatalog._();

  static const definitions = [
    // --- CONSISTENZA ---
    AchievementDefinition(
      id: 'veterano_10',
      metric: AthleteMetric.completedWorkouts,
      groupId: 'veterano',
      tier: 1,
      title: 'Veterano I',
      description: 'Completa 10 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'veterano_50',
      metric: AthleteMetric.completedWorkouts,
      groupId: 'veterano',
      tier: 2,
      title: 'Veterano II',
      description: 'Completa 50 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.silver,
      target: 50,
    ),
    AchievementDefinition(
      id: 'veterano_100',
      metric: AthleteMetric.completedWorkouts,
      groupId: 'veterano',
      tier: 3,
      title: 'Veterano III',
      description: 'Completa 100 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.gold,
      target: 100,
    ),
    AchievementDefinition(
      id: 'veterano_500',
      metric: AthleteMetric.completedWorkouts,
      groupId: 'veterano',
      tier: 4,
      title: 'Veterano IV',
      description: 'Completa 500 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.platinum,
      target: 500,
    ),

    // --- VOLUME ---
    AchievementDefinition(
      id: 'volume_5k',
      metric: AthleteMetric.bestSessionVolume,
      groupId: 'volume',
      tier: 1,
      title: 'Peso Piuma',
      description: 'Raggiungi 5.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.bronze,
      target: 5000,
    ),
    AchievementDefinition(
      id: 'volume_15k',
      metric: AthleteMetric.bestSessionVolume,
      groupId: 'volume',
      tier: 2,
      title: 'Volume King',
      description: 'Raggiungi 15.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.silver,
      target: 15000,
    ),
    AchievementDefinition(
      id: 'volume_30k',
      metric: AthleteMetric.bestSessionVolume,
      groupId: 'volume',
      tier: 3,
      title: 'Titano del Volume',
      description: 'Raggiungi 30.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 30000,
    ),
    AchievementDefinition(
      id: 'volume_50k',
      metric: AthleteMetric.bestSessionVolume,
      groupId: 'volume',
      tier: 4,
      title: 'Divinità del Volume',
      description: 'Raggiungi 50.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.platinum,
      target: 50000,
    ),

    // --- PESO MASSIMO ---
    AchievementDefinition(
      id: 'heavy_80',
      metric: AthleteMetric.heaviestWeight,
      groupId: 'heavy',
      tier: 1,
      title: 'Carico Serio',
      description: 'Registra un set da almeno 80 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.bronze,
      target: 80,
    ),
    AchievementDefinition(
      id: 'heavy_120',
      metric: AthleteMetric.heaviestWeight,
      groupId: 'heavy',
      tier: 2,
      title: 'Carico a Tre Cifre',
      description: 'Registra un set da almeno 120 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.silver,
      target: 120,
    ),
    AchievementDefinition(
      id: 'heavy_180',
      metric: AthleteMetric.heaviestWeight,
      groupId: 'heavy',
      tier: 3,
      title: 'Forza Bruta',
      description: 'Registra un set da almeno 180 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 180,
    ),
    AchievementDefinition(
      id: 'heavy_250',
      metric: AthleteMetric.heaviestWeight,
      groupId: 'heavy',
      tier: 4,
      title: 'Inarrestabile',
      description: 'Registra un set da almeno 250 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.platinum,
      target: 250,
    ),

    // --- CARDIO DISTANZA ---
    AchievementDefinition(
      id: 'dist_10',
      metric: AthleteMetric.cardioKilometers,
      groupId: 'distance',
      tier: 1,
      title: 'Maratoneta Jr',
      description: 'Percorri 10 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'dist_50',
      metric: AthleteMetric.cardioKilometers,
      groupId: 'distance',
      tier: 2,
      title: 'Globetrotter',
      description: 'Percorri 50 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.silver,
      target: 50,
    ),
    AchievementDefinition(
      id: 'dist_200',
      metric: AthleteMetric.cardioKilometers,
      groupId: 'distance',
      tier: 3,
      title: 'Viaggiatore',
      description: 'Percorri 200 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.gold,
      target: 200,
    ),
    AchievementDefinition(
      id: 'dist_1000',
      metric: AthleteMetric.cardioKilometers,
      groupId: 'distance',
      tier: 4,
      title: 'Odissea Cardio',
      description: 'Percorri 1000 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.platinum,
      target: 1000,
    ),

    // --- VARIETÀ ---
    AchievementDefinition(
      id: 'variety_10',
      metric: AthleteMetric.exercisesTried,
      groupId: 'variety',
      tier: 1,
      title: 'Sperimentatore',
      description: 'Prova 10 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'variety_30',
      metric: AthleteMetric.exercisesTried,
      groupId: 'variety',
      tier: 2,
      title: 'Esploratore',
      description: 'Prova 30 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.silver,
      target: 30,
    ),
    AchievementDefinition(
      id: 'variety_60',
      metric: AthleteMetric.exercisesTried,
      groupId: 'variety',
      tier: 3,
      title: 'Collezionista',
      description: 'Prova 60 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.gold,
      target: 60,
    ),
    AchievementDefinition(
      id: 'variety_100',
      metric: AthleteMetric.exercisesTried,
      groupId: 'variety',
      tier: 4,
      title: 'Maestro del Catalogo',
      description: 'Prova 100 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.platinum,
      target: 100,
    ),

    // --- STREAKS ---
    AchievementDefinition(
      id: 'streak_4w',
      metric: AthleteMetric.consecutiveWeeks,
      groupId: 'streak',
      tier: 1,
      title: 'Mese di Fuoco',
      description: 'Allenati per 4 settimane consecutive.',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.silver,
      target: 4,
    ),
    AchievementDefinition(
      id: 'streak_12w',
      metric: AthleteMetric.consecutiveWeeks,
      groupId: 'streak',
      tier: 2,
      title: 'Inarrestabile',
      description: 'Allenati per 12 settimane consecutive.',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.gold,
      target: 12,
    ),

    // --- SPECIALIZZAZIONE ---
    AchievementDefinition(
      id: 'specialist_legs',
      metric: AthleteMetric.legDaySessions,
      groupId: 'specialist',
      tier: 1,
      title: 'Leg Day Lover',
      description: 'Completa 20 sessioni focalizzate sulle gambe.',
      category: AchievementCategory.specialization,
      rarity: AchievementRarity.silver,
      target: 20,
    ),
    AchievementDefinition(
      id: 'specialist_push',
      metric: AthleteMetric.pushDaySessions,
      groupId: 'specialist',
      tier: 2,
      title: 'Push Master',
      description: 'Completa 20 sessioni con focus Petto/Spalle/Tricipiti.',
      category: AchievementCategory.specialization,
      rarity: AchievementRarity.silver,
      target: 20,
    ),

    // --- LIFESTYLE ---
    AchievementDefinition(
      id: 'early_bird_10',
      metric: AthleteMetric.earlyMorningSessions,
      groupId: 'lifestyle',
      tier: 1,
      title: 'Early Bird',
      description: 'Completa 10 allenamenti prima delle 8:00 del mattino.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.silver,
      target: 10,
    ),
    AchievementDefinition(
      id: 'night_owl_10',
      metric: AthleteMetric.lateEveningSessions,
      groupId: 'lifestyle',
      tier: 2,
      title: 'Night Owl',
      description: 'Completa 10 allenamenti dopo le 21:00.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.silver,
      target: 10,
    ),

    // --- MAESTRIA ---
    AchievementDefinition(
      id: 'bench_king_10k',
      metric: AthleteMetric.benchVolume,
      groupId: 'mastery',
      tier: 1,
      title: 'King of the Bench',
      description: 'Solleva 10.000 kg totali di Panca Piana.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 10000,
    ),
    AchievementDefinition(
      id: 'squat_legend_20k',
      metric: AthleteMetric.squatVolume,
      groupId: 'mastery',
      tier: 2,
      title: 'Squat Legend',
      description: 'Solleva 20.000 kg totali di Squat.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 20000,
    ),
    AchievementDefinition(
      id: 'reps_1000_club',
      metric: AthleteMetric.repsOnBestExercise,
      groupId: 'mastery',
      tier: 3,
      title: '1000 Reps Club',
      description:
          'Raggiungi 1000 ripetizioni totali per un singolo esercizio.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.silver,
      target: 1000,
    ),

    // --- INTENSITÀ ---
    AchievementDefinition(
      id: 'speed_demon',
      metric: AthleteMetric.fastPaceReached,
      groupId: 'speed',
      tier: 1,
      title: 'Speed Demon',
      description: 'Corri con un passo medio inferiore a 5:00 min/km.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.gold,
      target: 1, // Flag: 1 if achieved
    ),
    AchievementDefinition(
      id: 'calorie_crusher',
      metric: AthleteMetric.bestSessionCalories,
      groupId: 'performance_session',
      tier: 1,
      title: 'Calorie Crusher',
      description: 'Brucia più di 1000 kcal in una singola sessione cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.platinum,
      target: 1000,
    ),
    AchievementDefinition(
      id: 'iron_marathon',
      metric: AthleteMetric.longestSessionMinutes,
      groupId: 'performance_session',
      tier: 2,
      title: 'Maratoneta di Ferro',
      description: 'Completa una sessione di allenamento di oltre 2 ore.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 120, // Minuti
    ),
  ];

  /// Confronta ogni trofeo del catalogo con le metriche dell'atleta.
  static List<AchievementProgress> measure(AthleteMetrics metrics) {
    return [
      for (final definition in definitions)
        AchievementProgress(
          definition: definition,
          current: metrics.valueOf(definition.metric),
        ),
    ];
  }
}
