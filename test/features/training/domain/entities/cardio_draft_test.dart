import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_draft.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:latlong2/latlong.dart';

/// La bozza cardio decide se una sessione interrotta e' recuperabile.
///
/// Viene letta da JSON che puo' essere stato scritto da una versione diversa
/// dell'app o troncato da un crash a meta' scrittura: il comportamento sui
/// dati malformati e' quindi la parte che conta davvero.
void main() {
  const validJson = '''
{
  "type": "walk",
  "distanceMeters": 1234.5,
  "elapsedSeconds": 600,
  "steps": 1500,
  "startTime": "2026-08-12T10:30:00.000",
  "route": [
    {"lat": 45.1, "lng": 9.2, "t": 0},
    {"lat": 45.2, "lng": 9.3, "t": 300}
  ]
}
''';

  group('tryParse', () {
    test('legge una bozza completa', () {
      final draft = CardioDraft.tryParse(validJson)!;

      expect(draft.type, 'walk');
      expect(draft.distanceMeters, 1234.5);
      expect(draft.elapsedSeconds, 600);
      expect(draft.steps, 1500);
      expect(draft.startTime, DateTime(2026, 8, 12, 10, 30));
      expect(draft.route, const [
        CardioRoutePoint(position: LatLng(45.1, 9.2), elapsedSeconds: 0),
        CardioRoutePoint(position: LatLng(45.2, 9.3), elapsedSeconds: 300),
      ]);
    });

    test('una bozza scritta prima dei tempi resta recuperabile', () {
      // Le bozze salvate dalla versione precedente non hanno il campo "t":
      // la sessione deve riprendere lo stesso, perdendo i soli split.
      final draft = CardioDraft.tryParse(
        jsonEncode({
          'route': [
            {'lat': 45.1, 'lng': 9.2},
          ],
        }),
      )!;

      expect(draft.route.single.position, const LatLng(45.1, 9.2));
      expect(draft.route.single.elapsedSeconds, isNull);
    });

    test('restituisce null se il JSON e troncato a meta', () {
      // Caso tipico di una scrittura interrotta da un crash.
      final truncated = validJson.substring(0, validJson.length ~/ 2);

      expect(CardioDraft.tryParse(truncated), isNull);
    });

    test('restituisce null se il contenuto non e un oggetto JSON', () {
      expect(CardioDraft.tryParse('[]'), isNull);
      expect(CardioDraft.tryParse('"testo"'), isNull);
      expect(CardioDraft.tryParse('42'), isNull);
      expect(CardioDraft.tryParse(''), isNull);
    });

    test('accetta numeri interi scritti come decimali', () {
      // Una bozza salvata come 600.0 non deve far fallire il ripristino:
      // era esattamente il caso che rompeva il vecchio cast diretto a int.
      final draft = CardioDraft.tryParse(
        jsonEncode({'elapsedSeconds': 600.0, 'steps': 1500.0}),
      )!;

      expect(draft.elapsedSeconds, 600);
      expect(draft.steps, 1500);
    });

    test('ricade sui default quando i campi hanno il tipo sbagliato', () {
      final draft = CardioDraft.tryParse(
        jsonEncode({
          'type': 42,
          'distanceMeters': 'molta',
          'elapsedSeconds': null,
          'steps': <String>[],
          'startTime': 12345,
        }),
      )!;

      expect(draft.type, CardioDraft.defaultType);
      expect(draft.distanceMeters, 0);
      expect(draft.elapsedSeconds, 0);
      expect(draft.steps, 0);
      expect(draft.startTime, isNull);
      expect(draft.route, isEmpty);
    });

    test('startTime non valido non invalida il resto della bozza', () {
      final draft = CardioDraft.tryParse(
        jsonEncode({'elapsedSeconds': 120, 'startTime': 'non-una-data'}),
      )!;

      expect(draft.startTime, isNull);
      expect(draft.elapsedSeconds, 120);
    });

    test('scarta solo le coordinate malformate, non tutto il percorso', () {
      final draft = CardioDraft.tryParse(
        jsonEncode({
          'route': [
            {'lat': 45.1, 'lng': 9.2, 't': 0},
            {'lat': 'rotto', 'lng': 9.3},
            {'lat': 45.3},
            'non-un-oggetto',
            {'lat': 45.4, 'lng': 9.5, 't': 60},
          ],
        }),
      )!;

      expect(draft.route, const [
        CardioRoutePoint(position: LatLng(45.1, 9.2), elapsedSeconds: 0),
        CardioRoutePoint(position: LatLng(45.4, 9.5), elapsedSeconds: 60),
      ], reason: 'un punto rotto non deve far perdere gli altri');
    });

    test('un percorso di tipo inatteso lascia la rotta vuota', () {
      final draft = CardioDraft.tryParse(jsonEncode({'route': 'niente'}))!;

      expect(draft.route, isEmpty);
    });
  });

  group('encode', () {
    test('un giro completo di scrittura e rilettura preserva i dati', () {
      // Scrittura e lettura vivono nella stessa classe proprio per non
      // divergere: questo test lo verifica su tutti i campi insieme.
      final original = CardioDraft(
        type: 'run',
        elapsedSeconds: 930,
        distanceMeters: 2750.5,
        steps: 3120,
        startTime: DateTime(2026, 8, 12, 7, 15, 30),
        route: const [
          CardioRoutePoint(position: LatLng(45.4642, 9.19), elapsedSeconds: 0),
          CardioRoutePoint(
            position: LatLng(45.4643, 9.1901),
            elapsedSeconds: 930,
          ),
        ],
      );

      final restored = CardioDraft.tryParse(original.encode());

      expect(restored, original);
    });

    test('preserva una bozza senza orario di inizio e senza percorso', () {
      const original = CardioDraft(
        type: 'walk',
        elapsedSeconds: 0,
        distanceMeters: 0,
        steps: 0,
        startTime: null,
        route: [],
      );

      expect(CardioDraft.tryParse(original.encode()), original);
    });
  });

  group('CardioDraft.isFor', () {
    const draft = CardioDraft(
      type: 'run',
      elapsedSeconds: 600,
      distanceMeters: 1500,
      steps: 0,
      startTime: null,
      route: [],
    );

    test('vale per l attivita con cui e stata scritta', () {
      expect(draft.isFor(CardioActivity.run), isTrue);
    });

    test('non vale per un altra attivita', () {
      expect(draft.isFor(CardioActivity.bike), isFalse);
      expect(draft.isFor(CardioActivity.treadmill), isFalse);
    });
  });
}
