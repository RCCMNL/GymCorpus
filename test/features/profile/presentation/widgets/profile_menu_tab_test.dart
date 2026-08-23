import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_menu_tab.dart';

void main() {
  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(child: ProfileMenuTab()),
          ),
        ),
        GoRoute(
          path: '/profile/records',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Schermata Record'))),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('mostra le sezioni e le voci del menu', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('COMMUNITY & GAMIFICATION'), findsOneWidget);
    expect(find.text('PERFORMANCE & DATI'), findsOneWidget);
    expect(find.text('ALLENAMENTO'), findsOneWidget);
    expect(find.text('PALESTRA'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Progressi'), findsOneWidget);
  });

  testWidgets(
    'le voci non ancora implementate mostrano il badge Prossimamente',
    (tester) async {
      await tester.pumpWidget(wrap());

      expect(find.text('Classifica Utenti'), findsOneWidget);
      expect(find.text('Prossimamente'), findsWidgets);
    },
  );

  testWidgets('il tap su Record naviga a /profile/records', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();

    expect(find.text('Schermata Record'), findsOneWidget);
  });
}
