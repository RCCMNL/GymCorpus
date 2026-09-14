import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Tiene allineato lo storico peso al peso indicato nel profilo.
///
/// Vive qui e non nel repository di autenticazione: scrivere nello storico
/// degli allenamenti e' dominio training, e il repository auth lo faceva
/// solo perche' il peso si aggiorna dalla schermata profilo.
class WeightHistorySync {
  const WeightHistorySync(this._database);

  final AppDatabase _database;

  /// Sotto questa differenza il peso e' lo stesso: registrare ogni
  /// salvataggio del profilo riempirebbe il grafico di punti identici.
  static const minimumChangeKg = 0.05;

  Future<void> record(double weight) async {
    final latest = await _database.getLatestWeightEntry();
    final changed =
        latest == null || (latest.weight - weight).abs() >= minimumChangeKg;

    if (!changed) return;

    await _database.insertWeightLog(
      WeightLogsCompanion(weight: Value(weight), date: Value(DateTime.now())),
    );
  }
}
