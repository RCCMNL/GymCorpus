import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/section_title.dart';
import 'package:gym_corpus/core/widgets/social_icons.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/change_password_sheet.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/login_history_tile.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/security_item.dart';
import 'package:local_auth/local_auth.dart';

/// Schermata Sicurezza: biometria, provider di accesso, cronologia e
/// eliminazione account.
///
/// Il foglio del cambio password, il dialogo di eliminazione e le righe
/// dell'elenco vivono in widget dedicati: qui restano la logica biometrica e
/// la composizione della pagina.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  bool _canCheckBiometrics = false;
  bool _isBiometricEnabled = false;

  /// Quanti accessi mostrare in cronologia.
  static const _visibleLogins = 2;

  @override
  void initState() {
    super.initState();
    unawaited(_checkBiometrics());
    unawaited(_loadBiometricPreference());
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('SecurityScreen._checkBiometrics error: $e');
      canCheckBiometrics = false;
    }
    if (!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _loadBiometricPreference() async {
    final isEnabled = await _authRepository.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = isEnabled;
      });
    }
  }

  /// Anche disattivare la biometria richiede di autenticarsi: altrimenti
  /// chiunque abbia il telefono sbloccato potrebbe toglierla.
  Future<void> _toggleBiometrics(bool value) async {
    final reason = value
        ? 'Autenticati per abilitare lo sblocco biometrico'
        : 'Autenticati per disabilitare lo sblocco biometrico';

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (!didAuthenticate) {
        // Autenticazione rifiutata: si torna al valore salvato, non a
        // quello che l'interruttore mostra adesso.
        unawaited(_loadBiometricPreference());
        return;
      }

      setState(() => _isBiometricEnabled = value);
      await _authRepository.setBiometricEnabled(enabled: value);
    } catch (e) {
      debugPrint('SecurityScreen._toggleBiometrics error: $e');
      unawaited(_loadBiometricPreference());
      _showFeedback(
        value
            ? "Non e stato possibile abilitare l'accesso biometrico"
            : "Non e stato possibile disabilitare l'accesso biometrico",
        isError: true,
      );
    }
  }

  Future<bool> _verifyBiometricsIfEnabled(String reason) async {
    if (!_isBiometricEnabled || !_canCheckBiometrics) return true;

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      debugPrint('SecurityScreen._verifyBiometricsIfEnabled error: $e');
      return false;
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      AppSnackBar.showError(context, message);
    } else {
      AppSnackBar.showSuccess(context, message);
    }
  }

  Future<void> _openChangePassword() async {
    final verified = await _verifyBiometricsIfEnabled(
      'Autenticati per cambiare la password',
    );
    if (!mounted) return;
    if (!verified) {
      _showFeedback('Autenticazione richiesta per continuare', isError: true);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: const ChangePasswordSheet(),
      ),
    );
  }

  Future<void> _openDeleteAccount(List<String> authProviders) async {
    final verified = await _verifyBiometricsIfEnabled(
      'Autenticati per eliminare il tuo account',
    );
    if (!mounted) return;
    if (!verified) {
      _showFeedback('Autenticazione richiesta per continuare', isError: true);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => DeleteAccountDialog(
        authProviders: authProviders,
        onDeleted: () {
          context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
          _showFeedback('Account eliminato con successo');
        },
        onError: (message) => _showFeedback(message, isError: true),
      ),
    );
  }

  /// Accessi da mostrare: la cronologia vera, o l'ultimo accesso noto per
  /// i profili creati prima che la cronologia esistesse.
  List<LoginEntry> _loginHistoryOf(UserEntity? user) {
    if (user == null) return const [];
    if (user.loginHistory.isNotEmpty) {
      return user.loginHistory.take(_visibleLogins).toList();
    }

    final lastLogin = user.lastLoginDate;
    if (lastLogin == null) return const [];

    return [
      LoginEntry(
        date: lastLogin,
        device: user.lastLoginDevice ?? 'Dispositivo Corrente',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentUser = context.select((AuthBloc bloc) {
      return bloc.state.maybeWhen(
        authenticated: (user, _) => user,
        orElse: () => null,
      );
    });

    final history = _loginHistoryOf(currentUser);
    final hasGoogle =
        currentUser?.authProviders.contains('google.com') ?? false;

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientTitle('Sicurezza'),
              const SizedBox(height: 32),
              _SectionLabel('AUTENTICAZIONE', theme: theme),
              const SizedBox(height: 12),
              SecurityItem(
                icon: Icons.lock_outline,
                label: 'Cambia Password',
                onTap: () => unawaited(_openChangePassword()),
              ),
              if (_canCheckBiometrics)
                SecurityItem(
                  icon: Icons.fingerprint,
                  label: 'Accesso Biometrico',
                  trailing: Switch(
                    value: _isBiometricEnabled,
                    onChanged: (value) => unawaited(_toggleBiometrics(value)),
                  ),
                ),
              const SizedBox(height: 32),
              _SectionLabel('LOGIN SOCIAL', theme: theme),
              const SizedBox(height: 12),
              SecurityItem(
                leading: const GoogleLogo(size: 20),
                label: 'Google Account',
                trailing: AuthProviderBadge(isLinked: hasGoogle),
              ),
              const SizedBox(height: 32),
              _SectionLabel('CRONOLOGIA ACCESSI', theme: theme),
              const SizedBox(height: 12),
              for (final (index, login) in history.indexed)
                LoginHistoryTile(login: login, isCurrent: index == 0),
              const SizedBox(height: 48),
              _SectionLabel('ZONA PERICOLOSA', theme: theme),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(
                    _openDeleteAccount(
                      currentUser?.authProviders ?? const <String>[],
                    ),
                  ),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text(
                    'ELIMINA ACCOUNT',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titolo di sezione, con lo stesso stile in tutta la schermata.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => SectionTitle(
    text,
    color: theme.colorScheme.primary.withValues(alpha: 0.8),
    letterSpacing: 2.5,
    fontSize: 11,
    withAccentBar: true,
  );
}
