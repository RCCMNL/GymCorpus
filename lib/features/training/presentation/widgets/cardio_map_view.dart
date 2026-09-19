import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';

/// Mappa OpenStreetMap con il percorso GPS e la posizione corrente,
/// usata come sfondo del CardioTrackerScreen.
class CardioMapView extends StatelessWidget {
  const CardioMapView({
    required this.mapController,
    required this.currentPosition,
    required this.route,
    required this.isRun,
    super.key,
  });

  final MapController mapController;
  final LatLng? currentPosition;
  final List<LatLng> route;
  final bool isRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = isRun ? theme.colorScheme.primary : AppPalette.gold;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition ?? const LatLng(41.9028, 12.4964),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gymcorpus.app',
        ),
        if (route.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(points: route, color: accentColor, strokeWidth: 5),
            ],
          ),
        if (currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: currentPosition!,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
