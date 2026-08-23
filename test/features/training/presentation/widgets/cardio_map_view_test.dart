import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_map_view.dart';
import 'package:latlong2/latlong.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets("mostra un marker quando c'e una posizione corrente", (
    tester,
  ) async {
    final controller = MapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        CardioMapView(
          mapController: controller,
          currentPosition: const LatLng(41.9, 12.5),
          route: const [],
          isRun: true,
        ),
      ),
    );

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(MarkerLayer), findsOneWidget);
    expect(find.byType(PolylineLayer), findsNothing);
  });

  testWidgets('mostra la polilinea quando il percorso ha piu di un punto', (
    tester,
  ) async {
    final controller = MapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        CardioMapView(
          mapController: controller,
          currentPosition: const LatLng(41.9, 12.5),
          route: const [LatLng(41.9, 12.5), LatLng(41.91, 12.51)],
          isRun: false,
        ),
      ),
    );

    expect(find.byType(PolylineLayer), findsOneWidget);
  });

  testWidgets('non mostra marker quando la posizione e assente', (
    tester,
  ) async {
    final controller = MapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        CardioMapView(
          mapController: controller,
          currentPosition: null,
          route: const [],
          isRun: true,
        ),
      ),
    );

    expect(find.byType(MarkerLayer), findsNothing);
  });
}
