import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';

/// Il movimento fra due schermate.
///
/// Il caso che conta davvero non e' il movimento: e' il fermo. Una
/// transizione con il tween al contrario lascia la pagina spostata per
/// sempre, e non lo si vede perche' tutto e' spostato allo stesso modo:
/// lo si scopre quando qualcosa che sta fuori dalla pagina - una snack
/// bar, un dialogo - smette di combaciare.
void main() {
  Widget app() => MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(body: Center(child: Text('la seconda'))),
              ),
            ),
            child: const Text('la prima'),
          ),
        ),
      ),
    ),
  );

  testWidgets('a riposo la pagina sta dov e, non spostata di lato', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    final screen = tester.getSize(find.byType(MaterialApp));
    final center = tester.getCenter(find.text('la prima'));

    expect(center.dx, moreOrLessEquals(screen.width / 2, epsilon: 0.5));
  });

  testWidgets('la nuova arriva da destra e si ferma al suo posto', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final screen = tester.getSize(find.byType(MaterialApp));

    await tester.tap(find.text('la prima'));
    await tester.pump();
    // A meta' corsa la nuova schermata e' ancora sulla destra.
    await tester.pump(const Duration(milliseconds: 60));

    expect(
      tester.getCenter(find.text('la seconda')).dx,
      greaterThan(screen.width / 2),
    );

    await tester.pumpAndSettle();

    expect(
      tester.getCenter(find.text('la seconda')).dx,
      moreOrLessEquals(screen.width / 2, epsilon: 0.5),
    );
  });

  testWidgets('tornando indietro la prima si rimette a posto', (tester) async {
    await tester.pumpWidget(app());
    final screen = tester.getSize(find.byType(MaterialApp));

    await tester.tap(find.text('la prima'));
    await tester.pumpAndSettle();

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    expect(
      tester.getCenter(find.text('la prima')).dx,
      moreOrLessEquals(screen.width / 2, epsilon: 0.5),
    );
  });
}
