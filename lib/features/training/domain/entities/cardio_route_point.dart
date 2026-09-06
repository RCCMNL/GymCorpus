import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Un punto del percorso cardio, con il momento in cui e' stato raccolto.
///
/// `elapsedSeconds` sono i secondi dall'inizio della sessione. E' nullo per
/// i percorsi salvati prima che il tempo venisse registrato: quelle sessioni
/// restano leggibili, semplicemente non hanno passaggi al chilometro.
class CardioRoutePoint extends Equatable {
  const CardioRoutePoint({required this.position, this.elapsedSeconds});

  final LatLng position;
  final int? elapsedSeconds;

  double get latitude => position.latitude;
  double get longitude => position.longitude;

  Map<String, dynamic> toJson() => {
    'lat': position.latitude,
    'lng': position.longitude,
    if (elapsedSeconds != null) 't': elapsedSeconds,
  };

  /// Interpreta un singolo punto, restituendo `null` se inutilizzabile.
  ///
  /// Un tempo malformato non fa perdere il punto: le coordinate restano
  /// valide e la mappa si disegna comunque.
  static CardioRoutePoint? tryParse(Object? raw) {
    if (raw is! Map) return null;

    final lat = raw['lat'];
    final lng = raw['lng'];
    if (lat is! num || lng is! num) return null;

    final elapsed = raw['t'];
    return CardioRoutePoint(
      position: LatLng(lat.toDouble(), lng.toDouble()),
      elapsedSeconds: elapsed is num ? elapsed.toInt() : null,
    );
  }

  /// Interpreta una lista gia' decodificata, scartando i soli punti rotti.
  static List<CardioRoutePoint> parseList(Object? raw) {
    if (raw is! List) return const [];

    final points = <CardioRoutePoint>[];
    for (final entry in raw) {
      final point = tryParse(entry);
      if (point != null) points.add(point);
    }
    return points;
  }

  /// Interpreta un percorso salvato come stringa JSON.
  static List<CardioRoutePoint> decode(String raw) {
    if (raw.isEmpty) return const [];
    try {
      return parseList(jsonDecode(raw));
    } catch (e) {
      debugPrint('CardioRoutePoint: percorso non interpretabile: $e');
      return const [];
    }
  }

  static String encode(List<CardioRoutePoint> points) =>
      jsonEncode(points.map((p) => p.toJson()).toList());

  @override
  List<Object?> get props => [position, elapsedSeconds];
}
