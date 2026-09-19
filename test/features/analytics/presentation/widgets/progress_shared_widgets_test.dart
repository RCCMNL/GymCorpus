import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/progress_shared_widgets.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('ProgressTabBar', () {
    testWidgets('mostra le tab Peso e Misure', (tester) async {
      await tester.pumpWidget(
        wrap(
          DefaultTabController(
            length: 2,
            child: Builder(
              builder: (context) =>
                  ProgressTabBar(controller: DefaultTabController.of(context)),
            ),
          ),
        ),
      );

      expect(find.text('Peso'), findsOneWidget);
      expect(find.text('Misure'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('mostra titolo, sottotitolo e azione', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SectionHeader(
            title: 'Storico peso',
            subtitle: '5 check-in registrati',
            action: Icon(Icons.add),
          ),
        ),
      );

      expect(find.text('Storico peso'), findsOneWidget);
      expect(find.text('5 check-in registrati'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('LogTile', () {
    testWidgets('mostra titolo/sottotitolo e invoca onDelete', (tester) async {
      var deleted = false;

      await tester.pumpWidget(
        wrap(
          LogTile(
            title: '80.0 kg',
            subtitle: '12 gen 2026, 08:00',
            icon: Icons.scale_rounded,
            onDelete: () => deleted = true,
          ),
        ),
      );

      expect(find.text('80.0 kg'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(deleted, isTrue);
    });
  });

  group('ProgressErrorState', () {
    testWidgets('mostra il messaggio e invoca onRetry', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        wrap(
          ProgressErrorState(
            message: 'Errore di rete',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Errore di rete'), findsOneWidget);
      await tester.tap(find.text('Ricarica dati'));
      expect(retried, isTrue);
    });
  });

  // EmptyStateCard non vive piu' qui: era il riquadro "niente da
  // mostrare" di analytics, ma dodici schermate ne avevano uno per una.
  // Ora sta in core/widgets/empty_state.dart, con i suoi test.

  group('TipLine', () {
    testWidgets('mostra il testo del suggerimento', (tester) async {
      await tester.pumpWidget(
        wrap(const TipLine(text: 'Misura sempre alla stessa ora.')),
      );

      expect(find.text('Misura sempre alla stessa ora.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
