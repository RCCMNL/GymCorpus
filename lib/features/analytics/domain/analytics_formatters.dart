import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';

/// Formatta un totale di minuti allenati, es. "45m", "1h 30m", "2h".
String formatWorkoutDuration(int minutes) =>
    formatCompactDuration(minutes * 60);

/// Formatta un volume in kg in forma compatta, es. "850 kg", "12.3k kg".
String formatVolumeKg(double kg) {
  if (kg < 1000) return '${kg.toStringAsFixed(0)} kg';
  return '${(kg / 1000).toStringAsFixed(1)}k kg';
}

/// Come [formatVolumeKg], ma convertendo il volume in libbre.
String formatVolumeLb(double kg) {
  final lb = UnitConverter.kgToLb(kg);
  if (lb < 1000) return '${lb.toStringAsFixed(0)} lb';
  return '${(lb / 1000).toStringAsFixed(1)}k lb';
}
