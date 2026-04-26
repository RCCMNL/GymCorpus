import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:injectable/injectable.dart';

const currentLegalVersion = '2026-04-26';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        checkSessionRequested: (e) async => _onCheckSession(emit),
        loginRequested: (e) async => _onLogin(e.email, e.password, emit),
        signUpRequested: (e) async => _onSignUp(
          email: e.email,
          password: e.password,
          firstName: e.firstName,
          lastName: e.lastName,
          username: e.username,
          birthDate: e.birthDate,
          gender: e.gender,
          acceptedTerms: e.acceptedTerms,
          acceptedPrivacy: e.acceptedPrivacy,
          marketingConsent: e.marketingConsent,
          profilingConsent: e.profilingConsent,
          emit: emit,
        ),
        forgotPasswordRequested: (e) async => _onForgotPassword(e.email, emit),
        googleSignInRequested: (e) async => _onGoogleSignIn(
          acceptedTerms: e.acceptedTerms,
          acceptedPrivacy: e.acceptedPrivacy,
          marketingConsent: e.marketingConsent,
          profilingConsent: e.profilingConsent,
          emit: emit,
        ),
        appleSignInRequested: (e) async => _onAppleSignIn(
          acceptedTerms: e.acceptedTerms,
          acceptedPrivacy: e.acceptedPrivacy,
          marketingConsent: e.marketingConsent,
          profilingConsent: e.profilingConsent,
          emit: emit,
        ),
        logoutRequested: (e) async => _onLogout(emit),
        updateProfileImageRequested: (e) async =>
            _onUpdateProfileImage(e.filePath, emit),
        updateProfileRequested: (e) async => _onUpdateProfile(
          firstName: e.firstName,
          lastName: e.lastName,
          username: e.username,
          gender: e.gender,
          weight: e.weight,
          height: e.height,
          birthDate: e.birthDate,
          trainingObjective: e.trainingObjective,
          emit: emit,
        ),
        changePasswordRequested: (e) async =>
            _onChangePassword(e.currentPassword, e.newPassword, emit),
        deleteAccountRequested: (e) async => _onDeleteAccount(emit),
      );
    });
  }

  final AuthRepository _repository;

  Future<void> _onCheckSession(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _repository.checkSession();
    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogin(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _repository.login(email, password);
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required DateTime birthDate,
    required String gender,
    required bool acceptedTerms,
    required bool acceptedPrivacy,
    required bool marketingConsent,
    required bool profilingConsent,
    required Emitter<AuthState> emit,
  }) async {
    if (!acceptedTerms || !acceptedPrivacy) {
      emit(
        const AuthState.error(
          'Per creare un account devi accettare Termini e Privacy Policy.',
        ),
      );
      return;
    }

    emit(const AuthState.loading());
    final result = await _repository.signUp(email, password);

    await result.fold(
      (failure) async => emit(AuthState.error(failure.props.first.toString())),
      (user) async {
        final consentTimestamp = DateTime.now();

        // Immediately update profile with additional info
        final updateResult = await _repository.updateProfileDetails(
          firstName: firstName,
          lastName: lastName,
          username: username,
          birthDate: birthDate,
          gender: gender,
          termsAcceptedAt: consentTimestamp,
          privacyAcceptedAt: consentTimestamp,
          legalVersion: currentLegalVersion,
          marketingConsent: marketingConsent,
          profilingConsent: profilingConsent,
          marketingConsentUpdatedAt: consentTimestamp,
          profilingConsentUpdatedAt: consentTimestamp,
        );

        updateResult.fold(
          (failure) {
            debugPrint(
              'AuthBloc._onSignUp profile update error: ${failure.message}',
            );
            emit(
              AuthState.authenticated(
                user.copyWith(
                  firstName: firstName,
                  lastName: lastName,
                  username: username,
                  birthDate: birthDate,
                  gender: gender,
                  termsAcceptedAt: consentTimestamp,
                  privacyAcceptedAt: consentTimestamp,
                  legalVersion: currentLegalVersion,
                  marketingConsent: marketingConsent,
                  profilingConsent: profilingConsent,
                  marketingConsentUpdatedAt: consentTimestamp,
                  profilingConsentUpdatedAt: consentTimestamp,
                ),
              ),
            );
          },
          (updatedUser) => emit(AuthState.authenticated(updatedUser)),
        );
      },
    );
  }

  Future<void> _onForgotPassword(String email, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _repository.resetPassword(email);
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> _onGoogleSignIn({
    required bool acceptedTerms,
    required bool acceptedPrivacy,
    required bool marketingConsent,
    required bool profilingConsent,
    required Emitter<AuthState> emit,
  }) async {
    emit(const AuthState.loading());
    final result = await _repository.signInWithGoogle(
      acceptedTerms: acceptedTerms,
      acceptedPrivacy: acceptedPrivacy,
      marketingConsent: marketingConsent,
      profilingConsent: profilingConsent,
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onAppleSignIn({
    required bool acceptedTerms,
    required bool acceptedPrivacy,
    required bool marketingConsent,
    required bool profilingConsent,
    required Emitter<AuthState> emit,
  }) async {
    emit(const AuthState.loading());
    final result = await _repository.signInWithApple(
      acceptedTerms: acceptedTerms,
      acceptedPrivacy: acceptedPrivacy,
      marketingConsent: marketingConsent,
      profilingConsent: profilingConsent,
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onUpdateProfileImage(
    String filePath,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state.maybeWhen(
      authenticated: (user) => user,
      loading: (prev) => prev,
      error: (msg, prev) => prev,
      orElse: () => null,
    );
    emit(AuthState.loading(previousUser: currentUser));
    final result = await _repository.updateProfileImage(filePath);
    result.fold(
      (failure) => emit(
        AuthState.error(
          failure.props.first.toString(),
          previousUser: currentUser,
        ),
      ),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onUpdateProfile({
    required Emitter<AuthState> emit,
    String? firstName,
    String? lastName,
    String? username,
    String? gender,
    double? weight,
    double? height,
    DateTime? birthDate,
    String? trainingObjective,
  }) async {
    // Do not emit loading here: it triggers the router and causes crashes
    // during navigation. Just update silently in the background.
    final result = await _repository.updateProfileDetails(
      firstName: firstName,
      lastName: lastName,
      username: username,
      gender: gender,
      weight: weight,
      height: height,
      birthDate: birthDate,
      trainingObjective: trainingObjective,
    );
    result.fold(
      (failure) {
        debugPrint('AuthBloc._onUpdateProfile error: ${failure.message}');
      },
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onChangePassword(
    String currentPassword,
    String newPassword,
    Emitter<AuthState> emit,
  ) async {
    final result =
        await _repository.changePassword(currentPassword, newPassword);
    result.fold(
      (failure) {
        // Handle failure locally in UI instead of emitting state, as the UI stays open
        final currentUser = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
        emit(
          AuthState.error(
            failure.props.first.toString(),
            previousUser: currentUser,
          ),
        );
      },
      (_) {
        // Success - UI will close itself, state remains authenticated
      },
    );
  }

  Future<void> _onDeleteAccount(Emitter<AuthState> emit) async {
    final result = await _repository.deleteAccount();
    result.fold(
      (failure) {
        final currentUser = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
        emit(
          AuthState.error(
            failure.props.first.toString(),
            previousUser: currentUser,
          ),
        );
      },
      (_) => emit(const AuthState.unauthenticated()),
    );
  }
}
