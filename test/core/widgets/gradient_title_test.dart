import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    ),
  );
}

TextStyle _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

void main() {
  group('GradientMask', () {
    testWidgets('mostra quello che gli viene dato', (tester) async {
      await _pump(tester, const GradientMask(child: Icon(Icons.bolt)));

      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('lo dipinge con la sfumatura', (tester) async {
      await _pump(tester, const GradientMask(child: Icon(Icons.bolt)));

      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('GradientTitle', () {
    testWidgets('scrive il testo che riceve', (tester) async {
      await _pump(tester, const GradientTitle('Profilo'));

      expect(find.text('Profilo'), findsOneWidget);
    });

    testWidgets('il testo e bianco, se no la sfumatura non si vede', (
      tester,
    ) async {
      await _pump(tester, const GradientTitle('Profilo'));

      expect(_styleOf(tester, 'Profilo').color, Colors.white);
    });

    testWidgets('le tre misure sono 22, 28 e 32', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            GradientTitle('Compatto', scale: GradientTitleScale.compact),
            GradientTitle('Schermata'),
            GradientTitle('Grande', scale: GradientTitleScale.hero),
          ],
        ),
      );

      expect(_styleOf(tester, 'Compatto').fontSize, 22);
      expect(_styleOf(tester, 'Schermata').fontSize, 28);
      expect(_styleOf(tester, 'Grande').fontSize, 32);
    });

    testWidgets('uno stile aggiuntivo si somma a quello di base', (
      tester,
    ) async {
      await _pump(
        tester,
        const GradientTitle(
          'Gym Corpus',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );

      final style = _styleOf(tester, 'Gym Corpus');

      expect(style.fontStyle, FontStyle.italic);
      expect(style.fontWeight, FontWeight.w900);
      expect(style.fontFamily, 'Lexend');
    });

    testWidgets('un titolo lungo puo andare a capo una volta sola', (
      tester,
    ) async {
      await _pump(tester, const GradientTitle('Un titolo lungo', maxLines: 2));

      final text = tester.widget<Text>(find.text('Un titolo lungo'));

      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
