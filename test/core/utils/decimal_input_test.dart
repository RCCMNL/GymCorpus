import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/decimal_input.dart';

void main() {
  group('parseDecimalInput', () {
    test('legge un numero col punto', () {
      expect(parseDecimalInput('72.5'), 72.5);
    });

    test('legge un numero con la virgola, come si scrive in italiano', () {
      expect(parseDecimalInput('72,5'), 72.5);
    });

    test('ignora gli spazi ai lati', () {
      expect(parseDecimalInput('  72,5 '), 72.5);
    });

    test('un campo vuoto non e un numero', () {
      expect(parseDecimalInput(''), isNull);
      expect(parseDecimalInput('   '), isNull);
    });

    test('quello che non e un numero resta niente', () {
      expect(parseDecimalInput('settanta'), isNull);
      expect(parseDecimalInput('7,2,5'), isNull);
    });

    test('un intero e comunque un numero', () {
      expect(parseDecimalInput('72'), 72.0);
    });
  });
}
