import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/timer_picker_sheet.dart';
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

  testWidgets('mostra il titolo e applica il valore iniziale (clamped)', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TimerPickerSheet(initialValue: '90')));

    expect(find.text('Timer di Recupero'), findsOneWidget);

    await tester.tap(find.text('APPLICA MODIFICHE'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<UpdatePreferenceEvent>().single;
    expect(event.key, 'rest_timer');
    expect(event.value, '90');
  });

  testWidgets('un valore iniziale fuori range viene clampato tra 1 e 300', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TimerPickerSheet(initialValue: '9999')));

    await tester.tap(find.text('APPLICA MODIFICHE'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<UpdatePreferenceEvent>().single;
    expect(event.value, '300');
  });

  testWidgets('un valore iniziale non numerico ricade su 90', (tester) async {
    await tester.pumpWidget(
      wrap(const TimerPickerSheet(initialValue: 'invalid')),
    );

    await tester.tap(find.text('APPLICA MODIFICHE'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<UpdatePreferenceEvent>().single;
    expect(event.value, '90');
  });
}
