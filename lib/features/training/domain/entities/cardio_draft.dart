import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Sessione cardio interrotta, salvata periodicamente per poterla riprendere
/// dopo una chiusura imprevista dell'app.
///
/// Serializzazione e lettura vivono qui insieme di proposito: quando le due
/// parti stanno in punti diversi del codice e' facile aggiungere un campo da
/// un lato e dimenticarlo dall'altro.
class CardioDraft extends Equatable {
  const CardioDraft({
    required this.type,
    required this.elapsedSeconds,
    required this.distanceMeters,
    required this.steps,
    required this.startTime,
    required this.route,
  });

  /// Tipo usato quando la bozza non ne indica uno valido.
  static const defaultType = 'run';

  final String type; // 'run' oppure 'walk'
  final int elapsedSeconds;
  final double distanceMeters;
  final int steps;
  final DateTime? startTime;
  final List<LatLng> route;

  /// Interpreta una bozza salvata, restituendo `null` se non e' utilizzabile.
  ///
  /// Il JSON puo' essere stato scritto da una versione diversa dell'app o
  /// troncato da un crash a meta' scrittura, quindi ogni campo viene
  /// verificato invece che convertito con un cast: un valore inatteso ricade
  /// sul proprio default e una coordinata malformata scarta solo quel punto,
  /// senza far fallire l'intero ripristino.
  static CardioDraft? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final route = <LatLng>[];
      final rawRoute = decoded['route'];
      if (rawRoute is List) {
        for (final point in rawRoute) {
          if (point is! Map) continue;
          final lat = point['lat'];
          final lng = point['lng'];
          if (lat is num && lng is num) {
            route.add(LatLng(lat.toDouble(), lng.toDouble()));
          }
        }
      }

      final type = decoded['type'];
      final elapsed = decoded['elapsedSeconds'];
      final distance = decoded['distanceMeters'];
      final steps = decoded['steps'];
      final startTime = decoded['startTime'];

      return CardioDraft(
        type: type is String && type.isNotEmpty ? type : defaultType,
        elapsedSeconds: elapsed is num ? elapsed.toInt() : 0,
        distanceMeters: distance is num ? distance.toDouble() : 0,
        steps: steps is num ? steps.toInt() : 0,
        startTime: startTime is String ? DateTime.tryParse(startTime) : null,
        route: route,
      );
    } catch (e) {
      debugPrint('CardioDraft: bozza non interpretabile: $e');
      return null;
    }
  }

  String encode() => jsonEncode({
    'type': type,
    'distanceMeters': distanceMeters,
    'elapsedSeconds': elapsedSeconds,
    'steps': steps,
    'startTime': startTime?.toIso8601String(),
    'route': route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
  });

  @override
  List<Object?> get props => [
    type,
    elapsedSeconds,
    distanceMeters,
    steps,
    startTime,
    route,
  ];
}
