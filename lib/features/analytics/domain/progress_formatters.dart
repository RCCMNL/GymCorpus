import 'package:gym_corpus/core/utils/unit_converter.dart';

/// Formatta un peso in kg nell'unita' scelta dall'utente, es. "72.4 kg".
String formatWeight(double weightKg, {required bool isImperial}) {
  final value = isImperial ? UnitConverter.kgToLb(weightKg) : weightKg;
  final unit = isImperial ? 'lb' : 'kg';
  return '${value.toStringAsFixed(1)} $unit';
}

/// Come [formatWeight] ma con il segno esplicito, es. "+1.2 kg" o "-0.4 kg".
String formatSignedWeight(double weightKg, {required bool isImperial}) {
  final value = isImperial ? UnitConverter.kgToLb(weightKg) : weightKg;
  final unit = isImperial ? 'lb' : 'kg';
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(1)} $unit';
}

/// Chiave di raggruppamento mensile ordinabile, es. "2026-03".
String getMonthKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

/// Etichetta leggibile per una chiave prodotta da [getMonthKey],
/// es. "2026-03" -> "MARZO 2026".
String formatMonthKey(String key) {
  final parts = key.split('-');
  final year = parts[0];
  final month = int.parse(parts[1]);
  final monthName = [
    '',
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ][month];
  return '$monthName $year'.toUpperCase();
}
