import 'package:gym_corpus/core/utils/unit_converter.dart';

/// Formatta una durata in minuti in forma compatta, es. "45min", "1h30m".
String formatWorkoutDuration(int minutes) {
  if (minutes < 60) return '${minutes}min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h${m}m';
}

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
