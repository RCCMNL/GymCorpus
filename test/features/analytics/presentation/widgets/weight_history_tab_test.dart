import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/weight_history_tab.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
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

  // I provider vanno sopra MaterialApp: i fogli modali aperti da questo tab
  // usano il root navigator e non vedrebbero un provider annidato in home.
  Widget wrap({
    required List<BodyWeightLogEntity> logs,
    double? profileWeight,
    Map<String, String> settings = const {},
  }) {
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: MaterialApp(
        home: Scaffold(
          body: WeightHistoryTab(
            logs: logs,
            profileWeight: profileWeight,
            settings: settings,
            hero: const SizedBox(key: Key('hero')),
          ),
        ),
      ),
    );
  }

  testWidgets("mostra l'hero passato", (tester) async {
    await tester.pumpWidget(wrap(logs: const []));
    expect(find.byKey(const Key('hero')), findsOneWidget);
  });

  testWidgets('senza log ne peso profilo mostra lo stato vuoto generico', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(logs: const []));
    expect(find.text('Ancora nessun peso registrato'), findsOneWidget);
  });

  testWidgets('senza log ma con peso profilo mostra il peso disponibile', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(logs: const [], profileWeight: 70));
    expect(
      find.textContaining('Peso profilo disponibile: 70.0 kg'),
      findsOneWidget,
    );
  });

  testWidgets('con i log mostra il riepilogo dei check-in', (tester) async {
    await tester.pumpWidget(
      wrap(
        logs: [
          BodyWeightLogEntity(id: 1, weight: 80, date: DateTime(2026, 1, 5)),
          BodyWeightLogEntity(id: 2, weight: 79, date: DateTime(2026)),
        ],
      ),
    );

    expect(find.text('2 check-in registrati'), findsOneWidget);
  });

  testWidgets('aggiungere un peso invia AddBodyWeightLogEvent', (tester) async {
    await tester.pumpWidget(wrap(logs: const []));

    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '82');
    await tester.tap(find.text('Salva'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<AddBodyWeightLogEvent>().single;
    expect(event.weight, 82.0);
  });

  testWidgets('eliminare un log invia DeleteBodyWeightLogEvent', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        logs: [
          BodyWeightLogEntity(id: 7, weight: 80, date: DateTime(2026, 1, 5)),
        ],
      ),
    );

    // Il primo mese e' gia' espanso di default (initiallyExpanded: idx == 0).
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<DeleteBodyWeightLogEvent>().single;
    expect(event.id, 7);
  });
}
