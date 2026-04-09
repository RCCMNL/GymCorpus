// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent()';
  }
}

/// @nodoc
class $AuthEventCopyWith<$Res> {
  $AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}

/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckSessionRequested value)? checkSessionRequested,
    TResult Function(_LoginRequested value)? loginRequested,
    TResult Function(_SignUpRequested value)? signUpRequested,
    TResult Function(_ForgotPasswordRequested value)? forgotPasswordRequested,
    TResult Function(_GoogleSignInRequested value)? googleSignInRequested,
    TResult Function(_AppleSignInRequested value)? appleSignInRequested,
    TResult Function(_LogoutRequested value)? logoutRequested,
    TResult Function(_UpdateProfileImageRequested value)?
        updateProfileImageRequested,
    TResult Function(_UpdateProfileRequested value)? updateProfileRequested,
    TResult Function(_ChangePasswordRequested value)? changePasswordRequested,
    TResult Function(_DeleteAccountRequested value)? deleteAccountRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested(_that);
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested(_that);
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested(_that);
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
      case _UpdateProfileImageRequested()
          when updateProfileImageRequested != null:
        return updateProfileImageRequested(_that);
      case _UpdateProfileRequested() when updateProfileRequested != null:
        return updateProfileRequested(_that);
      case _ChangePasswordRequested() when changePasswordRequested != null:
        return changePasswordRequested(_that);
      case _DeleteAccountRequested() when deleteAccountRequested != null:
        return deleteAccountRequested(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckSessionRequested value)
        checkSessionRequested,
    required TResult Function(_LoginRequested value) loginRequested,
    required TResult Function(_SignUpRequested value) signUpRequested,
    required TResult Function(_ForgotPasswordRequested value)
        forgotPasswordRequested,
    required TResult Function(_GoogleSignInRequested value)
        googleSignInRequested,
    required TResult Function(_AppleSignInRequested value) appleSignInRequested,
    required TResult Function(_LogoutRequested value) logoutRequested,
    required TResult Function(_UpdateProfileImageRequested value)
        updateProfileImageRequested,
    required TResult Function(_UpdateProfileRequested value)
        updateProfileRequested,
    required TResult Function(_ChangePasswordRequested value)
        changePasswordRequested,
    required TResult Function(_DeleteAccountRequested value)
        deleteAccountRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested():
        return checkSessionRequested(_that);
      case _LoginRequested():
        return loginRequested(_that);
      case _SignUpRequested():
        return signUpRequested(_that);
      case _ForgotPasswordRequested():
        return forgotPasswordRequested(_that);
      case _GoogleSignInRequested():
        return googleSignInRequested(_that);
      case _AppleSignInRequested():
        return appleSignInRequested(_that);
      case _LogoutRequested():
        return logoutRequested(_that);
      case _UpdateProfileImageRequested():
        return updateProfileImageRequested(_that);
      case _UpdateProfileRequested():
        return updateProfileRequested(_that);
      case _ChangePasswordRequested():
        return changePasswordRequested(_that);
      case _DeleteAccountRequested():
        return deleteAccountRequested(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckSessionRequested value)? checkSessionRequested,
    TResult? Function(_LoginRequested value)? loginRequested,
    TResult? Function(_SignUpRequested value)? signUpRequested,
    TResult? Function(_ForgotPasswordRequested value)? forgotPasswordRequested,
    TResult? Function(_GoogleSignInRequested value)? googleSignInRequested,
    TResult? Function(_AppleSignInRequested value)? appleSignInRequested,
    TResult? Function(_LogoutRequested value)? logoutRequested,
    TResult? Function(_UpdateProfileImageRequested value)?
        updateProfileImageRequested,
    TResult? Function(_UpdateProfileRequested value)? updateProfileRequested,
    TResult? Function(_ChangePasswordRequested value)? changePasswordRequested,
    TResult? Function(_DeleteAccountRequested value)? deleteAccountRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested(_that);
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested(_that);
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested(_that);
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
      case _UpdateProfileImageRequested()
          when updateProfileImageRequested != null:
        return updateProfileImageRequested(_that);
      case _UpdateProfileRequested() when updateProfileRequested != null:
        return updateProfileRequested(_that);
      case _ChangePasswordRequested() when changePasswordRequested != null:
        return changePasswordRequested(_that);
      case _DeleteAccountRequested() when deleteAccountRequested != null:
        return deleteAccountRequested(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkSessionRequested,
    TResult Function(String email, String password)? loginRequested,
    TResult Function(String email, String password)? signUpRequested,
    TResult Function(String email)? forgotPasswordRequested,
    TResult Function()? googleSignInRequested,
    TResult Function()? appleSignInRequested,
    TResult Function()? logoutRequested,
    TResult Function(String filePath)? updateProfileImageRequested,
    TResult Function(
            String? firstName,
            String? lastName,
            String? username,
            String? gender,
            double? weight,
            double? height,
            DateTime? birthDate,
            String? trainingObjective)?
        updateProfileRequested,
    TResult Function(String currentPassword, String newPassword)?
        changePasswordRequested,
    TResult Function()? deleteAccountRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested();
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that.email, _that.password);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that.email, _that.password);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that.email);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested();
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested();
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested();
      case _UpdateProfileImageRequested()
          when updateProfileImageRequested != null:
        return updateProfileImageRequested(_that.filePath);
      case _UpdateProfileRequested() when updateProfileRequested != null:
        return updateProfileRequested(
            _that.firstName,
            _that.lastName,
            _that.username,
            _that.gender,
            _that.weight,
            _that.height,
            _that.birthDate,
            _that.trainingObjective);
      case _ChangePasswordRequested() when changePasswordRequested != null:
        return changePasswordRequested(
            _that.currentPassword, _that.newPassword);
      case _DeleteAccountRequested() when deleteAccountRequested != null:
        return deleteAccountRequested();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkSessionRequested,
    required TResult Function(String email, String password) loginRequested,
    required TResult Function(String email, String password) signUpRequested,
    required TResult Function(String email) forgotPasswordRequested,
    required TResult Function() googleSignInRequested,
    required TResult Function() appleSignInRequested,
    required TResult Function() logoutRequested,
    required TResult Function(String filePath) updateProfileImageRequested,
    required TResult Function(
            String? firstName,
            String? lastName,
            String? username,
            String? gender,
            double? weight,
            double? height,
            DateTime? birthDate,
            String? trainingObjective)
        updateProfileRequested,
    required TResult Function(String currentPassword, String newPassword)
        changePasswordRequested,
    required TResult Function() deleteAccountRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested():
        return checkSessionRequested();
      case _LoginRequested():
        return loginRequested(_that.email, _that.password);
      case _SignUpRequested():
        return signUpRequested(_that.email, _that.password);
      case _ForgotPasswordRequested():
        return forgotPasswordRequested(_that.email);
      case _GoogleSignInRequested():
        return googleSignInRequested();
      case _AppleSignInRequested():
        return appleSignInRequested();
      case _LogoutRequested():
        return logoutRequested();
      case _UpdateProfileImageRequested():
        return updateProfileImageRequested(_that.filePath);
      case _UpdateProfileRequested():
        return updateProfileRequested(
            _that.firstName,
            _that.lastName,
            _that.username,
            _that.gender,
            _that.weight,
            _that.height,
            _that.birthDate,
            _that.trainingObjective);
      case _ChangePasswordRequested():
        return changePasswordRequested(
            _that.currentPassword, _that.newPassword);
      case _DeleteAccountRequested():
        return deleteAccountRequested();
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkSessionRequested,
    TResult? Function(String email, String password)? loginRequested,
    TResult? Function(String email, String password)? signUpRequested,
    TResult? Function(String email)? forgotPasswordRequested,
    TResult? Function()? googleSignInRequested,
    TResult? Function()? appleSignInRequested,
    TResult? Function()? logoutRequested,
    TResult? Function(String filePath)? updateProfileImageRequested,
    TResult? Function(
            String? firstName,
            String? lastName,
            String? username,
            String? gender,
            double? weight,
            double? height,
            DateTime? birthDate,
            String? trainingObjective)?
        updateProfileRequested,
    TResult? Function(String currentPassword, String newPassword)?
        changePasswordRequested,
    TResult? Function()? deleteAccountRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested();
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that.email, _that.password);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that.email, _that.password);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that.email);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested();
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested();
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested();
      case _UpdateProfileImageRequested()
          when updateProfileImageRequested != null:
        return updateProfileImageRequested(_that.filePath);
      case _UpdateProfileRequested() when updateProfileRequested != null:
        return updateProfileRequested(
            _that.firstName,
            _that.lastName,
            _that.username,
            _that.gender,
            _that.weight,
            _that.height,
            _that.birthDate,
            _that.trainingObjective);
      case _ChangePasswordRequested() when changePasswordRequested != null:
        return changePasswordRequested(
            _that.currentPassword, _that.newPassword);
      case _DeleteAccountRequested() when deleteAccountRequested != null:
        return deleteAccountRequested();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CheckSessionRequested implements AuthEvent {
  const _CheckSessionRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _CheckSessionRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.checkSessionRequested()';
  }
}

