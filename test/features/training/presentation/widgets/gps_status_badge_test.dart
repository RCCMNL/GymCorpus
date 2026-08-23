import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/gps_status_badge.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets("mostra l'indicatore GPS solo quando isTracking e true", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const GpsStatusBadge(gpsSignalQuality: 2, isTracking: false)),
    );
    expect(find.textContaining('GPS'), findsNothing);
    expect(find.text('© OpenStreetMap'), findsOneWidget);

    await tester.pumpWidget(
      wrap(const GpsStatusBadge(gpsSignalQuality: 2, isTracking: true)),
    );
    expect(find.text('GPS OTTIMO'), findsOneWidget);
  });

  testWidgets("mostra l'etichetta corretta per ogni livello di segnale", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const GpsStatusBadge(gpsSignalQuality: 1, isTracking: true)),
    );
    expect(find.text('GPS DEBOLE'), findsOneWidget);

    await tester.pumpWidget(
      wrap(const GpsStatusBadge(gpsSignalQuality: 0, isTracking: true)),
    );
    expect(find.text('GPS PERSO'), findsOneWidget);
  });
}
