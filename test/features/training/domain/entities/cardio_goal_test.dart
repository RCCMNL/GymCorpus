import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';

/// L'obiettivo non viene salvato con la sessione: vive solo durante
/// l'allenamento, per la barra di avanzamento e per l'avviso al traguardo.
void main() {
  group('avanzamento', () {
    test('un obiettivo di distanza si misura sui chilometri percorsi', () {
      const goal = CardioGoal(type: CardioGoalType.distance, value: 5);

      expect(
        goal.progress(distanceKm: 2.5, seconds: 0, calories: 0),
        closeTo(0.5, 0.001),
      );
    });

    test('un obiettivo di tempo si misura sui minuti trascorsi', () {
      const goal = CardioGoal(type: CardioGoalType.duration, value: 30);

      expect(
        goal.progress(distanceKm: 0, seconds: 900, calories: 0),
        closeTo(0.5, 0.001),
      );
    });

    test('un obiettivo di calorie si misura sulle calorie bruciate', () {
      const goal = CardioGoal(type: CardioGoalType.calories, value: 300);

      expect(
        goal.progress(distanceKm: 0, seconds: 0, calories: 150),
        closeTo(0.5, 0.001),
      );
    });

    test('l avanzamento non supera il pieno', () {
      const goal = CardioGoal(type: CardioGoalType.distance, value: 5);

      expect(goal.progress(distanceKm: 12, seconds: 0, calories: 0), 1.0);
    });
  });

  group('traguardo', () {
    test('l obiettivo e raggiunto quando il valore e coperto', () {
      const goal = CardioGoal(type: CardioGoalType.distance, value: 5);

      expect(goal.isReached(distanceKm: 4.9, seconds: 0, calories: 0), isFalse);
      expect(goal.isReached(distanceKm: 5, seconds: 0, calories: 0), isTrue);
    });
  });

  group('etichetta', () {
    test('i valori interi non mostrano decimali inutili', () {
      expect(
        const CardioGoal(type: CardioGoalType.distance, value: 5).label,
        '5 km',
      );
      expect(
        const CardioGoal(type: CardioGoalType.duration, value: 30).label,
        '30 min',
      );
      expect(
        const CardioGoal(type: CardioGoalType.calories, value: 300).label,
        '300 kcal',
      );
    });

    test('una distanza con decimali li conserva', () {
      expect(
        const CardioGoal(type: CardioGoalType.distance, value: 2.5).label,
        '2.5 km',
      );
    });
  });
}