/// @nodoc

class _LoginRequested implements AuthEvent {
  const _LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoginRequestedCopyWith<_LoginRequested> get copyWith =>
      __$LoginRequestedCopyWithImpl<_LoginRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoginRequested &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @override
  String toString() {
    return 'AuthEvent.loginRequested(email: $email, password: $password)';
  }
}

/// @nodoc
abstract mixin class _$LoginRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$LoginRequestedCopyWith(
          _LoginRequested value, $Res Function(_LoginRequested) _then) =
      __$LoginRequestedCopyWithImpl;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$LoginRequestedCopyWithImpl<$Res>
    implements _$LoginRequestedCopyWith<$Res> {
  __$LoginRequestedCopyWithImpl(this._self, this._then);

  final _LoginRequested _self;
  final $Res Function(_LoginRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_LoginRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _SignUpRequested implements AuthEvent {
  const _SignUpRequested({required this.email, required this.password});

  final String email;
  final String password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SignUpRequestedCopyWith<_SignUpRequested> get copyWith =>
      __$SignUpRequestedCopyWithImpl<_SignUpRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SignUpRequested &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @override
  String toString() {
    return 'AuthEvent.signUpRequested(email: $email, password: $password)';
  }
}

/// @nodoc
abstract mixin class _$SignUpRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$SignUpRequestedCopyWith(
          _SignUpRequested value, $Res Function(_SignUpRequested) _then) =
      __$SignUpRequestedCopyWithImpl;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$SignUpRequestedCopyWithImpl<$Res>
    implements _$SignUpRequestedCopyWith<$Res> {
  __$SignUpRequestedCopyWithImpl(this._self, this._then);

  final _SignUpRequested _self;
  final $Res Function(_SignUpRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_SignUpRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _ForgotPasswordRequested implements AuthEvent {
  const _ForgotPasswordRequested({required this.email});

  final String email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ForgotPasswordRequestedCopyWith<_ForgotPasswordRequested> get copyWith =>
      __$ForgotPasswordRequestedCopyWithImpl<_ForgotPasswordRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ForgotPasswordRequested &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'AuthEvent.forgotPasswordRequested(email: $email)';
  }
}

/// @nodoc
abstract mixin class _$ForgotPasswordRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$ForgotPasswordRequestedCopyWith(_ForgotPasswordRequested value,
          $Res Function(_ForgotPasswordRequested) _then) =
      __$ForgotPasswordRequestedCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$ForgotPasswordRequestedCopyWithImpl<$Res>
    implements _$ForgotPasswordRequestedCopyWith<$Res> {
  __$ForgotPasswordRequestedCopyWithImpl(this._self, this._then);

  final _ForgotPasswordRequested _self;
  final $Res Function(_ForgotPasswordRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
  }) {
    return _then(_ForgotPasswordRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _GoogleSignInRequested implements AuthEvent {
  const _GoogleSignInRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _GoogleSignInRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.googleSignInRequested()';
  }
}

/// @nodoc

class _AppleSignInRequested implements AuthEvent {
  const _AppleSignInRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _AppleSignInRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.appleSignInRequested()';
  }
}

/// @nodoc

class _LogoutRequested implements AuthEvent {
  const _LogoutRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _LogoutRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.logoutRequested()';
  }
}

/// @nodoc

class _UpdateProfileImageRequested implements AuthEvent {
  const _UpdateProfileImageRequested({required this.filePath});

  final String filePath;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateProfileImageRequestedCopyWith<_UpdateProfileImageRequested>
      get copyWith => __$UpdateProfileImageRequestedCopyWithImpl<
          _UpdateProfileImageRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateProfileImageRequested &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filePath);

  @override
  String toString() {
    return 'AuthEvent.updateProfileImageRequested(filePath: $filePath)';
  }
}

/// @nodoc
abstract mixin class _$UpdateProfileImageRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$UpdateProfileImageRequestedCopyWith(
          _UpdateProfileImageRequested value,
          $Res Function(_UpdateProfileImageRequested) _then) =
      __$UpdateProfileImageRequestedCopyWithImpl;
  @useResult
  $Res call({String filePath});
}

