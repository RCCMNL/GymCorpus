import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// Indicatore qualita' segnale GPS (mostrato solo durante il tracking) e
/// attribuzione OpenStreetMap, in alto a destra sulla mappa.
class GpsStatusBadge extends StatelessWidget {
  const GpsStatusBadge({
    required this.gpsSignalQuality,
    required this.isTracking,
    super.key,
  });

  /// 0 = Bad, 1 = Ok, 2 = Good.
  final int gpsSignalQuality;
  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isTracking)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              children: [
                Icon(
                  gpsSignalQuality == 2
                      ? Icons.signal_cellular_4_bar
                      : gpsSignalQuality == 1
                      ? Icons.signal_cellular_alt
                      : Icons.signal_cellular_connected_no_internet_0_bar,
                  size: 14,
                  color: gpsSignalQuality == 2
                      ? Colors.green
                      : gpsSignalQuality == 1
                      ? Colors.orange
                      : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  gpsSignalQuality == 2
                      ? 'GPS OTTIMO'
                      : gpsSignalQuality == 1
                      ? 'GPS DEBOLE'
                      : 'GPS PERSO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: AppRadius.xs,
          ),
          child: Text(
            '© OpenStreetMap',
            style: TextStyle(fontSize: 9, color: theme.colorScheme.outline),
          ),
        ),
      ],
    );
  }
}
