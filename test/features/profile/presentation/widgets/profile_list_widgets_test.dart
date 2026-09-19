import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_list_widgets.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('ProfileSection', () {
    testWidgets('mostra titolo e le ProfileItem passate', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ProfileSection(
            title: 'Account',
            items: [
              ProfileItem(icon: Icons.person, label: 'Modifica Profilo'),
              ProfileItem(icon: Icons.lock, label: 'Sicurezza'),
            ],
          ),
        ),
      );

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Modifica Profilo'), findsOneWidget);
      expect(find.text('Sicurezza'), findsOneWidget);
    });
  });

  group('ProfileItem', () {
    testWidgets('il tap invoca onTap quando presente', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrap(
          ProfileItem(
            icon: Icons.person,
            label: 'Modifica Profilo',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Modifica Profilo'));
      expect(tapped, isTrue);
    });

    testWidgets('mostra il badge Prossimamente quando trailingText lo indica', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ProfileItem(
            icon: Icons.star,
            label: 'Valuta GymCorpus',
            trailingText: 'Prossimamente',
            isBadge: true,
          ),
        ),
      );

      expect(find.text('Prossimamente'), findsOneWidget);
    });

    testWidgets('mostra il widget trailing personalizzato (es. uno switch)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ProfileItem(
            icon: Icons.volume_up_rounded,
            label: 'Effetti Audio',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('mostra la freccia di navigazione quando non ci sono '
        'trailingText/trailing/badge', (tester) async {
      await tester.pumpWidget(
        wrap(const ProfileItem(icon: Icons.person, label: 'Voce semplice')),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    // Il colore dell'icona si decideva confrontando l'etichetta scritta a
    // schermo: 'Sicurezza' era menta, 'Valuta GymCorpus' arancione, tutto
    // il resto periwinkle. Riscrivere una voce - o tradurla - le cambiava
    // colore in silenzio, senza che nessuno avesse chiesto niente.
    Color iconColorOf(WidgetTester tester) =>
        tester.widget<Icon>(find.byType(Icon).first).color!;

    testWidgets('il tono e quello chiesto, non quello dedotto dal testo', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ProfileItem(
            icon: Icons.lock,
            label: 'Sicurezza',
            tone: ProfileItemTone.secondary,
          ),
        ),
      );
      final beforeRename = iconColorOf(tester);

      await tester.pumpWidget(
        wrap(
          const ProfileItem(
            icon: Icons.lock,
            label: 'Sicurezza e accesso',
            tone: ProfileItemTone.secondary,
          ),
        ),
      );

      expect(iconColorOf(tester), beforeRename);
    });

    testWidgets('toni diversi, colori diversi', (tester) async {
      final colors = <ProfileItemTone, Color>{};

      for (final tone in ProfileItemTone.values) {
        await tester.pumpWidget(
          wrap(ProfileItem(icon: Icons.person, label: 'Una voce', tone: tone)),
        );
        colors[tone] = iconColorOf(tester);
      }

      expect(
        colors.values.toSet(),
        hasLength(ProfileItemTone.values.length),
        reason:
            'due toni che finiscono sullo stesso colore sono un tono solo '
            'con due nomi: $colors',
      );
    });

    testWidgets('la voce in arrivo e smorzata anche senza badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ProfileItem(
            icon: Icons.emoji_events,
            label: 'Classifica Utenti',
            isComingSoon: true,
          ),
        ),
      );

      final theme = ThemeData();
      expect(iconColorOf(tester), isNot(theme.colorScheme.primary));
    });
  });
}
