import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/utils/biometric_messages.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_header.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/forgot_password_sheet.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/login_card.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _googleAccountNotRegisteredMessage =
      'Questo account Google non e ancora registrato. '
      'Crea prima un account dalla schermata Registrati.';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showBiometricButton = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    unawaited(_checkBiometricSupport());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _animController.forward();
  }

  Future<void> _checkBiometricSupport() async {
    final repo = GetIt.I<AuthRepository>();
    final isEnabled = await repo.isBiometricEnabled();
    if (!isEnabled) return;
    final auth = LocalAuthentication();
    final canCheck =
        await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (canCheck) {
      setState(() => _showBiometricButton = true);
      unawaited(_onBiometricLogin());
    }
  }

  Future<void> _onBiometricLogin() async {
    final auth = LocalAuthentication();
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Accedi a GymCorpus',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (didAuthenticate && mounted) {
        context.read<AuthBloc>().add(const AuthEvent.checkSessionRequested());
      }
    } on PlatformException catch (e) {
      // Prima ogni PlatformException veniva scartata senza log ne' messaggio:
      // con il sensore bloccato da troppi tentativi il pulsante sembrava
      // semplicemente non funzionare.
      debugPrint('LoginScreen._onBiometricLogin: ${e.code} ${e.message}');
      _showBiometricError(biometricErrorMessage(e));
    } catch (e) {
      // Il metodo viene lanciato con unawaited da initState: un errore non
      // tipizzato diventerebbe un errore non gestito.
      debugPrint('LoginScreen._onBiometricLogin: $e');
      _showBiometricError(
        'Non e stato possibile completare il riconoscimento.',
      );
    }
  }

  void _showBiometricError(String message) {
    if (!mounted) return;
    AppSnackBar.show(context, message);
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Inserisci email e password.');
      return;
    }
    context.read<AuthBloc>().add(
      AuthEvent.loginRequested(email: email, password: password),
    );
  }

  /// Su iOS l'accesso con Apple e' richiesto quando se ne offre un altro di
  /// terze parti: e' la linea guida 4.8 dell'App Store.
  static bool get _showsAppleSignIn =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> _onApplePressed() async {
    context.read<AuthBloc>().add(const AuthEvent.appleSignInRequested());
  }

  Future<void> _onGooglePressed() async {
    context.read<AuthBloc>().add(const AuthEvent.googleSignInRequested());
  }

  void _showSnack(String msg, {bool isError = false}) {
    AppSnackBar.show(
      context,
      msg,
      tone: isError ? AppSnackBarTone.error : AppSnackBarTone.warning,
    );
  }

  void _handleAuthError(String message) {
    _showSnack(message, isError: true);

    if (message == _googleAccountNotRegisteredMessage) {
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        context.push('/signup');
      });
    }
  }

  void _showForgotPassword() {
    unawaited(
      showForgotPasswordSheet(context, initialEmail: _emailController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.mapOrNull(
            authenticated: (_) => context.go('/training'),
            error: (e) => _handleAuthError(e.message),
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );

          return Stack(
            children: [
              AmbientBackground(theme: theme),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: FadeTransition(
                            opacity: _fadeIn,
                            child: SlideTransition(
                              position: _slideUp,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const AuthHeader(
                                    title: 'Bentornato',
                                    subtitle: 'ACCEDI AL TUO ACCOUNT',
                                  ),
                                  const SizedBox(height: 36),
                                  // Glass card
                                  LoginCard(
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    isLoading: isLoading,
                                    showsAppleSignIn: _showsAppleSignIn,
                                    showsBiometricButton: _showBiometricButton,
                                    onToggleObscure: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    onLogin: _onLoginPressed,
                                    onForgotPassword: _showForgotPassword,
                                    onGoogle: () =>
                                        unawaited(_onGooglePressed()),
                                    onApple: () => unawaited(_onApplePressed()),
                                    onBiometric: () =>
                                        unawaited(_onBiometricLogin()),
                                  ),
                                  const SizedBox(height: 28),
                                  AuthFooterPrompt(
                                    question: 'Non hai un account? ',
                                    action: 'Registrati',
                                    onTap: () => context.push('/signup'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
