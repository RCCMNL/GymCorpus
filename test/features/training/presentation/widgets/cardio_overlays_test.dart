import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_overlays.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('GpsSearchingOverlay', () {
    testWidgets('mostra il messaggio di ricerca segnale', (tester) async {
      await tester.pumpWidget(wrap(const GpsSearchingOverlay()));
      expect(find.text('RICERCA SEGNALE GPS...'), findsOneWidget);
    });
  });

  group('CountdownOverlay', () {
    testWidgets('mostra il numero del countdown', (tester) async {
      await tester.pumpWidget(wrap(const CountdownOverlay(countdown: 3)));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('mostra VIA! quando il countdown arriva a 0', (tester) async {
      await tester.pumpWidget(wrap(const CountdownOverlay(countdown: 0)));
      expect(find.text('VIA!'), findsOneWidget);
    });
  });

  group('ManualPauseOverlay', () {
    testWidgets('mostra "SESSIONE IN PAUSA" e invoca onResume', (tester) async {
      var resumed = false;
      await tester.pumpWidget(
        wrap(ManualPauseOverlay(onResume: () => resumed = true)),
      );

      expect(find.text('SESSIONE IN PAUSA'), findsOneWidget);
      await tester.tap(find.text('RIPRENDI'));
      expect(resumed, isTrue);
    });
  });

  group('AutoPauseOverlay', () {
    testWidgets('mostra "IN PAUSA" e invoca onDismiss al tocco', (
      tester,
    ) async {
      var dismissed = false;
      await tester.pumpWidget(
        wrap(AutoPauseOverlay(onDismiss: () => dismissed = true)),
      );

      expect(find.text('IN PAUSA'), findsOneWidget);
      expect(find.text('Rilevato stop.'), findsOneWidget);

      await tester.tap(find.byType(AutoPauseOverlay));
      expect(dismissed, isTrue);
    });
  });

  group('CardioMilestoneBanner', () {
    testWidgets('mostra il messaggio del traguardo raggiunto', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardioMilestoneBanner(
              title: '1 km',
              subtitle: '05:40 al chilometro',
            ),
          ),
        ),
      );

      expect(find.text('1 km'), findsOneWidget);
      expect(find.text('05:40 al chilometro'), findsOneWidget);
    });

    testWidgets('senza dettaglio mostra solo il titolo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardioMilestoneBanner(title: 'Obiettivo raggiunto'),
          ),
        ),
      );

      expect(find.text('Obiettivo raggiunto'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });
  });
}
