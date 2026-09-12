import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_thumbnail.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

const _exercise = ExerciseEntity(
  id: 1,
  name: 'Panca piana (Bilanciere)',
  targetMuscle: 'Petto',
);

Future<void> _pump(WidgetTester tester, [Widget? child]) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: child ?? const ExerciseThumbnail(exercise: _exercise),
      ),
    ),
  );
}

void main() {
  group('ExerciseThumbnail', () {
    testWidgets('cerca la figura col nome dell esercizio', (tester) async {
      await _pump(tester);

      final image = tester.widget<Image>(find.byType(Image)).image;

      expect(
        (image as AssetImage).assetName,
        'assets/exercises/panca-piana-bilanciere.webp',
      );
    });

    testWidgets('la figura che manca diventa il segnaposto, non un errore', (
      tester,
    ) async {
      await _pump(tester);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('il segnaposto si tinge della regione muscolare', (
      tester,
    ) async {
      await _pump(tester);
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.fitness_center_rounded),
      );
      final atteso = ExerciseThumbnail.accentFor(
        _exercise,
        AppTheme.darkTheme.colorScheme,
      );

      expect(icon.color, atteso.withValues(alpha: 0.85));
    });

    testWidgets('un nome senza lettere ne numeri non cerca nessun asset', (
      tester,
    ) async {
      await _pump(
        tester,
        const ExerciseThumbnail(
          exercise: ExerciseEntity(id: 2, name: '???', targetMuscle: 'Petto'),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    });

    testWidgets('la miniatura e quadrata della misura richiesta', (
      tester,
    ) async {
      await _pump(
        tester,
        const ExerciseThumbnail(exercise: _exercise, size: 48),
      );

      expect(
        tester.getSize(find.byType(ExerciseThumbnail)),
        const Size(48, 48),
      );
    });
  });
}
