import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/training_calculations.dart';

void main() {
  group('TrainingCalculations - Brzycki 1RM Estimation', () {
    test('ritorna 0 se le ripetizioni sono <= 0', () {
      final rm = TrainingCalculations.calculateBrzycki1RM(weight: 100, reps: 0);
      expect(rm, 0.0);
    });

    test('ritorna il peso inserito se reps = 1', () {
      final rm = TrainingCalculations.calculateBrzycki1RM(weight: 100, reps: 1);
      expect(rm, 100.0);
    });

    test('ritorna 0 se il peso sollevato è < 0', () {
      final rm = TrainingCalculations.calculateBrzycki1RM(weight: -50, reps: 5);
      expect(rm, 0.0);
    });

    test('calcola correttamente per 5 rep (RPE > 8 scenarios)', () {
      // Formula: 100 / (1.0278 - (0.0278 * 5))
      // Denominatore: 1.0278 - 0.139 = 0.8888
      // 1RM stimato: 100 / 0.8888 ≈ 112.51
      final rm = TrainingCalculations.calculateBrzycki1RM(weight: 100, reps: 5);
      expect(rm, closeTo(112.5, 0.1));
    });

    test('fallback logico per rep estreme (evitano denominatore negativo/0)', () {
      // Se reps > ~37, denominator <= 0, dovrebbe tornare il peso senza divisione.
      final rm = TrainingCalculations.calculateBrzycki1RM(weight: 100, reps: 40);
      expect(rm, 100.0); 
    });
  });
}
