import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// L'app usava diciannove raggi diversi: 2, 4, 5, 6, 8, 10, 12, 14, 15,
/// 16, 18, 20, 22, 24, 28, 30, 32, 40, 999. Nessuno di quei numeri era
/// sbagliato da solo, ma messi vicini si vedono: una card a 24 accanto a
/// una a 22 e a una a 20 non sembra una scelta, sembra distrazione.
///
/// Qui il raggio lo decide [AppRadius] e basta. Il test guarda i
/// sorgenti perche' e' l'unico modo di accorgersi di un numero nuovo
/// scritto a mano: un `BorderRadius.circular(17)` compila, passa
/// l'analisi e non rompe nessuno schermo, sporca solo l'insieme.
void main() {
  /// Tutti i .dart sotto lib/, esclusi i generati.
  List<File> sourceFiles() {
    return Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .where((f) => !f.path.endsWith('.freezed.dart'))
        .where((f) => !f.path.endsWith('.config.dart'))
        .toList();
  }

  test('nessun raggio scritto a mano fuori dalla scala', () {
    final offenders = <String>[];

    for (final file in sourceFiles()) {
      // La scala stessa e' l'unico posto dove i numeri possono stare.
      if (file.path
          .replaceAll(r'\', '/')
          .endsWith('core/theme/app_radius.dart')) {
        continue;
      }

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        // Il pacchetto pdf ha una sua geometria, omonima ma di un altro
        // tipo: il referto stampato non e' una schermata e non passa
        // per il tema dell'app.
        if (lines[i].contains('pw.BorderRadius')) continue;

        if (RegExp(r'Radius\.circular\(').hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Questi punti scelgono un raggio per conto loro invece di '
          'prenderlo da AppRadius:\n${offenders.join('\n')}',
    );
  });

  test('la scala resta corta e ordinata', () {
    final steps = [
      AppRadius.xs,
      AppRadius.sm,
      AppRadius.md,
      AppRadius.lg,
      AppRadius.xl,
      AppRadius.xxl,
    ];

    // Crescente: un gradino che torna indietro renderebbe i nomi
    // bugiardi, ed e' il genere di errore che si nota solo a schermo.
    for (var i = 1; i < steps.length; i++) {
      expect(
        steps[i].topLeft.x,
        greaterThan(steps[i - 1].topLeft.x),
        reason: 'il gradino ${i + 1} non e" piu" grande del precedente',
      );
    }

    expect(
      steps.length,
      lessThanOrEqualTo(6),
      reason:
          'una scala lunga e" una scala che non decide: se serve un '
          'gradino nuovo, prima guarda se uno dei sei basta',
    );

    // La pillola non e' un gradino della scala: e' "quanto basta perche'
    // i lati diventino semicerchi", qualunque sia l'altezza.
    expect(AppRadius.pill.topLeft.x, greaterThanOrEqualTo(999));
  });
}
