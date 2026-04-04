import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/widgets/exercise_card.dart';

void main() {
  const tExercise = ExerciseEntity(
    id: 1,
    name: 'Deadlift',
    targetMuscle: 'Back / Legs',
    isVector: true,
  );

  Widget createWidgetUnderTest(ThemeData theme) {
    return MaterialApp(
      theme: theme,
      home: const Scaffold(
        body: Center(
          child: ExerciseCard(exercise: tExercise),
        ),
      ),
    );
  }

  testWidgets('Golden Test per ExerciseCard in Light Mode', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AppTheme.lightTheme));
    
    // Attendi l'apertura e render dei font completi
    await tester.pumpAndSettle();

    // Matching per Golden File (Nota: questo genera/avvia comparazione con file render image)
    // flutter test --update-goldens
    await expectLater(
      find.byType(ExerciseCard),
      matchesGoldenFile('goldens/exercise_card_light.png'),
    );
  });

  testWidgets('Golden Test per ExerciseCard in Dark Mode', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(AppTheme.darkTheme));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ExerciseCard),
      matchesGoldenFile('goldens/exercise_card_dark.png'),
    );
  });
}
