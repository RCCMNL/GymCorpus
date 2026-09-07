import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_history_group.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;

  setUpAll(() {
    registerFallbackValue(LoadExercisesEvent());
  });

  setUp(() {
    bloc = MockTrainingBloc();
  });

  final session = CardioSessionEntity(
    id: 42,
    type: 'run',
    distance: 5,
    duration: 1800,
    avgSpeed: 10,
    pace: '06:00',
    calories: 400,
    date: DateTime(2026),
  );

  Widget wrap(Widget child) {
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('CardioHistoryGroup mostra titolo, sottotitolo e le sessioni', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CardioHistoryGroup(
          title: 'RECENTI',
          subtitle: 'Ultimi 7 giorni',
          accentColor: Colors.blue,
          sessions: [session],
        ),
      ),
    );

    expect(find.text('RECENTI'), findsOneWidget);
    expect(find.text('Ultimi 7 giorni'), findsOneWidget);
    expect(find.text('Corsa'), findsOneWidget);
  });

  testWidgets(
    'annullare la conferma di eliminazione mantiene la card e non invia eventi',
    (tester) async {
      await tester.pumpWidget(
        wrap(DismissibleCardioCard(session: session, accentColor: Colors.blue)),
      );

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Elimina sessione'), findsOneWidget);
      await tester.tap(find.text('ANNULLA'));
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    },
  );

  testWidgets("confermare l'eliminazione invia DeleteCardioSessionEvent", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(DismissibleCardioCard(session: session, accentColor: Colors.blue)),
    );

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ELIMINA'));
    await tester.pumpAndSettle();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<DeleteCardioSessionEvent>().single;
    expect(event.id, 42);
  });
}
