import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/legal_consent_field.dart';

/// Il consenso legale serve in due punti: nel form di registrazione e prima
/// di autenticarsi con un provider esterno, perche' l'account non va creato
/// se i termini non sono accettati.
void main() {
  Widget wrap({required bool value, required ValueChanged<bool> onChanged}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: LegalConsentField(value: value, onChanged: onChanged),
          ),
        ),
        GoRoute(
          path: '/legal/consent',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Termini'))),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('nomina entrambi i documenti che si stanno accettando', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(value: false, onChanged: (_) {}));

    expect(find.text('Accetto Termini e Privacy Policy'), findsOneWidget);
  });

  testWidgets('spuntando la casella lo comunica', (tester) async {
    bool? accepted;
    await tester.pumpWidget(
      wrap(value: false, onChanged: (value) => accepted = value),
    );

    await tester.tap(find.byType(Checkbox));

    expect(accepted, isTrue);
  });

  testWidgets('i termini si possono leggere prima di accettarli', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(value: false, onChanged: (_) {}));

    await tester.tap(find.text('Leggi i termini'));
    await tester.pumpAndSettle();

    expect(find.text('Termini'), findsOneWidget);
  });
}
