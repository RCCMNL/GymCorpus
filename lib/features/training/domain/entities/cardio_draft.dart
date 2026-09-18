import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';

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

  /// Percorso con i tempi di passaggio: riprendendo una sessione i passaggi
  /// al chilometro gia' percorsi devono sopravvivere all'interruzione.
  final List<CardioRoutePoint> route;

  /// Vero se la bozza appartiene a [activity].
  ///
  /// Una bozza di corsa ripresa dentro una sessione di vogatore finirebbe
  /// salvata come vogatore, con tanto di percorso GPS: distanza, tempo e
  /// tracciato di un allenamento che non e' mai esistito.
  bool isFor(CardioActivity activity) => type == activity.id;

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
        route: CardioRoutePoint.parseList(decoded['route']),
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
    'route': route.map((p) => p.toJson()).toList(),
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