/// @nodoc
class __$UpdateProfileImageRequestedCopyWithImpl<$Res>
    implements _$UpdateProfileImageRequestedCopyWith<$Res> {
  __$UpdateProfileImageRequestedCopyWithImpl(this._self, this._then);

  final _UpdateProfileImageRequested _self;
  final $Res Function(_UpdateProfileImageRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? filePath = null,
  }) {
    return _then(_UpdateProfileImageRequested(
      filePath: null == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _UpdateProfileRequested implements AuthEvent {
  const _UpdateProfileRequested(
      {this.firstName,
      this.lastName,
      this.username,
      this.gender,
      this.weight,
      this.height,
      this.birthDate,
      this.trainingObjective});

  final String? firstName;
  final String? lastName;
  final String? username;
  final String? gender;
  final double? weight;
  final double? height;
  final DateTime? birthDate;
  final String? trainingObjective;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateProfileRequestedCopyWith<_UpdateProfileRequested> get copyWith =>
      __$UpdateProfileRequestedCopyWithImpl<_UpdateProfileRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateProfileRequested &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.trainingObjective, trainingObjective) ||
                other.trainingObjective == trainingObjective));
  }

  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, username,
      gender, weight, height, birthDate, trainingObjective);

  @override
  String toString() {
    return 'AuthEvent.updateProfileRequested(firstName: $firstName, lastName: $lastName, username: $username, gender: $gender, weight: $weight, height: $height, birthDate: $birthDate, trainingObjective: $trainingObjective)';
  }
}

