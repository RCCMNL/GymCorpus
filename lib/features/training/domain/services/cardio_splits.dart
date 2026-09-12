import 'package:equatable/equatable.dart';
import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:latlong2/latlong.dart';

/// Un chilometro della sessione, con il tempo impiegato a percorrerlo.
class CardioSplit extends Equatable {
  const CardioSplit({
    required this.index,
    required this.distanceKm,
    required this.seconds,
    required this.isPartial,
  });

  /// Progressivo del tratto, a partire da 1.
  final int index;

  /// Distanza del tratto: 1 km, tranne l'ultimo che puo' essere piu' corto.
  final double distanceKm;

  final int seconds;

  /// L'ultimo tratto, quando la sessione si e' fermata prima del chilometro.
  final bool isPartial;

  /// Passo al chilometro in `mm:ss`, riportato al km pieno anche sui
  /// tratti parziali: mezzo chilometro in 2:30 resta un passo di 5:00.
  String get pace => formatPace(seconds: seconds, distanceKm: distanceKm);

  @override
  List<Object?> get props => [index, distanceKm, seconds, isPartial];
}

/// Ricava i passaggi al chilometro dal percorso registrato.
class CardioSplits {
  const CardioSplits._();

  /// Sotto questa soglia il tratto finale e' rumore GPS, non un tratto corso.
  static const _minPartialMeters = 50.0;

  static const _metersPerSplit = 1000.0;

  /// Restituisce una lista vuota quando il percorso non porta i tempi: sono
  /// le sessioni registrate prima che venissero salvati, e vanno mostrate
  /// come "split non disponibili" invece che con numeri ricostruiti a caso.
  static List<CardioSplit> fromRoute(List<CardioRoutePoint> points) {
    if (points.length < 2) return const [];
    if (points.any((p) => p.elapsedSeconds == null)) return const [];

    const geo = Distance();
    final splits = <CardioSplit>[];

    var distanceSoFar = 0.0;
    var splitStartSeconds = points.first.elapsedSeconds!.toDouble();
    var lastSeconds = splitStartSeconds;

    for (var i = 1; i < points.length; i++) {
      final from = points[i - 1];
      final to = points[i];
      final segment = geo.as(LengthUnit.Meter, from.position, to.position);

      final startSeconds = from.elapsedSeconds!.toDouble();
      final endSeconds = to.elapsedSeconds!.toDouble();
      lastSeconds = endSeconds;

      if (segment <= 0) continue;

      final segmentStart = distanceSoFar;
      distanceSoFar += segment;

      // Un solo tratto puo' contenere piu' confini di chilometro: con il GPS
      // in galleria capita di ricevere due punti a chilometri di distanza.
      var boundary = (splits.length + 1) * _metersPerSplit;
      while (boundary <= distanceSoFar) {
        final fraction = (boundary - segmentStart) / segment;
        final boundarySeconds =
            startSeconds + (endSeconds - startSeconds) * fraction;

        splits.add(
          CardioSplit(
            index: splits.length + 1,
            distanceKm: 1,
            seconds: (boundarySeconds - splitStartSeconds).round(),
            isPartial: false,
          ),
        );

        splitStartSeconds = boundarySeconds;
        boundary += _metersPerSplit;
      }
    }

    final remaining = distanceSoFar - splits.length * _metersPerSplit;
    if (remaining >= _minPartialMeters) {
      splits.add(
        CardioSplit(
          index: splits.length + 1,
          distanceKm: remaining / 1000,
          seconds: (lastSeconds - splitStartSeconds).round(),
          isPartial: true,
        ),
      );
    }

    return splits;
  }
}
