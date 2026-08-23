import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/bmi_card.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

import '../../../../helpers/mock_auth_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc trainingBloc;
  late MockAuthBloc authBloc;

  setUp(() {
    trainingBloc = MockTrainingBloc();
    authBloc = MockAuthBloc();
  });

  Widget wrap({
    required TrainingState trainingState,
    required AuthState authState,
  }) {
    whenListen(
      trainingBloc,
      const Stream<TrainingState>.empty(),
      initialState: trainingState,
    );
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: authState,
    );

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TrainingBloc>.value(value: trainingBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: const Scaffold(body: BMICard()),
      ),
    );
  }

  testWidgets('mostra -- e N/A senza dati sufficienti', (tester) async {
    await tester.pumpWidget(
      wrap(
        trainingState: const TrainingState.loaded(exercises: []),
        authState: const AuthState.unauthenticated(),
      ),
    );

    expect(find.text('--'), findsOneWidget);
    expect(find.text('N/A'), findsOneWidget);
  });

  testWidgets('calcola il BMI dal peso e altezza del profilo', (tester) async {
    const user = UserEntity(id: '1', email: 'a@a.com', weight: 70, height: 175);

    await tester.pumpWidget(
      wrap(
        trainingState: const TrainingState.loaded(exercises: []),
        authState: const AuthState.authenticated(user),
      ),
    );

    // 70 / (1.75*1.75) = 22.857... -> 22.9, categoria NORMAL.
    expect(find.text('22.9'), findsOneWidget);
    expect(find.text('NORMAL'), findsOneWidget);
  });

  testWidgets('usa il peso piu recente dal log invece di quello profilo', (
    tester,
  ) async {
    const user = UserEntity(id: '1', email: 'a@a.com', weight: 70, height: 175);

    await tester.pumpWidget(
      wrap(
        trainingState: TrainingState.loaded(
          exercises: const [],
          bodyWeightLogs: [
            BodyWeightLogEntity(id: 1, weight: 95, date: DateTime(2026)),
          ],
        ),
        authState: const AuthState.authenticated(user),
      ),
    );

    // 95 / (1.75*1.75) = 31.02 -> OBESE.
    expect(find.text('OBESE'), findsOneWidget);
  });
}
