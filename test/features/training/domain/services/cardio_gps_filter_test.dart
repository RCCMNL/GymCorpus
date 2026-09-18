import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/services/cardio_gps_filter.dart';

/// Un punto GPS scartato deve sparire del tutto: non entra nel percorso,
/// non somma distanza e non sposta la mappa.
void main() {
  group('CardioGpsFilter.rejects', () {
    test('accetta un punto preciso e vicino', () {
      expect(
        CardioGpsFilter.rejects(accuracyMeters: 8, metersFromPrevious: 12),
        isFalse,
      );
    });

    test('scarta un punto troppo impreciso', () {
      expect(
        CardioGpsFilter.rejects(accuracyMeters: 25, metersFromPrevious: 5),
        isTrue,
      );
    });

    test('scarta un salto impossibile per un umano', () {
      // Oltre i 35 metri fra due aggiornamenti ravvicinati e' un rimbalzo
      // del GPS, non una corsa.
      expect(
        CardioGpsFilter.rejects(accuracyMeters: 5, metersFromPrevious: 60),
        isTrue,
      );
    });

    test('il primo punto non ha un precedente da cui saltare', () {
      expect(
        CardioGpsFilter.rejects(accuracyMeters: 5, metersFromPrevious: null),
        isFalse,
      );
    });

    test('un primo punto impreciso viene scartato lo stesso', () {
      expect(
        CardioGpsFilter.rejects(accuracyMeters: 40, metersFromPrevious: null),
        isTrue,
      );
    });

    test('sul limite il punto si tiene', () {
      expect(
        CardioGpsFilter.rejects(accuracyMeters: 20, metersFromPrevious: 35),
        isFalse,
      );
    });
  });

  group('CardioGpsFilter.shouldWarnStaleFix', () {
    test('appena scartato qualche punto non si avvisa', () {
      expect(
        CardioGpsFilter.shouldWarnStaleFix(
          secondsSinceLastPoint: 20,
          secondsSinceLastWarning: 999,
        ),
        isFalse,
      );
    });

    test('dopo troppo tempo senza un punto valido si avvisa', () {
      // Con precisione sempre sopra la soglia il cronometro gira e la
      // distanza resta a zero: senza un avviso te ne accorgi alla fine.
      expect(
        CardioGpsFilter.shouldWarnStaleFix(
          secondsSinceLastPoint: 60,
          secondsSinceLastWarning: 999,
        ),
        isTrue,
      );
    });

    test('non si ripete l avviso appena dato', () {
      expect(
        CardioGpsFilter.shouldWarnStaleFix(
          secondsSinceLastPoint: 60,
          secondsSinceLastWarning: 10,
        ),
        isFalse,
      );
    });

    test('se il segnale non torna, l avviso si ripete piu' ' tardi', () {
      expect(
        CardioGpsFilter.shouldWarnStaleFix(
          secondsSinceLastPoint: 200,
          secondsSinceLastWarning: 120,
        ),
        isTrue,
      );
    });
  });

  group('CardioGpsFilter.qualityFor', () {
    test('sotto i 20 metri il segnale e buono', () {
      expect(CardioGpsFilter.qualityFor(10), GpsQuality.good);
    });

    test('fra 20 e 40 metri il segnale e discreto', () {
      expect(CardioGpsFilter.qualityFor(30), GpsQuality.fair);
    });

    test('oltre i 40 metri il segnale e scarso', () {
      expect(CardioGpsFilter.qualityFor(50), GpsQuality.poor);
    });
  });
}
