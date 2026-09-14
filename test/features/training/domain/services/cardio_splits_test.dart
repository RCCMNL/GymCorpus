import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:gym_corpus/features/training/domain/services/cardio_splits.dart';
import 'package:latlong2/latlong.dart';

/// Gli split non sono salvati: si ricavano dal percorso ogni volta che si
/// apre una sessione. Qui si fissa quel calcolo, compreso il caso in cui il
/// percorso non porti alcun tempo.
void main() {
  const origin = LatLng(45, 9);
  const geo = Distance();

  /// Costruisce un percorso rettilineo verso nord dalle distanze cumulate.
  List<CardioRoutePoint> routeOf(
    List<double> cumulativeMeters, {
    bool withTime = true,
    double secondsPerMeter = 0.3,
  }) {
    return [
      for (final meters in cumulativeMeters)
        CardioRoutePoint(
          position: meters == 0 ? origin : geo.offset(origin, meters, 0),
          elapsedSeconds: withTime ? (meters * secondsPerMeter).round() : null,
        ),
    ];
  }

  group('percorsi senza split calcolabili', () {
    test('un percorso senza tempi non produce split', () {
      final splits = CardioSplits.fromRoute(
        routeOf([0, 1000, 2000], withTime: false),
      );

      expect(splits, isEmpty);
    });

    test('meno di due punti non producono split', () {
      expect(CardioSplits.fromRoute(routeOf([0])), isEmpty);
      expect(CardioSplits.fromRoute(const []), isEmpty);
    });

    test('un percorso piu corto di un chilometro da solo il tratto finale', () {
      final splits = CardioSplits.fromRoute(routeOf([0, 400]));

      expect(splits, hasLength(1));
      expect(splits.single.isPartial, isTrue);
      expect(splits.single.distanceKm, closeTo(0.4, 0.01));
    });
  });

  group('chilometri completi', () {
    test('due chilometri ad andatura costante danno due split uguali', () {
      final splits = CardioSplits.fromRoute(
        routeOf([for (var m = 0; m <= 2000; m += 100) m.toDouble()]),
      );

      expect(splits, hasLength(2));
      expect(splits[0].index, 1);
      expect(splits[0].seconds, closeTo(300, 1));
      expect(splits[1].index, 2);
      expect(splits[1].seconds, closeTo(300, 1));
      expect(splits.every((s) => s.isPartial), isFalse);
    });

    test('il passaggio al chilometro e interpolato dentro il tratto', () {
      // Due soli punti a 2 km di distanza: il primo chilometro non coincide
      // con nessun punto registrato e va ricavato dentro il segmento.
      final splits = CardioSplits.fromRoute(routeOf([0, 2000]));

      expect(splits, hasLength(2));
      expect(splits[0].seconds, closeTo(300, 1));
      expect(splits[1].seconds, closeTo(300, 1));
    });

    test('il tratto finale incompleto e marcato come parziale', () {
      final splits = CardioSplits.fromRoute(
        routeOf([for (var m = 0; m <= 2500; m += 100) m.toDouble()]),
      );

      expect(splits, hasLength(3));
      expect(splits.last.isPartial, isTrue);
      expect(splits.last.distanceKm, closeTo(0.5, 0.01));
      expect(splits.last.seconds, closeTo(150, 1));
    });

    test('un resto di pochi metri non diventa uno split', () {
      final splits = CardioSplits.fromRoute(routeOf([0, 1000, 2000, 2020]));

      expect(splits, hasLength(2));
    });
  });

  group('andatura', () {
    test('il passo di un chilometro completo e il suo stesso tempo', () {
      final splits = CardioSplits.fromRoute(routeOf([0, 1000]));

      expect(splits.single.pace, '05:00');
    });

    test('il passo di un tratto parziale e riportato al chilometro', () {
      // Mezzo chilometro in 150 secondi resta un passo di 5:00 al km.
      final splits = CardioSplits.fromRoute(routeOf([0, 500]));

      expect(splits.single.pace, '05:00');
    });
  });
}
