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
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _marketingConsent = false;
  bool _profilingConsent = false;
  int _currentStep = 0;

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

    setState(() => _currentStep = 1);
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
    if (!_acceptedTerms || !_acceptedPrivacy) {
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
          acceptedTerms: _acceptedTerms,
          acceptedPrivacy: _acceptedPrivacy,
          marketingConsent: _marketingConsent,
          profilingConsent: _profilingConsent,
        ));
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('it', 'IT'),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(children: [
        IconButton(
          icon:
              Icon(Icons.arrow_back_rounded, color: theme.colorScheme.primary),
          onPressed: () {
            if (_currentStep == 1)
              _goBackToStep1();
            else
              context.pop();
          },
        ),
        const Spacer(),
        Text('Passo ${_currentStep + 1} di 2',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.outline, letterSpacing: 1)),
        const SizedBox(width: 16),
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
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 28),
                AuthPrimaryButton(
                    label: 'CONTINUA', isLoading: false, onPressed: _goToStep2),
                const SizedBox(height: 28),
                authDivider(theme, 'OPPURE REGISTRATI CON'),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                      child: AuthSocialButton(
                          logo: const GoogleLogo(size: 20),
                          label: 'Google',
                          onTap: () => _showSnack(
                                'Per ora crea l account con email e password per accettare i consensi obbligatori.',
                              ))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Opacity(
                          opacity: 0.5,
                          child: AuthSocialButton(
                              logo: const AppleLogo(size: 22),
                              label: 'Apple',
                              onTap: () =>
                                  _showSnack('Apple Sign-In in arrivo!')))),
                ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                            hint: 'Mario',
                            icon: Icons.badge_outlined,
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
                            hint: 'Rossi',
                            icon: Icons.badge_outlined,
                            autofill: const [AutofillHints.familyName],
                            action: TextInputAction.next)
                      ])),
                ]),
                const SizedBox(height: 20),
                authLabel(theme, 'Username'),
                const SizedBox(height: 8),
                AuthTextField(
                    controller: _usernameController,
                    hint: 'mario_rossi',
                    icon: Icons.alternate_email_rounded,
                    autofill: const [AutofillHints.username],
                    action: TextInputAction.done),
                const SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _buildDatePicker(theme)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderSelector(theme))
                ]),
                const SizedBox(height: 24),
                _buildLegalConsents(theme),
                const SizedBox(height: 28),
                AuthPrimaryButton(
                    label: 'CREA ACCOUNT',
                    isLoading: isLoading,
                    onPressed: _onSignUpPressed),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
        _buildConsentTile(
          theme,
          value: _acceptedTerms,
          onChanged: (value) => setState(() => _acceptedTerms = value),
          title: "Accetto i Termini e Condizioni d'Uso",
          description:
              'Obbligatorio: definisce regole, responsabilita e uso corretto di GymCorpus.',
          linkLabel: 'Leggi i Termini',
          route: '/legal/terms',
        ),
        const SizedBox(height: 10),
        _buildConsentTile(
          theme,
          value: _acceptedPrivacy,
          onChanged: (value) => setState(() => _acceptedPrivacy = value),
          title: 'Ho letto la Privacy Policy',
          description:
              'Obbligatorio: spiega come gestiamo profilo, allenamenti, record e dati tecnici.',
          linkLabel: 'Leggi la Privacy Policy',
          route: '/legal/privacy',
        ),
        const SizedBox(height: 10),
        _buildCookieNotice(theme),
        const SizedBox(height: 10),
        _buildConsentTile(
          theme,
          value: _marketingConsent,
          onChanged: (value) => setState(() => _marketingConsent = value),
          title: 'Consenso marketing e newsletter',
          description:
              'Facoltativo e non preselezionato: comunicazioni su novita, consigli e offerte.',
        ),
        const SizedBox(height: 10),
        _buildConsentTile(
          theme,
          value: _profilingConsent,
          onChanged: (value) => setState(() => _profilingConsent = value),
          title: 'Consenso alla profilazione commerciale',
          description:
              'Facoltativo e non preselezionato: personalizzazione di comunicazioni o promozioni.',
        ),
      ],
    );
  }

  Widget _buildConsentTile(
    ThemeData theme, {
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    required String description,
    String? linkLabel,
    String? route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? theme.colorScheme.primary.withValues(alpha: 0.35)
              : theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  if (linkLabel != null && route != null) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => context.push(route),
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

  Widget _buildCookieNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cookie_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cookie e tecnologie simili',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'GymCorpus e una app mobile: usiamo solo tecnologie tecniche necessarie per login, sicurezza e salvataggio locale. Nessun cookie di marketing e attivo qui.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push('/legal/cookies'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Leggi la Cookie Policy'),
            ),
          ),
        ],
      ),
    );
  }
}
