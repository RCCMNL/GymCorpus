import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Restringe la finestra del test a un telefono piccolo con il testo
/// ingrandito.
///
/// 320 punti e' la larghezza dei telefoni piu' piccoli ancora in giro, e
/// il 130% e' una taglia di testo comune fra chi non ci vede benissimo.
/// La finestra predefinita dei test e' 800x600: piu' larga di qualunque
/// telefono, ed e' il motivo per cui una ventina di traboccamenti non si
/// vedevano da qui.
void useNarrowScreen(WidgetTester tester, {double textScale = 1.3}) {
  tester.view
    ..physicalSize = const Size(960, 1920)
    ..devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;

  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
