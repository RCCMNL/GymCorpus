import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/header_tag.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra icona e testo quando icon e specificata', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HeaderTag(
          icon: Icons.timer_outlined,
          label: '30 MIN',
          color: Colors.blue,
          textColor: Colors.white,
        ),
      ),
    );

    expect(find.text('30 MIN'), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
  });

  testWidgets('non mostra alcuna icona quando icon e null', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HeaderTag(
          label: '5 ESERCIZI',
          color: Colors.green,
          textColor: Colors.black,
        ),
      ),
    );

    expect(find.text('5 ESERCIZI'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });
}
