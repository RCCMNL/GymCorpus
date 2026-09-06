import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_selector_sheet.dart';

/// L'obiettivo si sceglie qui, prima di partire: durante la sessione le mani
/// sono occupate e il telefono spesso in tasca.
void main() {
  Widget wrap({required void Function(CardioLaunchArgs) onStart}) {
    return MaterialApp(
      home: Scaffold(body: CardioSelectorSheet(onStart: onStart)),
    );
  }

  testWidgets('propone corsa e camminata', (tester) async {
    await tester.pumpWidget(wrap(onStart: (_) {}));

    expect(find.text('Corsa'), findsOneWidget);
    expect(find.text('Camminata'), findsOneWidget);
  });

  testWidgets('senza obiettivo scelto la sessione parte libera', (
    tester,
  ) async {
    CardioLaunchArgs? started;
    await tester.pumpWidget(wrap(onStart: (args) => started = args));

    await tester.tap(find.text('Corsa'));

    expect(started?.type, 'run');
    expect(started?.goal, isNull);
  });

  testWidgets('la camminata parte con il proprio tipo', (tester) async {
    CardioLaunchArgs? started;
    await tester.pumpWidget(wrap(onStart: (args) => started = args));

    await tester.tap(find.text('Camminata'));

    expect(started?.type, 'walk');
  });

  testWidgets('l obiettivo scelto viene passato alla sessione', (tester) async {
    CardioLaunchArgs? started;
    await tester.pumpWidget(wrap(onStart: (args) => started = args));

    await tester.tap(find.text('5 km'));
    await tester.pump();
    await tester.tap(find.text('Corsa'));

    expect(
      started?.goal,
      const CardioGoal(type: CardioGoalType.distance, value: 5),
    );
  });

  testWidgets('toccando di nuovo l obiettivo lo si toglie', (tester) async {
    CardioLaunchArgs? started;
    await tester.pumpWidget(wrap(onStart: (args) => started = args));

    await tester.tap(find.text('30 min'));
    await tester.pump();
    await tester.tap(find.text('30 min'));
    await tester.pump();
    await tester.tap(find.text('Corsa'));

    expect(started?.goal, isNull);
  });

  testWidgets('si puo scegliere un solo obiettivo per volta', (tester) async {
    CardioLaunchArgs? started;
    await tester.pumpWidget(wrap(onStart: (args) => started = args));

    await tester.tap(find.text('5 km'));
    await tester.pump();
    await tester.tap(find.text('300 kcal'));
    await tester.pump();
    await tester.tap(find.text('Corsa'));

    expect(
      started?.goal,
      const CardioGoal(type: CardioGoalType.calories, value: 300),
    );
  });
}
