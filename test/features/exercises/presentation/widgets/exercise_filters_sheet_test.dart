import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_catalog_view.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_filters_sheet.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

void main() {
  Widget wrap({
    required void Function(ExerciseFiltersResult?) onResult,
    String initialDifficulty = kAllDifficultiesFilter,
    Set<String> initialEquipment = const {},
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              final result = await showExerciseFiltersSheet(
                context,
                initialDifficulty: initialDifficulty,
                initialEquipment: initialEquipment,
              );
              onResult(result);
            },
            child: const Text('Apri filtri'),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra le opzioni di difficoltà e attrezzatura preselezionate', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        initialDifficulty: ExerciseEntity.difficultyIntermediate,
        initialEquipment: const {'Bilanciere'},
        onResult: (_) {},
      ),
    );
    await tester.tap(find.text('Apri filtri'));
    await tester.pumpAndSettle();

    final difficultyChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, ExerciseEntity.difficultyIntermediate),
    );
    expect(difficultyChip.selected, isTrue);

    final equipmentChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Bilanciere'),
    );
    expect(equipmentChip.selected, isTrue);
  });

  testWidgets(
    'selezionare difficoltà e più tag attrezzatura e applicare ritorna i valori scelti',
    (tester) async {
      ExerciseFiltersResult? result;
      await tester.pumpWidget(wrap(onResult: (r) => result = r));
      await tester.tap(find.text('Apri filtri'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ExerciseEntity.difficultyAdvanced));
      await tester.tap(find.text('Manubri'));
      await tester.tap(find.text('Kettlebell'));
      await tester.pump();

      await tester.tap(find.text('APPLICA'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.difficulty, ExerciseEntity.difficultyAdvanced);
      expect(result!.equipment, {'Manubri', 'Kettlebell'});
    },
  );

  testWidgets('azzera riporta la difficoltà a Tutte e svuota l attrezzatura', (
    tester,
  ) async {
    ExerciseFiltersResult? result;
    await tester.pumpWidget(
      wrap(
        initialDifficulty: ExerciseEntity.difficultyBeginner,
        initialEquipment: const {'Corpo libero'},
        onResult: (r) => result = r,
      ),
    );
    await tester.tap(find.text('Apri filtri'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AZZERA'));
    await tester.pump();
    await tester.tap(find.text('APPLICA'));
    await tester.pumpAndSettle();

    expect(result!.difficulty, kAllDifficultiesFilter);
    expect(result!.equipment, isEmpty);
  });
}
