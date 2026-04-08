enum WeightUnit { kg, lb }
enum LengthUnit { cm, inch }

class UnitConverter {
  static const double _lbToKgFactor = 0.45359237;
  static const double _inchToCmFactor = 2.54;

  // Weight conversions
  static double kgToLb(double kg) => kg / _lbToKgFactor;
  static double lbToKg(double lb) => lb * _lbToKgFactor;

  // Length conversions
  static double cmToInch(double cm) => cm / _inchToCmFactor;
  static double inchToCm(double inch) => inch * _inchToCmFactor;

  // Helper methodologies for formatting strings (display)
  static String formatWeight(double baseKg, WeightUnit displayUnit, {int decimalPlaces = 1}) {
    if (displayUnit == WeightUnit.kg) {
      return '${baseKg.toStringAsFixed(decimalPlaces)} kg';
    } else {
      return '${kgToLb(baseKg).toStringAsFixed(decimalPlaces)} lb';
    }
  }

  static String formatLength(double baseCm, LengthUnit displayUnit, {int decimalPlaces = 1}) {
    if (displayUnit == LengthUnit.cm) {
      return '${baseCm.toStringAsFixed(decimalPlaces)} cm';
    } else {
       return '${cmToInch(baseCm).toStringAsFixed(decimalPlaces)} in';
    }
  }

    // Helper for user input: converting from user's preferred unit to base unit (Kg/Cm)
  static double convertInputToAppBaseWeight(double input, WeightUnit inputUnit) {
      if(inputUnit == WeightUnit.kg) return input;
      return lbToKg(input);
  }

  static double convertInputToAppBaseLength(double input, LengthUnit inputUnit) {
      if(inputUnit == LengthUnit.cm) return input;
      return inchToCm(input);
  }
}
