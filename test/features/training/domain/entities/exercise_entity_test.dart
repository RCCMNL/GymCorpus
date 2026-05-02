import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

void main() {
  group('ExerciseEntity', () {
    test(
        'riconosce gli esercizi a corpo libero e li espone anche nella categoria dedicata',
        () {
      const exercise = ExerciseEntity(
        id: 1,
        name: 'Crunch',
        targetMuscle: 'Addominali',
        equipment: 'Corpo libero, Tappetino',
        isBodyweight: true,
      );

      expect(exercise.isBodyweight, isTrue);
      expect(
        exercise.categories,
        equals(['Addominali', ExerciseEntity.bodyweightCategory]),
      );
    });

    test('mantiene solo la categoria muscolare per gli esercizi non bodyweight',
        () {
      const exercise = ExerciseEntity(
        id: 2,
        name: 'Lat Machine',
        targetMuscle: 'Schiena',
        equipment: 'Macchinario (Lat Machine)',
      );

      expect(exercise.isBodyweight, isFalse);
      expect(exercise.categories, equals(['Schiena']));
    });
  });
}
