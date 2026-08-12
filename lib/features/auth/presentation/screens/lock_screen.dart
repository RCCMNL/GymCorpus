import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/services/app_lock_controller.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:local_auth/local_auth.dart';

/// Schermata di sblocco mostrata all'avvio e al ritorno in primo piano quando
/// l'utente ha attivato lo sblocco biometrico.
class LockScreen extends StatefulWidget {
  const LockScreen({required this.controller, super.key});

  final AppLockController controller;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _inProgress = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_authenticate());
  }

  Future<void> _authenticate() async {
    if (_inProgress) return;

    setState(() {
      _inProgress = true;
      _error = null;
    });
    widget.controller.isAuthenticating = true;

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Sblocca GymCorpus per accedere ai tuoi dati',
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (didAuthenticate) {
        widget.controller
          ..isAuthenticating = false
          ..unlock();
        return;
      }

      if (mounted) {
        setState(() => _error = 'Riconoscimento non riuscito.');
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() => _error = _messageFor(e));
      }
    } finally {
      widget.controller.isAuthenticating = false;
      if (mounted) {
        setState(() => _inProgress = false);
      }
    }
  }

  /// Traduce i codici di `local_auth` in messaggi utili all'utente: senza
  /// questo un lockout del sensore risulterebbe indistinguibile da un
  /// semplice tentativo fallito.
  String _messageFor(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
      case 'NotEnrolled':
        return 'Biometria non disponibile su questo dispositivo. '
            'Esci e accedi con la password.';
      case 'LockedOut':
        return 'Troppi tentativi falliti. Riprova tra qualche istante.';
      case 'PermanentlyLockedOut':
        return 'Riconoscimento bloccato. Sblocca il dispositivo con il '
            'codice, poi riprova.';
      case 'PasscodeNotSet':
        return 'Imposta un codice di blocco sul dispositivo per usare lo '
            'sblocco biometrico.';
      default:
        return 'Non e stato possibile completare lo sblocco.';
    }
  }

  Future<void> _logout() async {
    // Uscire e' l'unica via se la biometria non e piu' disponibile, per
    // esempio dopo la rimozione delle impronte registrate.
    widget.controller.unlock();
    context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'GymCorpus e bloccato',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Autenticati per accedere ai tuoi allenamenti e ai tuoi '
                  'dati di salute.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _inProgress ? null : _authenticate,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(_inProgress ? 'Attendi...' : 'Sblocca'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _inProgress ? null : _logout,
                  child: const Text('Esci dall account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
