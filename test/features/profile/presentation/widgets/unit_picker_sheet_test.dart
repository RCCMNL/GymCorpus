import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/unit_picker_sheet.dart';
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

  Widget wrap(Widget child) {
    return MaterialApp(
      home: BlocProvider<TrainingBloc>.value(
        value: bloc,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets("applica l'unita iniziale se non viene cambiata selezione", (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const UnitPickerSheet(initialUnit: 'KG')));

    expect(find.text('Unità di Misura'), findsOneWidget);

    await tester.tap(find.text('APPLICA MODIFICHE'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<UpdatePreferenceEvent>().single;
    expect(event.key, 'units');
    expect(event.value, 'KG');
  });

  testWidgets("un'unita iniziale non riconosciuta ricade su KG", (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const UnitPickerSheet(initialUnit: 'xx')));

    await tester.tap(find.text('APPLICA MODIFICHE'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<UpdatePreferenceEvent>().single;
    expect(event.value, 'KG');
  });

  testWidgets('selezionare Imperiale invia units=LB', (tester) async {
    await tester.pumpWidget(wrap(const UnitPickerSheet(initialUnit: 'KG')));

    await tester.tap(find.text('Imperiale'));
    await tester.pump();
    await tester.tap(find.text('APPLICA MODIFICHE'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<UpdatePreferenceEvent>().single;
    expect(event.value, 'LB');
  });
}
