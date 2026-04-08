import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        checkSessionRequested: (e) async => _onCheckSession(emit),
        loginRequested: (e) async => _onLogin(e.email, e.password, emit),
        signUpRequested: (e) async => _onSignUp(e.email, e.password, emit),
        forgotPasswordRequested: (e) async => _onForgotPassword(e.email, emit),
        googleSignInRequested: (e) async => _onGoogleSignIn(emit),
        appleSignInRequested: (e) async => _onAppleSignIn(emit),
        logoutRequested: (e) async => _onLogout(emit),
        updateProfileImageRequested: (e) async => _onUpdateProfileImage(e.filePath, emit),
        updateProfileRequested: (e) async => _onUpdateProfile(
          name: e.name,
          username: e.username,
          weight: e.weight,
          height: e.height,
          birthDate: e.birthDate,
          trainingObjective: e.trainingObjective,
          emit: emit,
        ),
        changePasswordRequested: (e) async => _onChangePassword(e.currentPassword, e.newPassword, emit),
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

  Future<void> _onLogin(String email, String password, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _repository.login(email, password);
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignUp(String email, String password, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _repository.signUp(email, password);
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (user) => emit(AuthState.authenticated(user)),
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

  Future<void> _onGoogleSignIn(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _repository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onAppleSignIn(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _repository.signInWithApple();
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString())),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onUpdateProfileImage(String filePath, Emitter<AuthState> emit) async {
    final currentUser = state.maybeWhen(
      authenticated: (user) => user, 
      loading: (prev) => prev,
      error: (msg, prev) => prev,
      orElse: () => null,
    );
    emit(AuthState.loading(previousUser: currentUser));
    final result = await _repository.updateProfileImage(filePath);
    result.fold(
      (failure) => emit(AuthState.error(failure.props.first.toString(), previousUser: currentUser)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onUpdateProfile({
    required Emitter<AuthState> emit,
    String? name,
    String? username,
    double? weight,
    double? height,
    DateTime? birthDate,
    String? trainingObjective,
  }) async {
    // Do NOT emit loading — it triggers the router and causes crashes
    // during navigation. Just update silently in the background.
    final result = await _repository.updateProfileDetails(
      name: name,
      username: username,
      weight: weight,
      height: height,
      birthDate: birthDate,
      trainingObjective: trainingObjective,
    );
    result.fold(
      (failure) {
        // Silently fail — data is already saved locally
        // The user already navigated back, no point showing an error
      },
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onChangePassword(String currentPassword, String newPassword, Emitter<AuthState> emit) async {
    final result = await _repository.changePassword(currentPassword, newPassword);
    result.fold(
      (failure) {
        // Handle failure locally in UI instead of emitting state, as the UI stays open
        final currentUser = state.maybeWhen(
          authenticated: (user) => user, 
          orElse: () => null,
        );
        emit(AuthState.error(failure.props.first.toString(), previousUser: currentUser));
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
        emit(AuthState.error(failure.props.first.toString(), previousUser: currentUser));
      },
      (_) => emit(const AuthState.unauthenticated()),
    );
  }
}
