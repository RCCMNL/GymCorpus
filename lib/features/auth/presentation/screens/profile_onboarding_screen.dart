import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/profile_basics_form.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/profile_stats_form.dart';

/// Completamento del profilo al primo accesso.
///
/// Ci arriva chi ha un account ma non le informazioni di base: chi entra con
/// Google, chi ha interrotto la registrazione a meta' e chi si era iscritto
/// quando alcuni campi non venivano ancora chiesti. Il router non lascia
/// uscire di qui finche' il profilo non e' completo: l'unica alternativa e'
/// disconnettersi.
class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  State<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  /// Informazioni di base gia' compilate: finche' e' nullo si sta al primo
  /// passo. Il salvataggio avviene una volta sola, alla fine, cosi' non si
  /// resta con un profilo scritto a meta'.
  ProfileBasics? _basics;

  /// Messaggio di un'operazione fallita che non invalida la sessione.
  static String? _errorOf(AuthState state) => state.maybeWhen(
    authenticated: (_, actionError) => actionError,
    orElse: () => null,
  );

  void _save(ProfileStats stats) {
    final basics = _basics;
    if (basics == null) return;

    context.read<AuthBloc>().add(
      AuthEvent.updateProfileRequested(
        firstName: basics.firstName,
        lastName: basics.lastName,
        username: basics.username,
        birthDate: basics.birthDate,
        gender: basics.gender,
        weight: stats.weight,
        height: stats.height,
      ),
    );
  }

  void _showMessage(String message) {
    AppSnackBar.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AuthBloc>().state;
    final user = state.maybeWhen(
      authenticated: (user, _) => user,
      orElse: () => null,
    );
    final isLoading = state.maybeWhen(
      loading: (_) => true,
      orElse: () => false,
    );
    final basics = _basics;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          _errorOf(current) != null && _errorOf(previous) != _errorOf(current),
      listener: (context, state) => _showMessage(_errorOf(state)!),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              AmbientBackground(theme: theme),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.read<AuthBloc>().add(
                          const AuthEvent.logoutRequested(),
                        ),
                        child: const Text('Esci'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        basics == null ? 'Ci siamo quasi' : 'Ultimo passo',
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
                        basics == null
                            ? 'COMPLETA IL TUO PROFILO'
                            : 'PESO E ALTEZZA (FACOLTATIVI)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: basics == null
                          ? ProfileBasicsForm(
                              submitLabel: 'CONTINUA',
                              isLoading: isLoading,
                              initial: ProfileBasics(
                                firstName: user?.firstName ?? '',
                                lastName: user?.lastName ?? '',
                                username: user?.username ?? '',
                                birthDate: user?.birthDate,
                                gender: user?.gender,
                              ),
                              onValidationError: _showMessage,
                              onSubmit: (value) =>
                                  setState(() => _basics = value),
                            )
                          : ProfileStatsForm(
                              isLoading: isLoading,
                              initial: ProfileStats(
                                weight: user?.weight,
                                height: user?.height,
                              ),
                              onSubmit: _save,
                              onSkip: () => _save(const ProfileStats()),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
