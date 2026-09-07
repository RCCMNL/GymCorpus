import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_detail_header.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

const _exercise = ExerciseEntity(
  id: 1,
  name: 'Panca piana',
  targetMuscle: 'Petto',
  difficulty: ExerciseEntity.difficultyIntermediate,
);

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(theme: AppTheme.darkTheme, home: Scaffold(body: child)),
  );
}

void main() {
  group('CircleActionButton', () {
    testWidgets('mostra l icona richiesta', (tester) async {
      await _pump(
        tester,
        CircleActionButton(icon: Icons.edit_outlined, onPressed: () {}),
      );

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('il tocco arriva a chi lo ha passato', (tester) async {
      var toccato = false;
      await _pump(
        tester,
        CircleActionButton(
          icon: Icons.favorite,
          onPressed: () => toccato = true,
        ),
      );

      await tester.tap(find.byType(IconButton));

      expect(toccato, isTrue);
    });
  });

  group('ExerciseHero', () {
    testWidgets('mostra nome e muscolo in maiuscolo', (tester) async {
      await _pump(tester, const ExerciseHero(exercise: _exercise));

      expect(find.text('Panca piana'), findsOneWidget);
      expect(find.text('PETTO'), findsOneWidget);
    });

    testWidgets('mostra la difficolta quando c e', (tester) async {
      await _pump(tester, const ExerciseHero(exercise: _exercise));

      expect(find.text('INTERMEDIO'), findsOneWidget);
    });

    testWidgets('senza difficolta non mostra il distintivo', (tester) async {
      await _pump(
        tester,
        const ExerciseHero(
          exercise: ExerciseEntity(
            id: 2,
            name: 'Crunch',
            targetMuscle: 'Addominali',
          ),
        ),
      );

      expect(find.text('INTERMEDIO'), findsNothing);
      expect(find.text('Crunch'), findsOneWidget);
    });

    testWidgets('un nome lungo viene scritto piu piccolo', (tester) async {
      const lungo = 'Distensioni su panca inclinata con manubri';
      await _pump(
        tester,
        const ExerciseHero(
          exercise: ExerciseEntity(
            id: 3,
            name: lungo,
            targetMuscle: 'Petto',
          ),
        ),
      );

      final corto = tester.widget<Text>(find.text(lungo));

      expect(corto.style!.fontSize, 32);
    });
  });
}
