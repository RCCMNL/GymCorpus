import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/login_history_tile.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/security_item.dart';

/// Pezzi estratti da SecurityScreen, che era diventata un file da 900 righe
/// con tre classi dentro.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('SecurityItem', () {
    testWidgets('mostra etichetta e icona', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SecurityItem(
            icon: Icons.lock_outline,
            label: 'Cambia Password',
          ),
        ),
      );

      expect(find.text('Cambia Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('il tap invoca l azione', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(SecurityItem(label: 'Voce', onTap: () => taps++)),
      );

      await tester.tap(find.text('Voce'));

      expect(taps, 1);
    });

    testWidgets('senza azione non mostra la freccia', (tester) async {
      // Una freccia su una riga che non porta da nessuna parte promette una
      // navigazione che non esiste.
      await tester.pumpWidget(wrap(const SecurityItem(label: 'Solo testo')));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('il contenuto in coda prende il posto della freccia', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          SecurityItem(
            label: 'Biometrico',
            onTap: () {},
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('AuthProviderBadge', () {
    testWidgets('dice se il provider e collegato', (tester) async {
      await tester.pumpWidget(wrap(const AuthProviderBadge(isLinked: true)));

      expect(find.text('COLLEGATO'), findsOneWidget);
    });

    testWidgets('dice anche quando non lo e', (tester) async {
      await tester.pumpWidget(wrap(const AuthProviderBadge(isLinked: false)));

      expect(find.text('NON COLLEGATO'), findsOneWidget);
    });
  });

  group('LoginHistoryTile', () {
    final login = LoginEntry(
      date: DateTime(2026, 9, 4, 18, 30),
      device: 'Pixel 8',
    );

    testWidgets('il primo accesso e quello attuale', (tester) async {
      await tester.pumpWidget(
        wrap(LoginHistoryTile(login: login, isCurrent: true)),
      );

      expect(find.text('Pixel 8'), findsOneWidget);
      expect(find.textContaining('Ultimo accesso'), findsOneWidget);
      expect(find.text('ATTIVO'), findsOneWidget);
    });

    testWidgets('gli altri sono accessi precedenti, senza badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(LoginHistoryTile(login: login, isCurrent: false)),
      );

      expect(find.textContaining('Accesso precedente'), findsOneWidget);
      expect(find.text('ATTIVO'), findsNothing);
    });

    testWidgets('la data e leggibile in italiano', (tester) async {
      await tester.pumpWidget(
        wrap(LoginHistoryTile(login: login, isCurrent: true)),
      );

      expect(find.textContaining('04 set 2026, 18:30'), findsOneWidget);
    });
  });
}
