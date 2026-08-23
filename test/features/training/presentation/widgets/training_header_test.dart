import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_header.dart';

void main() {
  Widget buildHeader({
    bool isPaused = false,
    VoidCallback? onTogglePause,
    VoidCallback? onConfirmEnd,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TrainingHeader(
          routineTitle: 'Push Day',
          execTimeStr: '00:12:34',
          accentColor: Colors.blue,
          isPaused: isPaused,
          onTogglePause: onTogglePause ?? () {},
          onConfirmEnd: onConfirmEnd ?? () {},
          exerciseIndex: 1,
          exerciseCount: 5,
          progress: 0.4,
        ),
      ),
    );
  }

  testWidgets('mostra titolo routine, cronometro e progresso', (tester) async {
    await tester.pumpWidget(buildHeader());

    expect(find.text('PUSH DAY'), findsOneWidget);
    expect(find.text('00:12:34'), findsOneWidget);
    expect(find.text('Esercizio 2 di 5'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
  });

  testWidgets('mostra icona pausa quando non in pausa, play quando in pausa', (
    tester,
  ) async {
    await tester.pumpWidget(buildHeader());
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

    await tester.pumpWidget(buildHeader(isPaused: true));
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsNothing);
  });

  testWidgets('onTogglePause e onConfirmEnd vengono invocate al tocco', (
    tester,
  ) async {
    var toggled = false;
    var confirmed = false;

    await tester.pumpWidget(
      buildHeader(
        onTogglePause: () => toggled = true,
        onConfirmEnd: () => confirmed = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.pause_rounded));
    expect(toggled, isTrue);

    await tester.tap(find.byIcon(Icons.stop_circle_outlined));
    expect(confirmed, isTrue);
  });
}
