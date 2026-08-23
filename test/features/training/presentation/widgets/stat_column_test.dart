import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/stat_column.dart';

void main() {
  testWidgets('mostra etichetta e valore', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: StatColumn(
              label: 'DISTANZA',
              value: '5.20 km',
              theme: Theme.of(context),
            ),
          ),
        ),
      ),
    );

    expect(find.text('DISTANZA'), findsOneWidget);
    expect(find.text('5.20 km'), findsOneWidget);
  });
}
