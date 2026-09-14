import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/features/training/data/weight_history_sync.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

class _FakeWeightLogsCompanion extends Fake implements WeightLogsCompanion {}

/// Il peso indicato nel profilo alimenta lo storico e quindi il grafico dei
/// progressi. Salvare il profilo dieci volte non deve produrre dieci punti
/// identici.
void main() {
  late _MockAppDatabase database;
  late WeightHistorySync sync;

  setUpAll(() {
    registerFallbackValue(_FakeWeightLogsCompanion());
  });

  setUp(() {
    database = _MockAppDatabase();
    sync = WeightHistorySync(database);

    when(() => database.insertWeightLog(any())).thenAnswer((_) async => 1);
  });

  WeightLog entry(double weight) =>
      WeightLog(id: 1, weight: weight, date: DateTime(2026, 9));

  test('senza storico registra il primo peso', () async {
    when(database.getLatestWeightEntry).thenAnswer((_) async => null);

    await sync.record(72);

    verify(() => database.insertWeightLog(any())).called(1);
  });

  test('una variazione trascurabile non aggiunge un punto', () async {
    when(database.getLatestWeightEntry).thenAnswer((_) async => entry(72));

    await sync.record(72.02);

    verifyNever(() => database.insertWeightLog(any()));
  });

  test('lo stesso peso non aggiunge un punto', () async {
    when(database.getLatestWeightEntry).thenAnswer((_) async => entry(72));

    await sync.record(72);

    verifyNever(() => database.insertWeightLog(any()));
  });

  test('una variazione reale viene registrata', () async {
    when(database.getLatestWeightEntry).thenAnswer((_) async => entry(72));

    await sync.record(71.5);

    verify(() => database.insertWeightLog(any())).called(1);
  });

  test('conta anche una variazione in aumento', () async {
    when(database.getLatestWeightEntry).thenAnswer((_) async => entry(72));

    await sync.record(72.6);

    verify(() => database.insertWeightLog(any())).called(1);
  });
}
