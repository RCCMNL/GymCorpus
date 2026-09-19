import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/routine_detail_header.dart';

import '../../../../helpers/narrow_screen.dart';

void main() {
  testWidgets('mostra titolo, numero esercizi e durata stimata', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RoutineDetailHeader(
            title: 'Push Day',
            exerciseCount: 6,
            estimatedDuration: 45,
          ),
        ),
      ),
    );

    expect(find.text('Push Day'), findsOneWidget);
    expect(find.text('6 ESERCIZI'), findsOneWidget);
    expect(find.text('45 MIN'), findsOneWidget);
  });

  testWidgets('mostra -- quando la durata stimata e assente', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RoutineDetailHeader(
            title: 'Full Body',
            exerciseCount: 3,
            estimatedDuration: null,
          ),
        ),
      ),
    );

    expect(find.text('-- MIN'), findsOneWidget);
  });

  testWidgets('su uno schermo stretto non taglia niente', (tester) async {
    useNarrowScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: RoutineDetailHeader(
              title: 'Full Body Principianti',
              exerciseCount: 8,
              estimatedDuration: 45,
              isSystem: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
