import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    test('converte peso tra kg e lb', () {
      expect(UnitConverter.kgToLb(100), closeTo(220.462, 0.001));
      expect(UnitConverter.lbToKg(220.462), closeTo(100, 0.001));
    });

    test('converte lunghezza tra cm e pollici', () {
      expect(UnitConverter.cmToInch(180), closeTo(70.866, 0.001));
      expect(UnitConverter.inchToCm(70.866), closeTo(180, 0.01));
    });

    test('formatta peso e lunghezza nella unita richiesta', () {
      expect(UnitConverter.formatWeight(80, WeightUnit.kg), '80.0 kg');
      expect(
        UnitConverter.formatWeight(80, WeightUnit.lb, decimalPlaces: 0),
        '176 lb',
      );
      expect(UnitConverter.formatLength(180, LengthUnit.cm), '180.0 cm');
      expect(UnitConverter.formatLength(180, LengthUnit.inch), '70.9 in');
    });

    test('converte input utente nella unita base dell app', () {
      expect(
        UnitConverter.convertInputToAppBaseWeight(220.462, WeightUnit.lb),
        closeTo(100, 0.001),
      );
      expect(
        UnitConverter.convertInputToAppBaseLength(70.866, LengthUnit.inch),
        closeTo(180, 0.01),
      );
    });

    test('ritorna il nome mese italiano compatto', () {
      expect(UnitConverter.monthName(1), 'GEN');
      expect(UnitConverter.monthName(12), 'DIC');
      expect(UnitConverter.monthName(0), '');
      expect(UnitConverter.monthName(13), '');
    });
  });
}
