import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/domain/muscle_groups.dart';

void main() {
  group('muscleRegionFor', () {
    test('mappa i gruppi di spinta', () {
      for (final muscle in ['Petto', 'Spalle', 'Tricipiti']) {
        expect(muscleRegionFor(muscle), MuscleRegion.spinta, reason: muscle);
      }
    });

    test('mappa i gruppi di trazione', () {
      for (final muscle in ['Dorso', 'Bicipiti', 'Avambracci']) {
        expect(muscleRegionFor(muscle), MuscleRegion.trazione, reason: muscle);
      }
    });

    test('mappa gambe e polpacci', () {
      expect(muscleRegionFor('Gambe'), MuscleRegion.gambe);
      expect(muscleRegionFor('Polpacci'), MuscleRegion.gambe);
    });

    test('mappa gli addominali sul core', () {
      expect(muscleRegionFor('Addominali'), MuscleRegion.core);
    });

    test('ignora maiuscole e spazi ai lati', () {
      expect(muscleRegionFor('  bicipiti '), MuscleRegion.trazione);
      expect(muscleRegionFor('PETTO'), MuscleRegion.spinta);
    });

    test('un gruppo sconosciuto ricade su una regione, non su null', () {
      // Gli esercizi custom possono avere qualunque gruppo: il segnaposto
      // deve restare tinto, altrimenti torna a sembrare un errore.
      expect(muscleRegionFor('Collo'), MuscleRegion.spinta);
      expect(muscleRegionFor(''), MuscleRegion.spinta);
    });

    test('copre tutti i nove gruppi del catalogo', () {
      const catalog = [
        'Addominali',
        'Avambracci',
        'Bicipiti',
        'Dorso',
        'Gambe',
        'Petto',
        'Polpacci',
        'Spalle',
        'Tricipiti',
      ];
      final regions = catalog.map(muscleRegionFor).toSet();
      expect(regions, MuscleRegion.values.toSet());
    });
  });
}
