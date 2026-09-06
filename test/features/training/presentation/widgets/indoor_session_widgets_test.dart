import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/presentation/widgets/indoor_session_widgets.dart';

/// Al chiuso non c'e' una mappa da guardare: al suo posto il cronometro, e
/// alla fine la distanza, che nessun sensore puo' misurare al posto tuo.
void main() {
  group('IndoorSessionBackdrop', () {
    Widget wrap(CardioActivity activity, {required int seconds}) => MaterialApp(
      home: Scaffold(
        body: IndoorSessionBackdrop(
          activity: activity,
          elapsedSeconds: seconds,
          isTracking: seconds > 0,
        ),
      ),
    );

    testWidgets('mostra il tempo trascorso in grande', (tester) async {
      await tester.pumpWidget(wrap(CardioActivity.treadmill, seconds: 3725));

      expect(find.text('01:02:05'), findsOneWidget);
    });

    testWidgets('sotto l ora il formato resta minuti e secondi', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(CardioActivity.rowing, seconds: 125));

      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('dice quale attivita si sta facendo', (tester) async {
      await tester.pumpWidget(wrap(CardioActivity.elliptical, seconds: 0));

      expect(find.text('ELLITTICA'), findsOneWidget);
    });
  });

  group('IndoorDistanceDialog', () {
    Future<double?> showAndTap(
      WidgetTester tester,
      Future<void> Function(BuildContext context) interact,
    ) async {
      double? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<double>(
                    context: context,
                    builder: (_) => const IndoorDistanceDialog(),
                  );
                },
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      await interact(tester.element(find.byType(IndoorDistanceDialog)));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('restituisce i chilometri inseriti', (tester) async {
      final result = await showAndTap(tester, (_) async {
        await tester.enterText(find.byType(TextField), '7,4');
        await tester.tap(find.text('SALVA'));
      });

      expect(result, 7.4);
    });

    testWidgets('si puo non indicare la distanza', (tester) async {
      final result = await showAndTap(tester, (_) async {
        await tester.tap(find.text('NON LA SO'));
      });

      expect(result, 0);
    });

    testWidgets('un valore non numerico non chiude il dialogo', (tester) async {
      await showAndTap(tester, (_) async {
        await tester.enterText(find.byType(TextField), 'tanta');
        await tester.tap(find.text('SALVA'));
      });

      expect(find.byType(IndoorDistanceDialog), findsOneWidget);
    });
  });
}
