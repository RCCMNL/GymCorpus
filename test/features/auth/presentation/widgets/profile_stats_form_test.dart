import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/profile_stats_form.dart';

/// Peso e altezza non sono obbligatori, ma senza il peso il cardio stima le
/// calorie su 70 kg fissi e il BMI resta vuoto: qui si chiedono una volta,
/// spiegando perche', e si puo' saltare.
void main() {
  Widget wrap({
    required void Function(ProfileStats) onSubmit,
    VoidCallback? onSkip,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProfileStatsForm(onSubmit: onSubmit, onSkip: onSkip ?? () {}),
        ),
      ),
    );
  }

  testWidgets('spiega a cosa servono invece di chiederli e basta', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onSubmit: (_) {}));

    expect(find.textContaining('calorie'), findsOneWidget);
  });

  testWidgets('si puo saltare', (tester) async {
    var skipped = 0;
    await tester.pumpWidget(wrap(onSubmit: (_) {}, onSkip: () => skipped++));

    await tester.tap(find.text('Lo faccio dopo'));

    expect(skipped, 1);
  });

  testWidgets('consegna peso e altezza inseriti', (tester) async {
    ProfileStats? submitted;
    await tester.pumpWidget(wrap(onSubmit: (value) => submitted = value));

    await tester.enterText(find.byKey(const Key('profile-weight')), '72.5');
    await tester.enterText(find.byKey(const Key('profile-height')), '178');
    await tester.tap(find.text('ENTRA IN GYMCORPUS'));
    await tester.pump();

    expect(submitted?.weight, 72.5);
    expect(submitted?.height, 178);
  });

  testWidgets('accetta la virgola come separatore decimale', (tester) async {
    // Sulla tastiera italiana il separatore e' la virgola: rifiutarla
    // significherebbe rifiutare il modo normale di scrivere 72,5.
    ProfileStats? submitted;
    await tester.pumpWidget(wrap(onSubmit: (value) => submitted = value));

    await tester.enterText(find.byKey(const Key('profile-weight')), '72,5');
    await tester.tap(find.text('ENTRA IN GYMCORPUS'));
    await tester.pump();

    expect(submitted?.weight, 72.5);
  });

  testWidgets('un valore fuori scala viene rifiutato', (tester) async {
    ProfileStats? submitted;
    await tester.pumpWidget(wrap(onSubmit: (value) => submitted = value));

    await tester.enterText(find.byKey(const Key('profile-weight')), '700');
    await tester.tap(find.text('ENTRA IN GYMCORPUS'));
    await tester.pump();

    expect(submitted, isNull);
    expect(find.textContaining('peso'), findsWidgets);
  });

  testWidgets('un campo lasciato vuoto resta semplicemente non indicato', (
    tester,
  ) async {
    ProfileStats? submitted;
    await tester.pumpWidget(wrap(onSubmit: (value) => submitted = value));

    await tester.enterText(find.byKey(const Key('profile-height')), '178');
    await tester.tap(find.text('ENTRA IN GYMCORPUS'));
    await tester.pump();

    expect(submitted?.weight, isNull);
    expect(submitted?.height, 178);
  });
}
