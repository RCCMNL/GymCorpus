import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/progress_hero.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('tab Peso (activeTab: 0)', () {
    testWidgets('senza log ne peso profilo mostra --', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ProgressHero(
            logs: [],
            profileWeight: null,
            measurements: [],
            settings: {},
            activeTab: 0,
          ),
        ),
      );

      expect(find.text('--'), findsOneWidget);
      expect(find.text('Nessun peso registrato'), findsOneWidget);
    });

    testWidgets('senza log ma con peso profilo mostra il peso profilo', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ProgressHero(
            logs: [],
            profileWeight: 75,
            measurements: [],
            settings: {},
            activeTab: 0,
          ),
        ),
      );

      expect(find.text('75.0 kg'), findsOneWidget);
      expect(find.text('Peso attuale dal profilo'), findsOneWidget);
    });

    testWidgets("con log mostra l'ultimo peso e il badge di variazione", (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ProgressHero(
            logs: [
              BodyWeightLogEntity(
                id: 1,
                weight: 79,
                date: DateTime(2026, 1, 2),
              ),
              BodyWeightLogEntity(id: 2, weight: 80, date: DateTime(2026)),
            ],
            profileWeight: null,
            measurements: const [],
            settings: const {},
            activeTab: 0,
          ),
        ),
      );

      expect(find.text('79.0 kg'), findsOneWidget);
      expect(find.text('Ultimo peso registrato'), findsOneWidget);
      // -1.0 kg rispetto al log precedente.
      expect(find.text('-1.0 kg'), findsOneWidget);
    });

    testWidgets('mostra il peso in libbre quando le impostazioni sono LB', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ProgressHero(
            logs: [],
            profileWeight: 100,
            measurements: [],
            settings: {'units': 'LB'},
            activeTab: 0,
          ),
        ),
      );

      expect(find.text('220.5 lb'), findsOneWidget);
    });
  });

  group('tab Misure (activeTab: 1)', () {
    testWidgets(
      'mostra il conteggio delle aree monitorate, chiuso di default',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            ProgressHero(
              logs: const [],
              profileWeight: null,
              measurements: [
                BodyMeasurementEntity(
                  part: 'Petto',
                  value: 100,
                  date: DateTime(2026),
                ),
                BodyMeasurementEntity(
                  part: 'Vita',
                  value: 80,
                  date: DateTime(2026),
                ),
              ],
              settings: const {},
              activeTab: 1,
            ),
          ),
        );

        expect(find.text('Stato Attuale'), findsOneWidget);
        expect(find.text('2 aree monitorate'), findsOneWidget);
        expect(find.text('100.0 cm'), findsNothing);
      },
    );

    testWidgets('il tap espande e mostra i valori delle misure', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ProgressHero(
            logs: const [],
            profileWeight: null,
            measurements: [
              BodyMeasurementEntity(
                part: 'Petto',
                value: 100,
                date: DateTime(2026),
              ),
            ],
            settings: const {},
            activeTab: 1,
          ),
        ),
      );

      await tester.tap(find.text('Stato Attuale'));
      await tester.pump();

      expect(find.text('100.0 cm'), findsOneWidget);
      expect(find.text('PETTO'), findsOneWidget);
    });
  });
}
