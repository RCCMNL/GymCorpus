import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/repositories/cycle_repository.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_bloc.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_event.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockCycleRepository extends Mock implements CycleRepository {}

void main() {
  late _MockCycleRepository repository;

  final today = DateTime(2026, 9, 5);
  final openLog = CycleLogEntity(id: 1, startDate: DateTime(2026, 9, 3));
  final closedLog = CycleLogEntity(
    id: 1,
    startDate: DateTime(2026, 9),
    endDate: DateTime(2026, 9, 5),
  );

  CycleBloc buildBloc() =>
      CycleBloc(repository: repository, clock: () => today);

  setUp(() {
    repository = _MockCycleRepository();
    when(() => repository.watchCycleLogs()).thenAnswer((_) => const Stream.empty());
    when(() => repository.startPeriod(any())).thenAnswer((_) async => const Right(1));
    when(
      () => repository.endPeriod(id: any(named: 'id'), date: any(named: 'date')),
    ).thenAnswer((_) async => const Right(null));
    when(() => repository.deleteCycleLog(any())).thenAnswer((_) async => const Right(null));
  });

  blocTest<CycleBloc, CycleState>(
    'il caricamento porta i log e il riepilogo calcolato su oggi',
    setUp: () {
      when(
        () => repository.watchCycleLogs(),
      ).thenAnswer((_) => Stream.value([openLog]));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(LoadCycleLogsEvent()),
    expect: () => [
      isA<CycleState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.logs, 'logs', [openLog])
          .having((s) => s.summary?.dayOfCycle, 'giorno del ciclo', 3)
          .having((s) => s.summary?.state, 'stato', CycleDataState.ongoing),
    ],
  );

  blocTest<CycleBloc, CycleState>(
    'segnare l inizio registra la data di oggi',
    build: buildBloc,
    act: (bloc) => bloc.add(StartPeriodEvent()),
    verify: (_) => verify(() => repository.startPeriod(today)).called(1),
  );

  blocTest<CycleBloc, CycleState>(
    'con un ciclo gia aperto l inizio non viene registrato due volte',
    setUp: () {
      when(
        () => repository.watchCycleLogs(),
      ).thenAnswer((_) => Stream.value([openLog]));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(LoadCycleLogsEvent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(StartPeriodEvent());
    },
    verify: (_) => verifyNever(() => repository.startPeriod(any())),
  );

  blocTest<CycleBloc, CycleState>(
    'segnare la fine chiude il ciclo aperto',
    setUp: () {
      when(
        () => repository.watchCycleLogs(),
      ).thenAnswer((_) => Stream.value([openLog]));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(LoadCycleLogsEvent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(EndPeriodEvent());
    },
    verify: (_) =>
        verify(() => repository.endPeriod(id: 1, date: today)).called(1),
  );

  blocTest<CycleBloc, CycleState>(
    'senza cicli aperti non c e nulla da chiudere',
    setUp: () {
      when(
        () => repository.watchCycleLogs(),
      ).thenAnswer((_) => Stream.value([closedLog]));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(LoadCycleLogsEvent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(EndPeriodEvent());
    },
    verify: (_) => verifyNever(
      () => repository.endPeriod(id: any(named: 'id'), date: any(named: 'date')),
    ),
  );

  blocTest<CycleBloc, CycleState>(
    'una registrazione sbagliata puo essere cancellata',
    build: buildBloc,
    act: (bloc) => bloc.add(const DeleteCycleLogEvent(7)),
    verify: (_) => verify(() => repository.deleteCycleLog(7)).called(1),
  );

  blocTest<CycleBloc, CycleState>(
    'un errore del database diventa un messaggio nello stato',
    setUp: () {
      when(
        () => repository.startPeriod(any()),
      ).thenAnswer((_) async => const Left(DatabaseFailure('disco pieno')));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(StartPeriodEvent()),
    expect: () => [
      isA<CycleState>().having(
        (s) => s.errorMessage,
        'messaggio di errore',
        'disco pieno',
      ),
    ],
  );
}
