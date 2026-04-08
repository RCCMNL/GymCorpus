import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/core/widgets/social_icons.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadBiometricPreference();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
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

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      try {
        final didAuthenticate = await _auth.authenticate(
          localizedReason: "Autenticati per abilitare lo sblocco biometrico",
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
        if (didAuthenticate) {
          setState(() => _isBiometricEnabled = true);
          await _authRepository.setBiometricEnabled(enabled: true);
        }
      } catch (e) {
        // Revert toggle UI if error
      }
    } else {
      // Disabling also requires authentication for security
      try {
        final didAuthenticate = await _auth.authenticate(
          localizedReason: "Autenticati per disabilitare lo sblocco biometrico",
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
        if (didAuthenticate) {
          setState(() => _isBiometricEnabled = false);
          await _authRepository.setBiometricEnabled(enabled: false);
        } else {
          // Authentication failed, keep it enabled in UI
          _loadBiometricPreference(); 
        }
      } catch (e) {
        _loadBiometricPreference();
      }
    }
  }

  Future<bool> _verifyBiomanualIfEnabled(String reason) async {
    if (_isBiometricEnabled && _canCheckBiometrics) {
      try {
        return await _auth.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
      } catch (_) {
        return false; // Fallback to fail if auth crashes
      }
    }
    return true; // Auto-pass if not enabled
  }

  Future<void> _showChangePasswordDialog() async {
    final verified = await _verifyBiomanualIfEnabled("Autenticati per cambiare la password");
    if (!verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autenticazione richiesta per continuare')));
      return;
    }

    if (!mounted) return;
    
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ChangePasswordDialogBody(
        currentPasswordController: currentPasswordController,
        newPasswordController: newPasswordController,
        theme: theme,
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final verified = await _verifyBiomanualIfEnabled("Autenticati per eliminare il tuo account");
    if (!verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autenticazione richiesta per continuare')));
      return;
    }

    if (!mounted) return;

    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Elimina Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('Sei sicuro di voler eliminare definitivamente il tuo account e tutti i dati associati? Questa operazione non può essere annullata.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ANNULLA')),
          TextButton(
            onPressed: () {
              // Dispatch event and pop dialog
              context.read<AuthBloc>().add(const AuthEvent.deleteAccountRequested());
              Navigator.pop(dialogContext);
            },
            child: const Text('ELIMINA PERMANENTEMENTE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Read the current user from the BLoC directly for history and providers
    final currentUser = context.select((AuthBloc bloc) {
      return bloc.state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );
    });

    final loginDate = currentUser?.lastLoginDate;
    final loginDevice = currentUser?.lastLoginDevice ?? 'Dispositivo Corrente';
    final formattedDate = loginDate != null ? DateFormat('dd MMM yyyy, HH:mm', 'it_IT').format(loginDate) : 'Sconosciuto';

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sicurezza',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('AUTENTICAZIONE', theme),
              const SizedBox(height: 12),
              _SecurityItem(
                icon: Icons.lock_outline,
                label: 'Cambia Password',
                onTap: _showChangePasswordDialog,
              ),
              if (_canCheckBiometrics)
                _SecurityItem(
                  icon: Icons.fingerprint,
                  label: 'Sblocco Biometrico',
                  trailing: Switch(
                    value: _isBiometricEnabled,
                    onChanged: _toggleBiometrics,
                  ),
                ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('LOGIN SOCIAL', theme),
              const SizedBox(height: 12),
              _SecurityItem(
                leading: const GoogleLogo(size: 20),
                label: 'Google Account',
                trailing: Text('ATTIVO / NON COLLEGATO', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('CRONOLOGIA ACCESSI', theme),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.important_devices, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loginDevice, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Ultimo accesso: $formattedDate', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('ATTIVO', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              _buildSectionTitle('ZONA PERICOLOSA', theme),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showDeleteAccountDialog,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('ELIMINA ACCOUNT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 2,
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.outline,
      ),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  const _SecurityItem({
    this.icon,
    this.leading,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData? icon;
  final Widget? leading;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading ?? (icon != null ? Icon(icon, color: theme.colorScheme.primary) : null),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Managed Dialog to avoid state propagation issues during password change
class _ChangePasswordDialogBody extends StatefulWidget {
  const _ChangePasswordDialogBody({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.theme,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final ThemeData theme;

  @override
  State<_ChangePasswordDialogBody> createState() => _ChangePasswordDialogBodyState();
}

class _ChangePasswordDialogBodyState extends State<_ChangePasswordDialogBody> {
  bool _isLoading = false;

  void _submit() async {
    if (widget.currentPasswordController.text.isEmpty || widget.newPasswordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    // Dispatch to BLoC
    context.read<AuthBloc>().add(
          AuthEvent.changePasswordRequested(
            currentPassword: widget.currentPasswordController.text,
            newPassword: widget.newPasswordController.text,
          ),
        );
        
    // Wait for fake UI loading effect to let BLoC call finish under the hood
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.colorScheme.surface,
      title: Text('Cambia Password', style: TextStyle(fontFamily: 'Lexend', color: widget.theme.colorScheme.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.currentPasswordController,
            decoration: const InputDecoration(labelText: 'Password Attuale'),
            obscureText: true,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.newPasswordController,
            decoration: const InputDecoration(labelText: 'Nuova Password'),
            obscureText: true,
            enabled: !_isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context), 
          child: const Text('ANNULLA')
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text('AGGIORNA'),
        ),
      ],
    );
  }
}
