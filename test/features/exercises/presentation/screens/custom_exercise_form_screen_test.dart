import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/custom_exercise_form_screen.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_notifications_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;
  late MockNotificationsBloc notificationsBloc;

  setUpAll(() {
    registerFallbackValue(LoadExercisesEvent());
  });

  setUp(() {
    bloc = MockTrainingBloc();
    whenListen(
      bloc,
      const Stream<TrainingState>.empty(),
      initialState: const TrainingState.loaded(exercises: []),
    );
    notificationsBloc = MockNotificationsBloc();
    whenListen(
      notificationsBloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsState(),
    );
  });

  // Nessun GoRouter reale nell'albero: il salvataggio chiama context.pop()
  // (estensione go_router), che senza un GoRouter ancestor lancia un
  // GoError invece di navigare. Nei test sul salvataggio riuscito questo
  // errore atteso viene consumato con tester.takeException() subito dopo
  // il tap, cosi' l'unica cosa verificata resta quella che conta davvero:
  // l'evento inviato al bloc con i campi giusti.
  Widget wrap({ExerciseEntity? exerciseToEdit}) {
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: BlocProvider<NotificationsBloc>.value(
        value: notificationsBloc,
        child: MaterialApp(
          home: CustomExerciseFormScreen(exerciseToEdit: exerciseToEdit),
        ),
      ),
    );
  }

  Future<void> tapSave(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pump();
  }

  group('CustomExerciseFormScreen - creazione', () {
    testWidgets('nome vuoto blocca il salvataggio senza inviare eventi', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      await tapSave(tester, 'CREA ESERCIZIO');

      verifyNever(() => bloc.add(any()));
      expect(find.text('Il nome è obbligatorio'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('senza gruppo muscolare mostra un avviso e non invia eventi', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      await tester.enterText(
        find.byType(TextFormField).first,
        'Curl con elastici',
      );
      await tapSave(tester, 'CREA ESERCIZIO');

      verifyNever(() => bloc.add(any()));
      expect(find.text('Seleziona un gruppo muscolare.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('senza difficoltà mostra un avviso e non invia eventi', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      await tester.enterText(
        find.byType(TextFormField).first,
        'Curl con elastici',
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Bicipiti'));
      await tester.pump();
      await tapSave(tester, 'CREA ESERCIZIO');

      verifyNever(() => bloc.add(any()));
      expect(find.text('Seleziona una difficoltà.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'con i campi obbligatori compilati invia AddCustomExerciseEvent',
      (tester) async {
        await tester.pumpWidget(wrap());

        await tester.enterText(
          find.byType(TextFormField).first,
          'Curl con elastici',
        );
        await tester.tap(find.widgetWithText(ChoiceChip, 'Bicipiti'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ChoiceChip, 'Principiante'));
        await tester.pump();
        await tapSave(tester, 'CREA ESERCIZIO');

        // Il pop successivo al dispatch lancia GoError (nessun GoRouter nel
        // test): e' l'errore atteso descritto sopra, non un fallimento.
        expect(tester.takeException(), isNotNull);

        final captured = verify(() => bloc.add(captureAny())).captured;
        expect(captured, hasLength(1));
        final event = captured.first as AddCustomExerciseEvent;
        expect(event.name, 'Curl con elastici');
        expect(event.targetMuscle, 'Bicipiti');
        expect(event.difficulty, 'Principiante');
      },
    );
  });

  group('CustomExerciseFormScreen - modifica', () {
    const existing = ExerciseEntity(
      id: 42,
      name: 'Curl con elastici',
      targetMuscle: 'Bicipiti',
      equipment: 'Elastici',
      difficulty: 'Intermedio',
      isCustom: true,
    );

    testWidgets('precompila nome, muscolo e difficoltà dell esercizio', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(exerciseToEdit: existing));

      expect(find.text('Curl con elastici'), findsOneWidget);
      expect(find.text('Elastici'), findsOneWidget);

      final muscleChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Bicipiti'),
      );
      expect(muscleChip.selected, isTrue);

      final difficultyChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Intermedio'),
      );
      expect(difficultyChip.selected, isTrue);

      expect(find.text('Modifica Esercizio'), findsOneWidget);
      expect(find.text('SALVA MODIFICHE'), findsOneWidget);
    });

    testWidgets(
      'il salvataggio invia UpdateCustomExerciseEvent con l id giusto',
      (tester) async {
        await tester.pumpWidget(wrap(exerciseToEdit: existing));

        await tester.tap(find.widgetWithText(ChoiceChip, 'Avanzato'));
        await tester.pump();
        await tapSave(tester, 'SALVA MODIFICHE');

        expect(tester.takeException(), isNotNull);

        final captured = verify(() => bloc.add(captureAny())).captured;
        expect(captured, hasLength(1));
        final event = captured.first as UpdateCustomExerciseEvent;
        expect(event.id, 42);
        expect(event.name, 'Curl con elastici');
        expect(event.targetMuscle, 'Bicipiti');
        expect(event.difficulty, 'Avanzato');
      },
    );
  });
}
