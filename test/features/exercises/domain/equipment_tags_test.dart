import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/domain/equipment_tags.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

void main() {
  group('equipmentTagsFor', () {
    test('un esercizio a corpo libero ha sempre il tag Corpo libero', () {
      const exercise = ExerciseEntity(
        id: 1,
        name: 'Plank',
        targetMuscle: 'Addominali',
        equipment: 'Tappetino',
        isBodyweight: true,
      );

      expect(equipmentTagsFor(exercise), contains('Corpo libero'));
    });

    test('riconosce un singolo tag da una parola chiave nel testo', () {
      const exercise = ExerciseEntity(
        id: 2,
        name: 'Curl con manubri',
        targetMuscle: 'Bicipiti',
        equipment: 'Manubri',
      );

      expect(equipmentTagsFor(exercise), ['Manubri']);
    });

    test('un esercizio con più attrezzi ha più tag', () {
      const exercise = ExerciseEntity(
        id: 3,
        name: 'Back Squat',
        targetMuscle: 'Gambe',
        equipment: 'Bilanciere, Rack (Squat rack), Pesi',
      );

      final tags = equipmentTagsFor(exercise);
      expect(tags, containsAll(['Bilanciere', 'Rack', 'Dischi / Pesi']));
    });

    test('il riconoscimento non distingue maiuscole e minuscole', () {
      const exercise = ExerciseEntity(
        id: 4,
        name: 'Test',
        targetMuscle: 'Petto',
        equipment: 'BILANCIERE',
      );

      expect(equipmentTagsFor(exercise), ['Bilanciere']);
    });

    test('cavo/ercolina copre anche le varianti corda e maniglia', () {
      const exercise = ExerciseEntity(
        id: 5,
        name: 'Pushdown ai cavi',
        targetMuscle: 'Tricipiti',
        equipment: 'Cavo (Ercolina), Corda',
      );

      expect(equipmentTagsFor(exercise), ['Cavi / Ercolina']);
    });

    test('nessun tag riconosciuto restituisce lista vuota', () {
      const exercise = ExerciseEntity(
        id: 6,
        name: 'Wrist Roller',
        targetMuscle: 'Avambracci',
        equipment: 'Wrist roller (rullo per polsi) e peso',
      );

      expect(equipmentTagsFor(exercise), isEmpty);
    });

    test('senza campo equipment e senza corpo libero non ci sono tag', () {
      const exercise = ExerciseEntity(
        id: 7,
        name: 'Misterioso',
        targetMuscle: 'Petto',
      );

      expect(equipmentTagsFor(exercise), isEmpty);
    });
  });
}
