import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_catalog_view.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

void main() {
  const squat = ExerciseEntity(
    id: 1,
    name: 'Squat',
    targetMuscle: 'Gambe',
    equipment: 'Bilanciere',
  );
  const pushUp = ExerciseEntity(
    id: 2,
    name: 'Push-up',
    targetMuscle: 'Petto',
    isBodyweight: true,
  );
  const benchPress = ExerciseEntity(
    id: 3,
    name: 'Panca piana',
    targetMuscle: 'Petto',
    equipment: 'Bilanciere',
    isFavorite: true,
  );
  const noMuscle = ExerciseEntity(id: 4, name: 'Misterioso', targetMuscle: '');

  final all = [squat, pushUp, benchPress, noMuscle];

  group('ExerciseCatalogView.build', () {
    test('senza filtri raggruppa per ogni categoria di ogni esercizio', () {
      final catalog = ExerciseCatalogView.build(
        exercises: all,
        searchQuery: '',
        selectedMuscle: kAllMusclesFilter,
      );

      // push-up e' sia "Petto" che "Corpo libero": compare in entrambe le
      // sezioni quando non c'e' un filtro muscolo attivo.
      expect(catalog.sections, contains('Petto'));
      expect(catalog.sections, contains('Corpo libero'));
      expect(
        catalog.exercisesBySection['Petto'],
        containsAll([pushUp, benchPress]),
      );
      expect(catalog.exercisesBySection['Corpo libero'], contains(pushUp));
    });

    test(
      'un esercizio senza muscolo ne corpo libero non compare in alcuna sezione',
      () {
        // targetMuscle vuoto e isBodyweight=false producono categories = [],
        // quindi l'esercizio passa il filtro ma non entra in alcun
        // raggruppamento. Il fallback su kUncategorizedSection nel codice
        // di build() non scatta mai in pratica: ExerciseEntity.categories
        // non produce mai una categoria dal nome vuoto, la filtra prima di
        // restituire la lista.
        final catalog = ExerciseCatalogView.build(
          exercises: [noMuscle],
          searchQuery: '',
          selectedMuscle: kAllMusclesFilter,
        );

        expect(catalog.sections, isEmpty);
        expect(catalog.exercisesBySection, isEmpty);
      },
    );

    test(
      'con un muscolo specifico selezionato, un esercizio compare solo in quella sezione',
      () {
        // push-up e' sia Petto che Corpo libero: filtrando su "Petto" non
        // deve comparire anche sotto "Corpo libero".
        final catalog = ExerciseCatalogView.build(
          exercises: all,
          searchQuery: '',
          selectedMuscle: 'Petto',
        );

        expect(catalog.sections, ['Petto']);
        expect(catalog.exercisesBySection['Petto'], [pushUp, benchPress]);
      },
    );

    test('kFavoritesMuscleFilter mostra solo gli esercizi preferiti', () {
      final catalog = ExerciseCatalogView.build(
        exercises: all,
        searchQuery: '',
        selectedMuscle: kFavoritesMuscleFilter,
      );

      final shown = catalog.exercisesBySection.values.expand((e) => e);
      expect(shown, [benchPress]);
    });

    test(
      'la ricerca testuale corrisponde su nome, attrezzatura e categoria',
      () {
        expect(
          ExerciseCatalogView.build(
            exercises: all,
            searchQuery: 'squat',
            selectedMuscle: kAllMusclesFilter,
          ).exercisesBySection.values.expand((e) => e),
          [squat],
        );

        expect(
          ExerciseCatalogView.build(
            exercises: all,
            searchQuery: 'bilanciere',
            selectedMuscle: kAllMusclesFilter,
          ).exercisesBySection.values.expand((e) => e).toSet(),
          {squat, benchPress},
        );

        expect(
          ExerciseCatalogView.build(
            exercises: all,
            searchQuery: 'gambe',
            selectedMuscle: kAllMusclesFilter,
          ).exercisesBySection.values.expand((e) => e),
          [squat],
        );
      },
    );

    test('la ricerca non distingue maiuscole e minuscole', () {
      final catalog = ExerciseCatalogView.build(
        exercises: all,
        searchQuery: 'SQUAT',
        selectedMuscle: kAllMusclesFilter,
      );

      expect(catalog.exercisesBySection.values.expand((e) => e), [squat]);
    });

    test('ricerca e filtro muscolo si combinano con AND', () {
      // "panca" trova solo benchPress, ma con filtro "Gambe" (dove non e')
      // il risultato deve essere vuoto: nessun OR implicito.
      final catalog = ExerciseCatalogView.build(
        exercises: all,
        searchQuery: 'panca',
        selectedMuscle: 'Gambe',
      );

      expect(catalog.exercisesBySection, isEmpty);
    });

    test(
      'muscleGroups include sempre Tutti e Preferiti, poi le categorie ordinate',
      () {
        final catalog = ExerciseCatalogView.build(
          exercises: all,
          searchQuery: '',
          selectedMuscle: kAllMusclesFilter,
        );

        expect(catalog.muscleGroups.first, kAllMusclesFilter);
        expect(catalog.muscleGroups[1], kFavoritesMuscleFilter);
        expect(catalog.muscleGroups.skip(2), [
          'Corpo libero',
          'Gambe',
          'Petto',
        ]);
      },
    );

    test('muscleGroups deriva sempre dal catalogo completo, non filtrato', () {
      // Anche filtrando la ricerca su "squat", il selettore deve continuare
      // a mostrare tutti i muscoli disponibili, non solo "Gambe".
      final catalog = ExerciseCatalogView.build(
        exercises: all,
        searchQuery: 'squat',
        selectedMuscle: kAllMusclesFilter,
      );

      expect(catalog.muscleGroups, contains('Petto'));
      expect(catalog.muscleGroups, contains('Corpo libero'));
    });
  });
}
