import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/sign_up_progress.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(theme: AppTheme.darkTheme, home: Scaffold(body: child)),
  );
}

void main() {
  group('SignUpTopBar', () {
    testWidgets('dice a che passo siamo', (tester) async {
      await _pump(tester, SignUpTopBar(currentStep: 0, onBack: () {}));

      expect(find.text('Passo 1 di 2'), findsOneWidget);
    });

    testWidgets('al secondo passo cambia il conteggio', (tester) async {
      await _pump(tester, SignUpTopBar(currentStep: 1, onBack: () {}));

      expect(find.text('Passo 2 di 2'), findsOneWidget);
    });

    testWidgets('la freccia indietro avvisa chi l ha messa', (tester) async {
      var indietro = false;
      await _pump(
        tester,
        SignUpTopBar(currentStep: 1, onBack: () => indietro = true),
      );

      await tester.tap(find.byType(IconButton));

      expect(indietro, isTrue);
    });
  });

  group('SignUpStepIndicator', () {
    testWidgets('mostra i due pallini del percorso', (tester) async {
      await _pump(tester, const SignUpStepIndicator(currentStep: 0));

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });
  });
}
