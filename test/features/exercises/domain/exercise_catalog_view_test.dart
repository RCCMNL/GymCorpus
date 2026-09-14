import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_catalog_view.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

void main() {
  const squat = ExerciseEntity(
    id: 1,
    name: 'Squat',
    targetMuscle: 'Gambe',
    equipment: 'Bilanciere',
    difficulty: ExerciseEntity.difficultyAdvanced,
  );
  const pushUp = ExerciseEntity(
    id: 2,
    name: 'Push-up',
    targetMuscle: 'Petto',
    isBodyweight: true,
    difficulty: ExerciseEntity.difficultyBeginner,
  );
  const benchPress = ExerciseEntity(
    id: 3,
    name: 'Panca piana',
    targetMuscle: 'Petto',
    equipment: 'Bilanciere',
    isFavorite: true,
    difficulty: ExerciseEntity.difficultyIntermediate,
  );
  const noMuscle = ExerciseEntity(id: 4, name: 'Misterioso', targetMuscle: '');

  final all = [squat, pushUp, benchPress, noMuscle];

  group('ExerciseCatalogView.build', () {
    test('senza filtri raggruppa per ogni categoria di ogni esercizio', () {
      final catalog = ExerciseCatalogView.build(
        exercises: all,
        searchQuery: '',
        selectedMuscle: kAllMusclesFilter,
        selectedDifficulty: kAllDifficultiesFilter,
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
          selectedDifficulty: kAllDifficultiesFilter,
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
          selectedDifficulty: kAllDifficultiesFilter,
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
        selectedDifficulty: kAllDifficultiesFilter,
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
            selectedDifficulty: kAllDifficultiesFilter,
          ).exercisesBySection.values.expand((e) => e),
          [squat],
        );

        expect(
          ExerciseCatalogView.build(
            exercises: all,
            searchQuery: 'bilanciere',
            selectedMuscle: kAllMusclesFilter,
            selectedDifficulty: kAllDifficultiesFilter,
          ).exercisesBySection.values.expand((e) => e).toSet(),
          {squat, benchPress},
        );

        expect(
          ExerciseCatalogView.build(
            exercises: all,
            searchQuery: 'gambe',
            selectedMuscle: kAllMusclesFilter,
            selectedDifficulty: kAllDifficultiesFilter,
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
        selectedDifficulty: kAllDifficultiesFilter,
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
        selectedDifficulty: kAllDifficultiesFilter,
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
          selectedDifficulty: kAllDifficultiesFilter,
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
        selectedDifficulty: kAllDifficultiesFilter,
      );

      expect(catalog.muscleGroups, contains('Petto'));
      expect(catalog.muscleGroups, contains('Corpo libero'));
    });

    group('filtro difficoltà', () {
      test('kAllDifficultiesFilter mostra tutti gli esercizi', () {
        final catalog = ExerciseCatalogView.build(
          exercises: all,
          searchQuery: '',
          selectedMuscle: kAllMusclesFilter,
          selectedDifficulty: kAllDifficultiesFilter,
        );

        expect(catalog.exercisesBySection.values.expand((e) => e).toSet(), {
          squat,
          pushUp,
          benchPress,
        });
      });

      test(
        'una difficoltà specifica filtra solo gli esercizi corrispondenti',
        () {
          final catalog = ExerciseCatalogView.build(
            exercises: all,
            searchQuery: '',
            selectedMuscle: kAllMusclesFilter,
            selectedDifficulty: ExerciseEntity.difficultyBeginner,
          );

          expect(catalog.exercisesBySection.values.expand((e) => e).toSet(), {
            pushUp,
          });
        },
      );

      test(
        'un esercizio senza difficoltà non compare con un filtro specifico',
        () {
          final catalog = ExerciseCatalogView.build(
            exercises: [noMuscle],
            searchQuery: '',
            selectedMuscle: kAllMusclesFilter,
            selectedDifficulty: ExerciseEntity.difficultyBeginner,
          );

          expect(catalog.exercisesBySection, isEmpty);
        },
      );

      test('difficoltà, muscolo e ricerca si combinano con AND, non OR', () {
        // benchPress e' Intermedio: un filtro su Avanzato deve escluderlo
        // anche se muscolo e ricerca combaciano.
        final catalog = ExerciseCatalogView.build(
          exercises: all,
          searchQuery: 'panca',
          selectedMuscle: 'Petto',
          selectedDifficulty: ExerciseEntity.difficultyAdvanced,
        );

        expect(catalog.exercisesBySection, isEmpty);
      });

      test(
        'difficultyOptions e sempre Tutte seguito dai tre livelli in ordine',
        () {
          final catalog = ExerciseCatalogView.build(
            exercises: all,
            searchQuery: '',
            selectedMuscle: kAllMusclesFilter,
            selectedDifficulty: kAllDifficultiesFilter,
          );

          expect(catalog.difficultyOptions, [
            kAllDifficultiesFilter,
            ExerciseEntity.difficultyBeginner,
            ExerciseEntity.difficultyIntermediate,
            ExerciseEntity.difficultyAdvanced,
          ]);
        },
      );
    });

    group('filtro attrezzatura', () {
      test('un set vuoto non filtra nulla (comportamento di default)', () {
        final catalog = ExerciseCatalogView.build(
          exercises: all,
          searchQuery: '',
          selectedMuscle: kAllMusclesFilter,
          selectedDifficulty: kAllDifficultiesFilter,
        );

        expect(catalog.exercisesBySection.values.expand((e) => e).toSet(), {
          squat,
          pushUp,
          benchPress,
        });
      });

      test('un tag mostra solo gli esercizi che lo hanno', () {
        final catalog = ExerciseCatalogView.build(
          exercises: all,
          searchQuery: '',
          selectedMuscle: kAllMusclesFilter,
          selectedDifficulty: kAllDifficultiesFilter,
          selectedEquipment: const {'Corpo libero'},
        );

        expect(catalog.exercisesBySection.values.expand((e) => e).toSet(), {
          pushUp,
        });
      });

      test(
        'più tag selezionati si combinano con OR, non serve averli tutti',
        () {
          final catalog = ExerciseCatalogView.build(
            exercises: all,
            searchQuery: '',
            selectedMuscle: kAllMusclesFilter,
            selectedDifficulty: kAllDifficultiesFilter,
            selectedEquipment: const {'Corpo libero', 'Bilanciere'},
          );

          expect(catalog.exercisesBySection.values.expand((e) => e).toSet(), {
            squat,
            pushUp,
            benchPress,
          });
        },
      );

      test(
        'attrezzatura si combina con AND rispetto a muscolo e difficoltà',
        () {
          // benchPress ha "Bilanciere" ma e' Intermedio: filtrando su
          // Avanzato non deve comparire anche se il tag combacia.
          final catalog = ExerciseCatalogView.build(
            exercises: all,
            searchQuery: '',
            selectedMuscle: kAllMusclesFilter,
            selectedDifficulty: ExerciseEntity.difficultyAdvanced,
            selectedEquipment: const {'Bilanciere'},
          );

          expect(catalog.exercisesBySection.values.expand((e) => e).toSet(), {
            squat,
          });
        },
      );
    });
  });
}
