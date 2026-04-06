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
    emit(const AuthState.loading());
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }
}
