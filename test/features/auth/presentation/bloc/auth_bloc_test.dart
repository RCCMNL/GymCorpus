import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('AuthBloc', () {
    final birthDate = DateTime(1994, 6, 12);
    const baseUser = UserEntity(
      id: 'u1',
      email: 'mario@example.com',
      firstName: 'Atleta',
    );
    final completedUser = baseUser.copyWith(
      firstName: 'Mario',
      lastName: 'Rossi',
      username: 'mario_rossi',
      birthDate: birthDate,
      gender: 'Uomo',
    );

    blocTest<AuthBloc, AuthState>(
      'registra l utente e salva i campi profilo richiesti',
      build: () {
        when(() => repository.signUp('mario@example.com', 'password123'))
            .thenAnswer((_) async => const Right(baseUser));
        when(
          () => repository.updateProfileDetails(
            firstName: 'Mario',
            lastName: 'Rossi',
            username: 'mario_rossi',
            birthDate: birthDate,
            gender: 'Uomo',
          ),
        ).thenAnswer((_) async => Right(completedUser));

        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(
        AuthEvent.signUpRequested(
          email: 'mario@example.com',
          password: 'password123',
          firstName: 'Mario',
          lastName: 'Rossi',
          username: 'mario_rossi',
          birthDate: birthDate,
          gender: 'Uomo',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        AuthState.authenticated(completedUser),
      ],
      verify: (_) {
        verify(() => repository.signUp('mario@example.com', 'password123'))
            .called(1);
        verify(
          () => repository.updateProfileDetails(
            firstName: 'Mario',
            lastName: 'Rossi',
            username: 'mario_rossi',
            birthDate: birthDate,
            gender: 'Uomo',
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'mantiene i dati profilo nello stato locale se il sync post signup fallisce',
      build: () {
        when(() => repository.signUp('mario@example.com', 'password123'))
            .thenAnswer((_) async => const Right(baseUser));
        when(
          () => repository.updateProfileDetails(
            firstName: 'Mario',
            lastName: 'Rossi',
            username: 'mario_rossi',
            birthDate: birthDate,
            gender: 'Uomo',
          ),
        ).thenAnswer((_) async => const Left(ServerFailure('offline')));

        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(
        AuthEvent.signUpRequested(
          email: 'mario@example.com',
          password: 'password123',
          firstName: 'Mario',
          lastName: 'Rossi',
          username: 'mario_rossi',
          birthDate: birthDate,
          gender: 'Uomo',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        AuthState.authenticated(completedUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emette errore se la creazione account fallisce',
      build: () {
        when(() => repository.signUp('mario@example.com', 'password123'))
            .thenAnswer((_) async => const Left(ServerFailure('email usata')));

        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(
        AuthEvent.signUpRequested(
          email: 'mario@example.com',
          password: 'password123',
          firstName: 'Mario',
          lastName: 'Rossi',
          username: 'mario_rossi',
          birthDate: birthDate,
          gender: 'Uomo',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.error('email usata'),
      ],
      verify: (_) {
        verifyNever(
          () => repository.updateProfileDetails(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            username: any(named: 'username'),
            birthDate: any(named: 'birthDate'),
            gender: any(named: 'gender'),
          ),
        );
      },
    );
  });
}