/// @nodoc
abstract mixin class _$UpdateProfileRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$UpdateProfileRequestedCopyWith(_UpdateProfileRequested value,
          $Res Function(_UpdateProfileRequested) _then) =
      __$UpdateProfileRequestedCopyWithImpl;
  @useResult
  $Res call(
      {String? firstName,
      String? lastName,
      String? username,
      String? gender,
      double? weight,
      double? height,
      DateTime? birthDate,
      String? trainingObjective});
}

/// @nodoc
class __$UpdateProfileRequestedCopyWithImpl<$Res>
    implements _$UpdateProfileRequestedCopyWith<$Res> {
  __$UpdateProfileRequestedCopyWithImpl(this._self, this._then);

  final _UpdateProfileRequested _self;
  final $Res Function(_UpdateProfileRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? username = freezed,
    Object? gender = freezed,
    Object? weight = freezed,
    Object? height = freezed,
    Object? birthDate = freezed,
    Object? trainingObjective = freezed,
  }) {
    return _then(_UpdateProfileRequested(
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      birthDate: freezed == birthDate
          ? _self.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      trainingObjective: freezed == trainingObjective
          ? _self.trainingObjective
          : trainingObjective // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _ChangePasswordRequested implements AuthEvent {
  const _ChangePasswordRequested(
      {required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChangePasswordRequestedCopyWith<_ChangePasswordRequested> get copyWith =>
      __$ChangePasswordRequestedCopyWithImpl<_ChangePasswordRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChangePasswordRequested &&
            (identical(other.currentPassword, currentPassword) ||
                other.currentPassword == currentPassword) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentPassword, newPassword);

  @override
  String toString() {
    return 'AuthEvent.changePasswordRequested(currentPassword: $currentPassword, newPassword: $newPassword)';
  }
}

/// @nodoc
abstract mixin class _$ChangePasswordRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$ChangePasswordRequestedCopyWith(_ChangePasswordRequested value,
          $Res Function(_ChangePasswordRequested) _then) =
      __$ChangePasswordRequestedCopyWithImpl;
  @useResult
  $Res call({String currentPassword, String newPassword});
}

/// @nodoc
class __$ChangePasswordRequestedCopyWithImpl<$Res>
    implements _$ChangePasswordRequestedCopyWith<$Res> {
  __$ChangePasswordRequestedCopyWithImpl(this._self, this._then);

  final _ChangePasswordRequested _self;
  final $Res Function(_ChangePasswordRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentPassword = null,
    Object? newPassword = null,
  }) {
    return _then(_ChangePasswordRequested(
      currentPassword: null == currentPassword
          ? _self.currentPassword
          : currentPassword // ignore: cast_nullable_to_non_nullable
              as String,
      newPassword: null == newPassword
          ? _self.newPassword
          : newPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _DeleteAccountRequested implements AuthEvent {
  const _DeleteAccountRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _DeleteAccountRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.deleteAccountRequested()';
  }
}

// dart format on
