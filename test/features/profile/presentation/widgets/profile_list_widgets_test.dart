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
  });
}
