import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';

Future<void> _pumpTrigger(
  WidgetTester tester,
  void Function(BuildContext context) onTap,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => onTap(context),
            child: const Text('mostra'),
          ),
        ),
      ),
    ),
  );
}

Color _pillColor(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(of: find.byType(SnackBar), matching: find.byType(Container))
        .first,
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  group('AppSnackBar', () {
    testWidgets('mostra il messaggio richiesto', (tester) async {
      await _pumpTrigger(
        tester,
        (context) => AppSnackBar.show(context, 'Salvato'),
      );

      await tester.tap(find.text('mostra'));
      await tester.pump();

      expect(find.text('Salvato'), findsOneWidget);
    });

    testWidgets('il tono di errore prende il colore di errore del tema', (
      tester,
    ) async {
      await _pumpTrigger(
        tester,
        (context) => AppSnackBar.showError(context, 'Non riuscito'),
      );

      await tester.tap(find.text('mostra'));
      await tester.pump();

      expect(_pillColor(tester), AppTheme.darkTheme.colorScheme.error);
    });

    testWidgets('il tono di successo prende il colore terziario', (
      tester,
    ) async {
      await _pumpTrigger(
        tester,
        (context) => AppSnackBar.showSuccess(context, 'Fatto'),
      );

      await tester.tap(find.text('mostra'));
      await tester.pump();

      expect(_pillColor(tester), AppTheme.darkTheme.colorScheme.tertiary);
    });

    testWidgets('ogni tono porta la propria icona', (tester) async {
      await _pumpTrigger(
        tester,
        (context) => AppSnackBar.showWarning(context, 'Attenzione'),
      );

      await tester.tap(find.text('mostra'));
      await tester.pump();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('un icona esplicita sostituisce quella del tono', (
      tester,
    ) async {
      await _pumpTrigger(
        tester,
        (context) => AppSnackBar.show(
          context,
          'Aggiungi un esercizio',
          icon: Icons.fitness_center_rounded,
        ),
      );

      await tester.tap(find.text('mostra'));
      await tester.pump();

      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    });

    testWidgets('senza icona resta il solo messaggio', (tester) async {
      await _pumpTrigger(
        tester,
        (context) => AppSnackBar.show(context, 'Nota', icon: null),
      );

      await tester.tap(find.text('mostra'));
      await tester.pump();

      expect(
        find.descendant(of: find.byType(SnackBar), matching: find.byType(Icon)),
        findsNothing,
      );
    });

    testWidgets('un secondo messaggio non si accoda al primo', (tester) async {
      await _pumpTrigger(tester, (context) {
        AppSnackBar.show(context, 'Primo');
        AppSnackBar.show(context, 'Secondo');
      });

      await tester.tap(find.text('mostra'));
      await tester.pump();

      expect(find.text('Primo'), findsNothing);
      expect(find.text('Secondo'), findsOneWidget);
    });
    testWidgets('un azione compare accanto al messaggio', (tester) async {
      var premuto = false;
      await _pumpTrigger(
        tester,
        (context) => AppSnackBar.show(
          context,
          'Notifiche disattivate',
          actionLabel: 'Impostazioni',
          onAction: () => premuto = true,
        ),
      );

      await tester.tap(find.text('mostra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Impostazioni'));

      expect(premuto, isTrue);
    });
  });
}
