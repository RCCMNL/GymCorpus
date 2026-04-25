import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@Freezed(toStringOverride: false)
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
  const factory AuthEvent.updateProfileImageRequested({required String filePath}) = _UpdateProfileImageRequested;

  const factory AuthEvent.updateProfileRequested({
    String? firstName,
    String? lastName,
    String? username,
    String? gender,
    double? weight,
    double? height,
    DateTime? birthDate,
    String? trainingObjective,
  }) = _UpdateProfileRequested;

  const factory AuthEvent.changePasswordRequested({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequested;

  const factory AuthEvent.deleteAccountRequested() = _DeleteAccountRequested;
}
