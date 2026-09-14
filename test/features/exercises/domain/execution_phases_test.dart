import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/domain/execution_phases.dart';

void main() {
  group('ExecutionPhases.fromText', () {
    test('senza testo non c e nessuna fase', () {
      expect(ExecutionPhases.fromText(null).up, isNull);
      expect(ExecutionPhases.fromText('   ').down, isNull);
    });

    test('una frase sola e tutta la salita', () {
      final phases = ExecutionPhases.fromText('Spingi il bilanciere.');

      expect(phases.up, 'Spingi il bilanciere.');
      expect(phases.down, isNull);
    });

    test('la seconda frase e la discesa', () {
      final phases = ExecutionPhases.fromText(
        'Abbassa il bilanciere al petto. Spingi verso l alto.',
      );

      expect(phases.up, 'Abbassa il bilanciere al petto.');
      expect(phases.down, 'Spingi verso l alto.');
    });

    test('il punto finale non crea una fase vuota', () {
      // Ogni esercizio del catalogo finisce con il punto: prima quel punto
      // faceva contare tre parti invece di due e la discesa spariva.
      final phases = ExecutionPhases.fromText('Prima frase. Seconda frase.');

      expect(phases.down, 'Seconda frase.');
    });

    test('dalla terza frase in poi niente va perso', () {
      final phases = ExecutionPhases.fromText('Uno. Due. Tre.');

      expect(phases.up, 'Uno.');
      expect(phases.down, 'Due. Tre.');
    });

    test('un testo senza punti resta tutto nella salita', () {
      final phases = ExecutionPhases.fromText('Spingi e torna giu');

      expect(phases.up, 'Spingi e torna giu.');
      expect(phases.down, isNull);
    });
  });
}
