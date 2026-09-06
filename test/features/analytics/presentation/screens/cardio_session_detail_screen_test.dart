import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/cardio_session_detail_screen.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_notifications_bloc.dart';
import '../../../../helpers/offline_map_tiles.dart';

/// Il dettaglio sostituisce la card espandibile dello storico: qui la
/// sessione si vede per intero, percorso compreso.
void main() {
  useOfflineMapTiles();

  late MockNotificationsBloc notificationsBloc;

  setUp(() {
    notificationsBloc = MockNotificationsBloc();
    when(
      () => notificationsBloc.state,
    ).thenReturn(const NotificationsState());
  });

  const geo = Distance();
  const origin = LatLng(45, 9);

  /// Percorso rettilineo di 2 km con i tempi di passaggio.
  String timedRoute() {
    return CardioRoutePoint.encode([
      for (var meters = 0; meters <= 2000; meters += 100)
        CardioRoutePoint(
          position: meters == 0
              ? origin
              : geo.offset(origin, meters.toDouble(), 0),
          elapsedSeconds: (meters * 0.3).round(),
        ),
    ]);
  }

  CardioSessionEntity session({String? routeJson}) => CardioSessionEntity(
    id: 1,
    type: 'run',
    distance: 2,
    duration: 600,
    avgSpeed: 12,
    pace: '05:00',
    calories: 180,
    date: DateTime(2026, 9, 4, 18, 30),
    steps: 2600,
    routeJson: routeJson,
  );

  /// Schermo alto abbastanza da contenere tutta la scheda: evita di
  /// scorrere sopra la mappa, che intercetterebbe il trascinamento.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget wrap(CardioSessionEntity value) {
    return BlocProvider<NotificationsBloc>.value(
      value: notificationsBloc,
      child: MaterialApp(home: CardioSessionDetailScreen(session: value)),
    );
  }

  testWidgets('mostra tipo, distanza, durata e calorie della sessione', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(session(routeJson: timedRoute())));

    expect(find.text('Corsa'), findsOneWidget);
    expect(find.text('2.00 km'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('180 kcal'), findsOneWidget);
  });

  testWidgets('disegna il percorso registrato', (tester) async {
    await tester.pumpWidget(wrap(session(routeJson: timedRoute())));

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
  });

  testWidgets('mostra i passaggi al chilometro', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(wrap(session(routeJson: timedRoute())));


    expect(find.text('KM 1'), findsOneWidget);
    expect(find.text('KM 2'), findsOneWidget);
  });

  testWidgets('una sessione senza percorso non mostra la mappa', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(session()));

    expect(find.byType(FlutterMap), findsNothing);
  });

  testWidgets('una sessione registrata senza tempi lo dichiara', (
    tester,
  ) async {
    final legacy = CardioRoutePoint.encode(const [
      CardioRoutePoint(position: LatLng(45, 9)),
      CardioRoutePoint(position: LatLng(45.01, 9)),
    ]);

    useTallScreen(tester);
    await tester.pumpWidget(wrap(session(routeJson: legacy)));


    expect(find.textContaining('Split non disponibili'), findsOneWidget);
  });
}
