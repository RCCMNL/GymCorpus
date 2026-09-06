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
    final consentDate = DateTime(2026, 4, 26, 12);
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
      termsAcceptedAt: consentDate,
      privacyAcceptedAt: consentDate,
      legalVersion: currentLegalVersion,
      marketingConsent: true,
      profilingConsent: false,
      marketingConsentUpdatedAt: consentDate,
      profilingConsentUpdatedAt: consentDate,
    );

    blocTest<AuthBloc, AuthState>(
      'registra l utente e salva profilo e consensi granulari',
      build: () {
        when(
          () => repository.signUp('mario@example.com', 'password123'),
        ).thenAnswer((_) async => const Right(baseUser));
        when(
          () => repository.updateProfileDetails(
            firstName: 'Mario',
            lastName: 'Rossi',
            username: 'mario_rossi',
            birthDate: birthDate,
            gender: 'Uomo',
            termsAcceptedAt: any(named: 'termsAcceptedAt'),
            privacyAcceptedAt: any(named: 'privacyAcceptedAt'),
            legalVersion: currentLegalVersion,
            marketingConsent: true,
            profilingConsent: false,
            marketingConsentUpdatedAt: any(named: 'marketingConsentUpdatedAt'),
            profilingConsentUpdatedAt: any(named: 'profilingConsentUpdatedAt'),
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
          acceptedTerms: true,
          acceptedPrivacy: true,
          marketingConsent: true,
          profilingConsent: false,
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        AuthState.authenticated(completedUser),
      ],
      verify: (_) {
        verify(
          () => repository.signUp('mario@example.com', 'password123'),
        ).called(1);
        verify(
          () => repository.updateProfileDetails(
            firstName: 'Mario',
            lastName: 'Rossi',
            username: 'mario_rossi',
            birthDate: birthDate,
            gender: 'Uomo',
            termsAcceptedAt: any(named: 'termsAcceptedAt'),
            privacyAcceptedAt: any(named: 'privacyAcceptedAt'),
            legalVersion: currentLegalVersion,
            marketingConsent: true,
            profilingConsent: false,
            marketingConsentUpdatedAt: any(named: 'marketingConsentUpdatedAt'),
            profilingConsentUpdatedAt: any(named: 'profilingConsentUpdatedAt'),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'mantiene i dati profilo nello stato locale se il sync post signup fallisce',
      build: () {
        when(
          () => repository.signUp('mario@example.com', 'password123'),
        ).thenAnswer((_) async => const Right(baseUser));
        when(
          () => repository.updateProfileDetails(
            firstName: 'Mario',
            lastName: 'Rossi',
            username: 'mario_rossi',
            birthDate: birthDate,
            gender: 'Uomo',
            termsAcceptedAt: any(named: 'termsAcceptedAt'),
            privacyAcceptedAt: any(named: 'privacyAcceptedAt'),
            legalVersion: currentLegalVersion,
            marketingConsent: true,
            profilingConsent: false,
            marketingConsentUpdatedAt: any(named: 'marketingConsentUpdatedAt'),
            profilingConsentUpdatedAt: any(named: 'profilingConsentUpdatedAt'),
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
          acceptedTerms: true,
          acceptedPrivacy: true,
          marketingConsent: true,
          profilingConsent: false,
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        isA<AuthState>()
            .having(
              (state) => state.maybeWhen(
                authenticated: (user, _) => user.firstName,
                orElse: () => null,
              ),
              'firstName',
              'Mario',
            )
            .having(
              (state) => state.maybeWhen(
                authenticated: (user, _) => user.termsAcceptedAt,
                orElse: () => null,
              ),
              'termsAcceptedAt',
              isNotNull,
            )
            .having(
              (state) => state.maybeWhen(
                authenticated: (user, _) => user.marketingConsent,
                orElse: () => null,
              ),
              'marketingConsent',
              true,
            )
            .having(
              (state) => state.maybeWhen(
                authenticated: (user, _) => user.profilingConsent,
                orElse: () => null,
              ),
              'profilingConsent',
              false,
            ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emette errore se la creazione account fallisce',
      build: () {
        when(
          () => repository.signUp('mario@example.com', 'password123'),
        ).thenAnswer((_) async => const Left(ServerFailure('email usata')));

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
          acceptedTerms: true,
          acceptedPrivacy: true,
          marketingConsent: false,
          profilingConsent: false,
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

    blocTest<AuthBloc, AuthState>(
      'blocca la registrazione se mancano i consensi obbligatori',
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(
        AuthEvent.signUpRequested(
          email: 'mario@example.com',
          password: 'password123',
          firstName: 'Mario',
          lastName: 'Rossi',
          username: 'mario_rossi',
          birthDate: birthDate,
          gender: 'Uomo',
          acceptedTerms: false,
          acceptedPrivacy: true,
          marketingConsent: false,
          profilingConsent: false,
        ),
      ),
      expect: () => [
        const AuthState.error(
          'Per creare un account devi accettare Termini e Privacy Policy.',
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.signUp(any(), any()));
      },
    );
  });

  group('aggiornamento profilo', () {
    const user = UserEntity(id: 'u1', email: 'mario@example.com');

    blocTest<AuthBloc, AuthState>(
      'un salvataggio riuscito porta il profilo aggiornato',
      build: () {
        when(
          () => repository.updateProfileDetails(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            username: any(named: 'username'),
            gender: any(named: 'gender'),
            weight: any(named: 'weight'),
            height: any(named: 'height'),
            birthDate: any(named: 'birthDate'),
            trainingObjective: any(named: 'trainingObjective'),
            syncWeightHistory: any(named: 'syncWeightHistory'),
          ),
        ).thenAnswer(
          (_) async => const Right(UserEntity(id: 'u1', email: 'm@e.com')),
        );

        return AuthBloc(repository);
      },
      act: (bloc) =>
          bloc.add(const AuthEvent.updateProfileRequested(gender: 'Donna')),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.maybeWhen(
            authenticated: (_, actionError) => actionError,
            orElse: () => 'stato inatteso',
          ),
          'errore',
          isNull,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'un salvataggio fallito segnala l errore senza disconnettere',
      // Dietro il cancello dell'onboarding un errore muto diventa un
      // pulsante che non risponde: l'utente resta autenticato, ma deve
      // sapere che il salvataggio non e' andato a buon fine.
      build: () {
        when(
          () => repository.updateProfileDetails(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            username: any(named: 'username'),
            gender: any(named: 'gender'),
            weight: any(named: 'weight'),
            height: any(named: 'height'),
            birthDate: any(named: 'birthDate'),
            trainingObjective: any(named: 'trainingObjective'),
            syncWeightHistory: any(named: 'syncWeightHistory'),
          ),
        ).thenAnswer((_) async => const Left(ServerFailure('rete assente')));

        return AuthBloc(repository);
      },
      seed: () => const AuthState.authenticated(user),
      act: (bloc) =>
          bloc.add(const AuthEvent.updateProfileRequested(gender: 'Donna')),
      expect: () => [const AuthState.authenticated(user, actionError: 'rete assente')],
    );

    blocTest<AuthBloc, AuthState>(
      'l errore precedente non resta appiccicato al tentativo successivo',
      build: () {
        when(
          () => repository.updateProfileDetails(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            username: any(named: 'username'),
            gender: any(named: 'gender'),
            weight: any(named: 'weight'),
            height: any(named: 'height'),
            birthDate: any(named: 'birthDate'),
            trainingObjective: any(named: 'trainingObjective'),
            syncWeightHistory: any(named: 'syncWeightHistory'),
          ),
        ).thenAnswer((_) async => const Right(user));

        return AuthBloc(repository);
      },
      seed: () =>
          const AuthState.authenticated(user, actionError: 'rete assente'),
      act: (bloc) =>
          bloc.add(const AuthEvent.updateProfileRequested(gender: 'Donna')),
      expect: () => [const AuthState.authenticated(user)],
    );
  });
}
