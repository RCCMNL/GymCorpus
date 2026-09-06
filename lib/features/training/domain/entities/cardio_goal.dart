import 'package:equatable/equatable.dart';

/// Cosa si vuole raggiungere in una sessione cardio.
enum CardioGoalType { distance, duration, calories }

/// Obiettivo scelto prima di partire.
///
/// Non viene salvato con la sessione: serve durante l'allenamento per la
/// barra di avanzamento e per l'avviso al traguardo.
class CardioGoal extends Equatable {
  const CardioGoal({required this.type, required this.value});

  final CardioGoalType type;

  /// Chilometri, minuti o calorie a seconda del tipo.
  final double value;

  double _current({
    required double distanceKm,
    required int seconds,
    required int calories,
  }) {
    switch (type) {
      case CardioGoalType.distance:
        return distanceKm;
      case CardioGoalType.duration:
        return seconds / 60;
      case CardioGoalType.calories:
        return calories.toDouble();
    }
  }

  /// Avanzamento tra 0 e 1: oltre il traguardo la barra resta piena.
  double progress({
    required double distanceKm,
    required int seconds,
    required int calories,
  }) {
    if (value <= 0) return 0;

    final current = _current(
      distanceKm: distanceKm,
      seconds: seconds,
      calories: calories,
    );
    return (current / value).clamp(0.0, 1.0);
  }

  bool isReached({
    required double distanceKm,
    required int seconds,
    required int calories,
  }) {
    if (value <= 0) return false;

    return _current(
          distanceKm: distanceKm,
          seconds: seconds,
          calories: calories,
        ) >=
        value;
  }

  String get label {
    final rounded = value.roundToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);

    switch (type) {
      case CardioGoalType.distance:
        return '$rounded km';
      case CardioGoalType.duration:
        return '$rounded min';
      case CardioGoalType.calories:
        return '$rounded kcal';
    }
  }

  @override
  List<Object?> get props => [type, value];
}

/// Parametri con cui si apre il tracker cardio.
///
/// La rotta accettava una semplice stringa con il tipo di attivita': quel
/// formato resta leggibile, cosi' una navigazione salvata da una versione
/// precedente continua ad aprire la schermata giusta.
class CardioLaunchArgs extends Equatable {
  const CardioLaunchArgs({required this.type, this.goal});

  final String type;
  final CardioGoal? goal;

  @override
  List<Object?> get props => [type, goal];
}
