import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_image.dart';

void main() {
  group('exerciseImageSlug', () {
    test('minuscolo e con i trattini al posto degli spazi', () {
      expect(exerciseImageSlug('Panca piana'), 'panca-piana');
    });

    test('le parentesi spariscono, non diventano trattini in mezzo', () {
      expect(
        exerciseImageSlug('Distensioni su panca piana (Bilanciere)'),
        'distensioni-su-panca-piana-bilanciere',
      );
    });

    test('gli accenti diventano la lettera senza accento', () {
      expect(
        exerciseImageSlug('Trazioni alla sbarra è più'),
        'trazioni-alla-sbarra-e-piu',
      );
    });

    test('niente trattini doppi ne in testa ne in coda', () {
      expect(exerciseImageSlug('  Curl  /  Bicipiti!  '), 'curl-bicipiti');
    });

    test('i numeri restano', () {
      expect(exerciseImageSlug('Plank 60 secondi'), 'plank-60-secondi');
    });

    test('un nome che non lascia niente non da un nome di file vuoto', () {
      expect(exerciseImageSlug('!!!'), '');
    });
  });

  group('exerciseImageAsset', () {
    test('la figura sta in assets/exercises col nome dell esercizio', () {
      expect(
        exerciseImageAsset('Panca piana (Bilanciere)'),
        'assets/exercises/panca-piana-bilanciere.webp',
      );
    });

    test('senza un nome utilizzabile non c e figura da cercare', () {
      expect(exerciseImageAsset('???'), isNull);
    });
  });
}
