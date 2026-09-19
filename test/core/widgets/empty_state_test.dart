import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/empty_state.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('EmptyState', () {
    testWidgets('dice cosa manca e perche', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Nessun preferito',
            message: 'Aggiungi esercizi ai preferiti per trovarli qui.',
          ),
        ),
      );

      expect(find.text('Nessun preferito'), findsOneWidget);
      expect(
        find.text('Aggiungi esercizi ai preferiti per trovarli qui.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });

    testWidgets("l'icona e quella della casa, non un cerchio a mano", (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Nessuna notifica',
            message: 'Appariranno qui.',
          ),
        ),
      );

      // Tre schermate si disegnavano il proprio cerchio: una Container da
      // 80 con l'icona al 50%, una IconBadge tinta, una neutra. Adesso e'
      // sempre la stessa pastiglia.
      expect(find.byType(IconBadge), findsOneWidget);
    });

    testWidgets('senza azione non c e un pulsante', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(
            icon: Icons.inbox_rounded,
            title: 'Vuoto',
            message: 'Non c e niente.',
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('con un azione, il gesto che riempie il vuoto e li', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        wrap(
          EmptyState(
            icon: Icons.add_rounded,
            title: 'Nessun workout creato',
            message: 'Creane uno.',
            action: FilledButton(
              onPressed: () => tapped = true,
              child: const Text('NUOVO'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('NUOVO'));
      expect(tapped, isTrue);
    });

    testWidgets('non e un riquadro: sta dove lo si mette', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EmptyState(
            icon: Icons.inbox_rounded,
            title: 'Vuoto',
            message: 'Non c e niente.',
          ),
        ),
      );

      // Il guscio lo mette EmptyStateCard, quando serve: dentro una
      // pagina che scorre il riquadro e' giusto, a schermo pieno no.
      expect(find.byType(AppCard), findsNothing);
    });
  });

  group('EmptyStateCard', () {
    testWidgets('e lo stesso messaggio, dentro un riquadro', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EmptyStateCard(
            icon: Icons.straighten_rounded,
            title: 'Nessuna misura salvata',
            message: 'Registra la prima.',
          ),
        ),
      );

      expect(find.byType(AppCard), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Nessuna misura salvata'), findsOneWidget);
    });
  });
}
