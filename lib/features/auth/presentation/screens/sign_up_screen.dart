import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/social_icons.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';
import 'package:intl/intl.dart';

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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  DateTime? _birthDate;
  String _gender = 'Uomo';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedLegal = false;
  bool _marketingConsent = false;
  bool _profilingConsent = false;
  int _currentStep = 0;
  bool _isGoogleSignUpFlow = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
      backgroundColor:
          isError ? Theme.of(context).colorScheme.error : Colors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ));
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
      _isGoogleSignUpFlow = false;
    });
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic);
  }

  void _startGoogleSignUp() {
    setState(() {
      _currentStep = 1;
      _isGoogleSignUpFlow = true;
    });
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic);
  }

  void _goBackToStep1() {
    setState(() => _currentStep = 0);
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic);
  }

  void _onSignUpPressed() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty) {
      _showSnack('Compila tutti i campi obbligatori.');
      return;
    }
    if (_birthDate == null) {
      _showSnack('Seleziona la tua data di nascita.');
      return;
    }
    if (!_acceptedLegal) {
      _showSnack(
        'Accetta Termini e Privacy Policy per creare l account.',
        isError: true,
      );
      return;
    }

    context.read<AuthBloc>().add(AuthEvent.signUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: firstName,
          lastName: lastName,
          username: username,
          birthDate: _birthDate!,
          gender: _gender,
          acceptedTerms: _acceptedLegal,
          acceptedPrivacy: _acceptedLegal,
          marketingConsent: _marketingConsent,
          profilingConsent: _profilingConsent,
        ));
  }

  void _onGoogleSignUpPressed() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty) {
      _showSnack('Compila tutti i campi obbligatori.');
      return;
    }
    if (_birthDate == null) {
      _showSnack('Seleziona la tua data di nascita.');
      return;
    }
    if (!_acceptedLegal) {
      _showSnack(
        'Accetta Termini e Privacy Policy per creare l account.',
        isError: true,
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthEvent.googleSignInRequested(
            acceptedTerms: _acceptedLegal,
            acceptedPrivacy: _acceptedLegal,
            marketingConsent: _marketingConsent,
            profilingConsent: _profilingConsent,
          ),
        );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 20);
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        var tempDate = initialDate;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Data di nascita',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 320,
                      child: CalendarDatePicker(
                        initialDate: tempDate,
                        firstDate: DateTime(1900),
                        lastDate: now,
                        onDateChanged: (value) {
                          setModalState(() => tempDate = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(tempDate),
                            child: const Text('Conferma'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.mapOrNull(
            authenticated: (_) {
              if (_isGoogleSignUpFlow) {
                setState(() => _isGoogleSignUpFlow = false);
                context.read<AuthBloc>().add(
                      AuthEvent.updateProfileRequested(
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        username: _usernameController.text.trim(),
                        birthDate: _birthDate,
                        gender: _gender,
                      ),
                    );
              }
              context.go('/training');
            },
            error: (e) => _showSnack(e.message, isError: true),
          );
        },
        builder: (context, state) {
          final isLoading =
              state.maybeWhen(loading: (_) => true, orElse: () => false);
          return Stack(children: [
            AmbientBackground(theme: theme),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(children: [
                    _buildTopBar(theme),
                    _buildStepIndicator(theme),
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
                  ]),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              if (_currentStep == 1)
                _goBackToStep1();
              else
                context.pop();
            },
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.18),
                theme.colorScheme.tertiary.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Text('Passo ${_currentStep + 1} di 2',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface, letterSpacing: 1)),
        ),
      ]),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(children: [
        _stepDot(theme, 0),
        Expanded(child: _stepLine(theme, 0)),
        _stepDot(theme, 1),
      ]),
    );
  }

  Widget _stepDot(ThemeData theme, int step) {
    final isActive = _currentStep >= step;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 12 : 10,
      height: isActive ? 12 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 8)
              ]
            : null,
      ),
    );
  }

  Widget _stepLine(ThemeData theme, int step) {
    final isActive = _currentStep > step;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ]
              : [
                  theme.colorScheme.outline.withValues(alpha: 0.22),
                  theme.colorScheme.outline.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(999),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crea il tuo account',
                      style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          fontSize: 28)),
                  const SizedBox(height: 4),
                  Text('INIZIA IL TUO PERCORSO',
                      style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.7))),
                ],
              ),
              const SizedBox(width: 16),
              Hero(
                tag: 'app_logo',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ).createShader(bounds),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 48,
                        height: 48,
                        color: Colors.white,
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                    action: TextInputAction.next),
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
                          color: theme.colorScheme.outline),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword)),
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
                          color: theme.colorScheme.outline),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm)),
                ),
                const SizedBox(height: 22),
                AuthPrimaryButton(
                    label: 'CONTINUA', isLoading: false, onPressed: _goToStep2),
                const SizedBox(height: 22),
                authDivider(theme, 'OPPURE REGISTRATI CON'),
                const SizedBox(height: 20),
                AuthSocialButton(
                    logo: const GoogleLogo(size: 20),
                    label: 'Registrati con Google',
                    onTap: _startGoogleSignUp),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: RichText(
                  text: TextSpan(
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      children: [
                    const TextSpan(text: 'Hai già un account? '),
                    TextSpan(
                        text: 'Accedi',
                        style: TextStyle(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.bold))
                  ])),
            ),
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
                      gradient: LinearGradient(colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.22),
                        theme.colorScheme.tertiary.withValues(alpha: 0.16),
                      ]),
                      shape: BoxShape.circle),
                  child: Icon(Icons.person_outline_rounded,
                      size: 40, color: theme.colorScheme.primary))),
          const SizedBox(height: 16),
          Center(
              child: Text('Parlaci di te',
                  style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 28))),
          const SizedBox(height: 6),
          Center(
              child: Text('COMPLETA IL TUO PROFILO',
                  style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.7)))),
          const SizedBox(height: 28),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        authLabel(theme, 'Nome'),
                        const SizedBox(height: 8),
                        AuthTextField(
                            controller: _firstNameController,
                            hint: 'nome',
                            autofill: const [AutofillHints.givenName],
                            action: TextInputAction.next)
                      ])),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        authLabel(theme, 'Cognome'),
                        const SizedBox(height: 8),
                        AuthTextField(
                            controller: _lastNameController,
                            hint: 'cognome',
                            autofill: const [AutofillHints.familyName],
                            action: TextInputAction.next)
                      ])),
                ]),
                const SizedBox(height: 16),
                authLabel(theme, 'Username'),
                const SizedBox(height: 8),
                AuthTextField(
                    controller: _usernameController,
                    hint: 'username',
                    icon: Icons.alternate_email_rounded,
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 30, minHeight: 18),
                    autofill: const [AutofillHints.username],
                    action: TextInputAction.done),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _buildDatePicker(theme)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderSelector(theme))
                ]),
                const SizedBox(height: 18),
                _buildLegalConsents(theme),
                const SizedBox(height: 22),
                AuthPrimaryButton(
                    label: _isGoogleSignUpFlow
                        ? 'CONTINUA CON GOOGLE'
                        : 'CREA ACCOUNT',
                    isLoading: isLoading,
                    onPressed: _isGoogleSignUpFlow
                        ? _onGoogleSignUpPressed
                        : _onSignUpPressed),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        authLabel(theme, 'Data di nascita'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      _birthDate == null
                          ? 'Seleziona'
                          : DateFormat('dd/MM/yyyy').format(_birthDate!),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: _birthDate == null
                              ? theme.colorScheme.outline
                              : theme.colorScheme.onSurface))),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        authLabel(theme, 'Genere'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              borderRadius: BorderRadius.circular(14),
              dropdownColor: theme.colorScheme.surfaceContainerHigh,
              items: const [
                DropdownMenuItem(value: 'Uomo', child: Text('Uomo')),
                DropdownMenuItem(value: 'Donna', child: Text('Donna')),
                DropdownMenuItem(value: 'Altro', child: Text('Altro'))
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalConsents(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        authLabel(theme, 'Consensi e privacy'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color:
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _acceptedLegal
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _acceptedLegal,
                onChanged: (checked) =>
                    setState(() => _acceptedLegal = checked ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    'Accetto Termini',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/legal/consent'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(right: 12),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Leggi i termini'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
