import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_selector_sheet.dart';

/// L'obiettivo si sceglie qui, prima di partire: durante la sessione le mani
/// sono occupate e il telefono spesso in tasca.
void main() {
  Widget wrap({required void Function(CardioLaunchArgs) onStart}) {
    return MaterialApp(
      home: Scaffold(
        body: CardioSelectorSheet(onStart: onStart, onManualEntry: () {}),
      ),
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

    expect(started?.activity, CardioActivity.run);
    expect(started?.goal, isNull);
  });

  testWidgets('la camminata parte con il proprio tipo', (tester) async {
    CardioLaunchArgs? started;
    await tester.pumpWidget(wrap(onStart: (args) => started = args));

    await tester.tap(find.text('Camminata'));

    expect(started?.activity, CardioActivity.walk);
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

  testWidgets('propone anche le attivita al chiuso', (tester) async {
    await tester.pumpWidget(wrap(onStart: (_) {}));

    expect(find.text('Tapis roulant'), findsOneWidget);
    expect(find.text('Ellittica'), findsOneWidget);
    expect(find.text('Vogatore'), findsOneWidget);
  });

  testWidgets('con poco spazio le attivita al chiuso restano raggiungibili', (
    tester,
  ) async {
    CardioLaunchArgs? started;
    // 450 logici: quanto concedeva il foglio modale senza isScrollControlled.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 450,
              child: CardioSelectorSheet(
                onStart: (args) => started = args,
                onManualEntry: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('Vogatore'), 100);
    await tester.tap(find.text('Vogatore'));

    expect(started?.activity, CardioActivity.rowing);
  });

  testWidgets('aperto come foglio mostra le attivita al chiuso sullo schermo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showCardioSelectorSheet(
                  context: context,
                  onStart: (_) {},
                  onManualEntry: () {},
                ),
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.text('Vogatore')).bottom, lessThanOrEqualTo(800));
  });

  testWidgets('si puo registrare una sessione gia fatta', (tester) async {
    var manual = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardioSelectorSheet(
            onStart: (_) {},
            onManualEntry: () => manual++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Registra una sessione gia fatta'));

    expect(manual, 1);
  });
}
