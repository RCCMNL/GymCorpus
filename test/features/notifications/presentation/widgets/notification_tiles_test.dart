import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/notifications/presentation/widgets/notification_tiles.dart';

/// Pezzi estratti da NotificationSettingsScreen, che teneva 750 righe fra
/// logica di scheduling e widget di presentazione.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('NotificationSwitchTile', () {
    testWidgets('mostra etichetta e spiegazione', (tester) async {
      await tester.pumpWidget(
        wrap(
          NotificationSwitchTile(
            label: 'Stretching',
            subtitle: 'Ogni giorno alla stessa ora',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Stretching'), findsOneWidget);
      expect(find.text('Ogni giorno alla stessa ora'), findsOneWidget);
    });

    testWidgets('comunica il cambio di stato', (tester) async {
      bool? changed;
      await tester.pumpWidget(
        wrap(
          NotificationSwitchTile(
            label: 'Stretching',
            subtitle: 'sottotitolo',
            value: false,
            onChanged: (value) => changed = value,
          ),
        ),
      );

      await tester.tap(find.byType(Switch));

      expect(changed, isTrue);
    });
  });

  group('NotificationTimeTile', () {
    testWidgets('mostra l orario con due cifre', (tester) async {
      await tester.pumpWidget(
        wrap(
          NotificationTimeTile(
            label: 'Orario',
            time: const TimeOfDay(hour: 9, minute: 5),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('09:05'), findsOneWidget);
    });

    testWidgets('il tap apre la scelta dell orario', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          NotificationTimeTile(
            label: 'Orario',
            time: const TimeOfDay(hour: 20, minute: 30),
            onTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('20:30'));

      expect(taps, 1);
    });
  });

  group('WeekDaySelector', () {
    testWidgets('mostra i sette giorni della settimana', (tester) async {
      await tester.pumpWidget(
        wrap(WeekDaySelector(selectedDays: const {}, onToggle: (_) {})),
      );

      expect(find.text('L'), findsOneWidget);
      expect(find.text('M'), findsNWidgets(2));
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('il tocco su un giorno lo comunica col numero giusto', (
      tester,
    ) async {
      // 1 e' lunedi' e 7 domenica, come in DateTime: sbagliare qui
      // sposterebbe i promemoria di un giorno.
      final toggled = <int>[];
      await tester.pumpWidget(
        wrap(WeekDaySelector(selectedDays: const {}, onToggle: toggled.add)),
      );

      await tester.tap(find.text('L'));
      await tester.tap(find.text('D'));

      expect(toggled, [1, 7]);
    });
  });
}
