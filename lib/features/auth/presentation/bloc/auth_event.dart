import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkSessionRequested() = _CheckSessionRequested;
  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = _LoginRequested;
  const factory AuthEvent.signUpRequested({
    required String email,
    required String password,
  }) = _SignUpRequested;
  const factory AuthEvent.forgotPasswordRequested({
    required String email,
  }) = _ForgotPasswordRequested;

  const factory AuthEvent.googleSignInRequested() = _GoogleSignInRequested;

  const factory AuthEvent.appleSignInRequested() = _AppleSignInRequested;

  const factory AuthEvent.logoutRequested() = _LogoutRequested;
}
