import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/social_icons.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_header.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/legal_consent_field.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/profile_basics_form.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/sign_up_progress.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedLegal = false;
  final bool _marketingConsent = false;
  final bool _profilingConsent = false;
  int _currentStep = 0;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = false}) {
    AppSnackBar.show(
      context,
      msg,
      tone: isError ? AppSnackBarTone.error : AppSnackBarTone.warning,
    );
  }

  void _goToStep2() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Compila tutti i campi.');
      return;
    }
    if (!email.contains('@')) {
      _showSnack('Inserisci un indirizzo email valido.');
      return;
    }
    if (password.length < 6) {
      _showSnack('La password deve contenere almeno 6 caratteri.');
      return;
    }
    if (password != confirm) {
      _showSnack('Le password non coincidono.', isError: true);
      return;
    }

    setState(() {
      _currentStep = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Su iOS l'accesso con Apple e' richiesto quando se ne offre un altro di
  /// terze parti: e' la linea guida 4.8 dell'App Store.
  static bool get _showsAppleSignIn =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Con un provider esterno il profilo non si chiede qui: dopo
  /// l'autenticazione ci pensa l'onboarding, che copre anche chi interrompe
  /// a meta'. Restano i consensi, che vanno raccolti prima di creare
  /// l'account: il repository cancella l'utente appena creato se non sono
  /// stati accettati.
  Future<void> _startSocialSignUp(SocialProvider provider) async {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SocialConsentSheet(provider: provider),
    );

    if (accepted != true || !mounted) return;

    context.read<AuthBloc>().add(
      provider == SocialProvider.google
          ? AuthEvent.googleSignInRequested(
              acceptedTerms: true,
              acceptedPrivacy: true,
              marketingConsent: _marketingConsent,
              profilingConsent: _profilingConsent,
            )
          : AuthEvent.appleSignInRequested(
              acceptedTerms: true,
              acceptedPrivacy: true,
              marketingConsent: _marketingConsent,
              profilingConsent: _profilingConsent,
            ),
    );
  }

  void _goBackToStep1() {
    setState(() => _currentStep = 0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onSubmit(ProfileBasics basics) {
    if (!_acceptedLegal) {
      _showSnack(
        'Accetta Termini e Privacy Policy per creare l account.',
        isError: true,
      );
      return;
    }

    // Il form garantisce che i campi ci siano tutti: qui resta da verificare
    // solo il consenso, che vive nel footer di questa schermata.
    context.read<AuthBloc>().add(
      AuthEvent.signUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: basics.firstName,
        lastName: basics.lastName,
        username: basics.username,
        birthDate: basics.birthDate!,
        gender: basics.gender!,
        acceptedTerms: _acceptedLegal,
        acceptedPrivacy: _acceptedLegal,
        marketingConsent: _marketingConsent,
        profilingConsent: _profilingConsent,
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
            // Con un profilo incompleto, per esempio dopo l'accesso con
            // Google, e' il cancello del router a dirottare sull'onboarding.
            authenticated: (_) => context.go('/training'),
            error: (e) => _showSnack(e.message, isError: true),
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
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Column(
                      children: [
                        SignUpTopBar(
                          currentStep: _currentStep,
                          onBack: () {
                            if (_currentStep == 1) {
                              _goBackToStep1();
                            } else {
                              context.pop();
                            }
                          },
                        ),
                        SignUpStepIndicator(currentStep: _currentStep),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildStep1(theme, isLoading),
                              _buildStep2(theme, isLoading),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const AuthHeader(
            title: 'Crea il tuo account',
            subtitle: 'INIZIA IL TUO PERCORSO',
            titleSize: 28,
            logoSize: 48,
          ),
          const SizedBox(height: 28),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                authLabel(theme, 'Email'),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _emailController,
                  hint: 'nome@esempio.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  autofill: const [AutofillHints.email],
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                authLabel(theme, 'Password'),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _passwordController,
                  hint: 'Almeno 6 caratteri',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  autofill: const [AutofillHints.newPassword],
                  action: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: theme.colorScheme.outline,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                authLabel(theme, 'Conferma password'),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hint: 'Ripeti la password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  autofill: const [AutofillHints.newPassword],
                  action: TextInputAction.done,
                  onSubmitted: (_) => _goToStep2(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: theme.colorScheme.outline,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 22),
                AuthPrimaryButton(
                  label: 'CONTINUA',
                  isLoading: false,
                  onPressed: _goToStep2,
                ),
                const SizedBox(height: 22),
                authDivider(theme, 'OPPURE REGISTRATI CON'),
                const SizedBox(height: 20),
                AuthSocialButton(
                  logo: const GoogleLogo(size: 20),
                  label: 'Registrati con Google',
                  onTap: () => _startSocialSignUp(SocialProvider.google),
                ),
                if (_showsAppleSignIn) ...[
                  const SizedBox(height: 12),
                  AuthSocialButton(
                    logo: const AppleLogo(size: 20),
                    label: 'Registrati con Apple',
                    onTap: () => _startSocialSignUp(SocialProvider.apple),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          AuthFooterPrompt(
            question: 'Hai già un account? ',
            action: 'Accedi',
            onTap: () => context.pop(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.22),
                    theme.colorScheme.tertiary.withValues(alpha: 0.16),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Parlaci di te',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'COMPLETA IL TUO PROFILO',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 28),
          GlassCard(
            child: ProfileBasicsForm(
              submitLabel: 'CREA ACCOUNT',
              isLoading: isLoading,
              footer: LegalConsentField(
                value: _acceptedLegal,
                onChanged: (value) => setState(() => _acceptedLegal = value),
              ),
              onValidationError: _showSnack,
              onSubmit: _onSubmit,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Consenso legale richiesto prima di creare un account con un provider
/// esterno.
///
/// Ha uno stato tutto suo perche' vive in un foglio modale: la spunta deve
/// aggiornare il pulsante del foglio, non la schermata sotto.
/// Provider esterno con cui si sta creando l'account.
enum SocialProvider { google, apple }

class _SocialConsentSheet extends StatefulWidget {
  const _SocialConsentSheet({required this.provider});

  final SocialProvider provider;

  @override
  State<_SocialConsentSheet> createState() => _SocialConsentSheetState();
}

class _SocialConsentSheetState extends State<_SocialConsentSheet> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Prima di continuare',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Il resto del profilo te lo chiediamo subito dopo, una volta '
            'entrato.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          LegalConsentField(
            value: _accepted,
            onChanged: (value) => setState(() => _accepted = value),
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            label: widget.provider == SocialProvider.google
                ? 'CONTINUA CON GOOGLE'
                : 'CONTINUA CON APPLE',
            isLoading: false,
            onPressed: _accepted ? () => Navigator.of(context).pop(true) : null,
          ),
        ],
      ),
    );
  }
}
