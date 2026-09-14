import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:latlong2/latlong.dart';

/// I percorsi salvati prima di questa versione contengono solo lat e lng.
/// Devono continuare ad aprirsi: l'assenza del tempo toglie gli split, non
/// la sessione.
void main() {
  group('tryParse', () {
    test('legge coordinate e tempo trascorso', () {
      final point = CardioRoutePoint.tryParse({
        'lat': 45.1,
        'lng': 9.2,
        't': 42,
      })!;

      expect(point.position, const LatLng(45.1, 9.2));
      expect(point.elapsedSeconds, 42);
    });

    test('accetta il vecchio formato senza tempo', () {
      final point = CardioRoutePoint.tryParse({'lat': 45.1, 'lng': 9.2})!;

      expect(point.position, const LatLng(45.1, 9.2));
      expect(point.elapsedSeconds, isNull);
    });

    test('rifiuta un punto senza coordinate utilizzabili', () {
      expect(CardioRoutePoint.tryParse({'lat': 45.1}), isNull);
      expect(CardioRoutePoint.tryParse({'lat': 'nord', 'lng': 9.2}), isNull);
      expect(CardioRoutePoint.tryParse('45.1, 9.2'), isNull);
      expect(CardioRoutePoint.tryParse(null), isNull);
    });

    test('ignora un tempo non numerico invece di scartare il punto', () {
      final point = CardioRoutePoint.tryParse({
        'lat': 45.1,
        'lng': 9.2,
        't': 'poco',
      })!;

      expect(point.elapsedSeconds, isNull);
    });
  });

  group('parseList', () {
    test('scarta i punti malformati e conserva gli altri', () {
      final points = CardioRoutePoint.parseList([
        {'lat': 45.1, 'lng': 9.2, 't': 0},
        {'lat': 45.2},
        'rumore',
        {'lat': 45.3, 'lng': 9.4, 't': 60},
      ]);

      expect(points, hasLength(2));
      expect(points.first.elapsedSeconds, 0);
      expect(points.last.elapsedSeconds, 60);
    });

    test('restituisce una lista vuota se non e una lista', () {
      expect(CardioRoutePoint.parseList(null), isEmpty);
      expect(CardioRoutePoint.parseList({'lat': 45.1}), isEmpty);
    });
  });

  group('decode', () {
    test('legge un percorso salvato come stringa JSON', () {
      final points = CardioRoutePoint.decode(
        '[{"lat":45.1,"lng":9.2,"t":0},{"lat":45.2,"lng":9.3,"t":30}]',
      );

      expect(points, hasLength(2));
      expect(points.last.elapsedSeconds, 30);
    });

    test('restituisce una lista vuota su contenuto inutilizzabile', () {
      expect(CardioRoutePoint.decode(''), isEmpty);
      expect(CardioRoutePoint.decode('non json'), isEmpty);
      expect(CardioRoutePoint.decode('{"lat":45.1}'), isEmpty);
    });
  });

  group('encode', () {
    test('un percorso codificato si rilegge identico', () {
      const points = [
        CardioRoutePoint(position: LatLng(45.1, 9.2), elapsedSeconds: 0),
        CardioRoutePoint(position: LatLng(45.2, 9.3), elapsedSeconds: 30),
      ];

      expect(CardioRoutePoint.decode(CardioRoutePoint.encode(points)), points);
    });

    test('non scrive la chiave del tempo quando il tempo non c e', () {
      const points = [CardioRoutePoint(position: LatLng(45.1, 9.2))];

      expect(CardioRoutePoint.encode(points), '[{"lat":45.1,"lng":9.2}]');
    });
  });
}
