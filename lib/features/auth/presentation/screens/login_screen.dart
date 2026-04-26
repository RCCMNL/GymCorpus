import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/social_icons.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotEmailController = TextEditingController();
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
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
    ));
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
      if (e.code == auth_error.notAvailable) {
        // Handle not available
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
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

  Future<void> _onGooglePressed() async {
    final consent = await _showSocialConsentSheet(providerName: 'Google');
    if (!mounted || consent == null) return;

    context.read<AuthBloc>().add(
          AuthEvent.googleSignInRequested(
            acceptedTerms: consent.acceptedTerms,
            acceptedPrivacy: consent.acceptedPrivacy,
            marketingConsent: consent.marketingConsent,
            profilingConsent: consent.profilingConsent,
          ),
        );
  }

  Future<_SocialConsentResult?> _showSocialConsentSheet({
    required String providerName,
  }) {
    final theme = Theme.of(context);
    var acceptedTerms = false;
    var acceptedPrivacy = false;
    var marketingConsent = false;
    var profilingConsent = false;
    var showRequiredError = false;

    return showModalBottomSheet<_SocialConsentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Continua con $providerName',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Se questo Google account e nuovo per GymCorpus, prima dobbiamo raccogliere i consensi obbligatori. Per account gia esistenti useremo solo il login.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSocialConsentTile(
                        theme,
                        value: acceptedTerms,
                        onChanged: (value) => setModalState(() {
                          acceptedTerms = value;
                          showRequiredError = false;
                        }),
                        title: "Accetto i Termini e Condizioni d'Uso",
                        linkLabel: 'Leggi i Termini',
                        onLinkTap: () => context.push('/legal/terms'),
                      ),
                      const SizedBox(height: 10),
                      _buildSocialConsentTile(
                        theme,
                        value: acceptedPrivacy,
                        onChanged: (value) => setModalState(() {
                          acceptedPrivacy = value;
                          showRequiredError = false;
                        }),
                        title: 'Ho letto la Privacy Policy',
                        linkLabel: 'Leggi la Privacy Policy',
                        onLinkTap: () => context.push('/legal/privacy'),
                      ),
                      const SizedBox(height: 10),
                      _buildSocialConsentTile(
                        theme,
                        value: marketingConsent,
                        onChanged: (value) =>
                            setModalState(() => marketingConsent = value),
                        title: 'Consenso marketing e newsletter',
                        subtitle: 'Facoltativo e non preselezionato.',
                      ),
                      const SizedBox(height: 10),
                      _buildSocialConsentTile(
                        theme,
                        value: profilingConsent,
                        onChanged: (value) =>
                            setModalState(() => profilingConsent = value),
                        title: 'Consenso alla profilazione commerciale',
                        subtitle: 'Facoltativo e non preselezionato.',
                      ),
                      if (showRequiredError) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Termini e Privacy Policy sono necessari per creare un nuovo account.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (!acceptedTerms || !acceptedPrivacy) {
                              setModalState(() => showRequiredError = true);
                              return;
                            }
                            Navigator.of(sheetContext).pop(
                              _SocialConsentResult(
                                acceptedTerms: acceptedTerms,
                                acceptedPrivacy: acceptedPrivacy,
                                marketingConsent: marketingConsent,
                                profilingConsent: profilingConsent,
                              ),
                            );
                          },
                          child: Text(
                              'CONTINUA CON ${providerName.toUpperCase()}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSocialConsentTile(
    ThemeData theme, {
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    String? subtitle,
    String? linkLabel,
    VoidCallback? onLinkTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (linkLabel != null && onLinkTap != null) ...[
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: onLinkTap,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(linkLabel),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? Theme.of(context).colorScheme.error : Colors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ));
  }

  void _showForgotPasswordSheet() {
    _forgotEmailController.text = _emailController.text;
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.lock_reset_rounded,
                      color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Text('Recupera Password',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              Text(
                'Inserisci la tua email e ti invieremo un link per reimpostare la password.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _forgotEmailController,
                hint: 'La tua email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                action: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final email = _forgotEmailController.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      _showSnack('Inserisci un\'email valida.');
                      return;
                    }
                    context.read<AuthBloc>().add(
                          AuthEvent.forgotPasswordRequested(email: email),
                        );
                    Navigator.of(ctx).pop();
                    _showSnack('Email di recupero inviata a $email');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('INVIA LINK DI RECUPERO',
                      style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
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
            error: (e) => _showSnack(e.message, isError: true),
          );
        },
        builder: (context, state) {
          final isLoading =
              state.maybeWhen(loading: (_) => true, orElse: () => false);

          return Stack(children: [
            AmbientBackground(theme: theme),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: SlideTransition(
                            position: _slideUp,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Bentornato',
                                            style: theme.textTheme.headlineLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: -0.5,
                                                    fontSize: 32)),
                                        const SizedBox(height: 4),
                                        Text('ACCEDI AL TUO ACCOUNT',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    letterSpacing: 2,
                                                    color: theme
                                                        .colorScheme.primary
                                                        .withValues(
                                                            alpha: 0.7))),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Hero(
                                      tag: 'app_logo',
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.05),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.15),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ShaderMask(
                                          shaderCallback: (bounds) =>
                                              LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.tertiary,
                                            ],
                                          ).createShader(bounds),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/logo.png',
                                              width: 56,
                                              height: 56,
                                              color: Colors.white,
                                              colorBlendMode:
                                                  BlendMode.modulate,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 36),

                                // Glass card
                                GlassCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel(theme, 'Email'),
                                      const SizedBox(height: 8),
                                      AuthTextField(
                                        controller: _emailController,
                                        hint: 'nome@esempio.com',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofill: const [AutofillHints.email],
                                        action: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 22),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildLabel(theme, 'Password'),
                                          GestureDetector(
                                            onTap: _showForgotPasswordSheet,
                                            child: Text('Password dimenticata?',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                        color: theme.colorScheme
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AuthTextField(
                                        controller: _passwordController,
                                        hint: 'password',
                                        icon: Icons.lock_outline_rounded,
                                        obscure: _obscurePassword,
                                        autofill: const [
                                          AutofillHints.password
                                        ],
                                        action: TextInputAction.done,
                                        onSubmitted: (_) => _onLoginPressed(),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              size: 20,
                                              color: theme.colorScheme.outline),
                                          onPressed: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      AuthPrimaryButton(
                                          label: 'ACCEDI',
                                          isLoading: isLoading,
                                          onPressed: _onLoginPressed),
                                      const SizedBox(height: 28),
                                      _buildDivider(
                                          theme, 'OPPURE CONTINUA CON'),
                                      const SizedBox(height: 20),
                                      Row(children: [
                                        Expanded(
                                          child: AuthSocialButton(
                                            logo: const GoogleLogo(size: 20),
                                            label: 'Google',
                                            onTap: _onGooglePressed,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Opacity(
                                            opacity: 0.5,
                                            child: AuthSocialButton(
                                              logo: const AppleLogo(size: 22),
                                              label: 'Apple',
                                              onTap: () => _showSnack(
                                                  'Apple Sign-In in arrivo!'),
                                            ),
                                          ),
                                        ),
                                      ]),
                                      if (_showBiometricButton) ...[
                                        const SizedBox(height: 24),
                                        Center(
                                          child: Column(children: [
                                            IconButton.filledTonal(
                                              onPressed: isLoading
                                                  ? null
                                                  : _onBiometricLogin,
                                              icon: const Icon(
                                                  Icons.fingerprint,
                                                  size: 30),
                                              padding: const EdgeInsets.all(14),
                                              style: IconButton.styleFrom(
                                                backgroundColor: theme
                                                    .colorScheme.primary
                                                    .withValues(alpha: 0.1),
                                                foregroundColor:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text('Accedi con Biometria',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                        color: theme.colorScheme
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ]),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Center(
                                  child: GestureDetector(
                                    onTap: () => context.push('/signup'),
                                    child: RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant),
                                        children: [
                                          const TextSpan(
                                              text: 'Non hai un account? '),
                                          TextSpan(
                                            text: 'Registrati',
                                            style: TextStyle(
                                                color:
                                                    theme.colorScheme.tertiary,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
          ]);
        },
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5)),
    );
  }

  Widget _buildDivider(ThemeData theme, String text) {
    return Row(children: [
      Expanded(
        child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(text, style: theme.textTheme.labelSmall),
      ),
      Expanded(
        child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15)),
      ),
    ]);
  }
}

class _SocialConsentResult {
  const _SocialConsentResult({
    required this.acceptedTerms,
    required this.acceptedPrivacy,
    required this.marketingConsent,
    required this.profilingConsent,
  });

  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final bool marketingConsent;
  final bool profilingConsent;
}
