import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';

/// Accesso alle mestruazioni registrate.
///
/// I dati restano sul dispositivo, nel database locale cifrato: non passano
/// da Firestore ne' finiscono nel report PDF.
abstract class CycleRepository {
  Stream<List<CycleLogEntity>> watchCycleLogs();

  /// Registra l'inizio di una mestruazione.
  Future<Either<Failure, int>> startPeriod(DateTime date);

  /// Chiude una mestruazione in corso.
  Future<Either<Failure, void>> endPeriod({
    required int id,
    required DateTime date,
  });

  Future<Either<Failure, void>> deleteCycleLog(int id);
}
