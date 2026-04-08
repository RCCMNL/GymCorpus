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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _ChangePasswordSheet(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          theme: theme,
        ),
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
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                ).createShader(bounds),
                child: Text(
                  'Sicurezza',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    color: Colors.white,
                    fontSize: 28,
                  ),
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
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentUser?.authProviders.contains('google.com') == true
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentUser?.authProviders.contains('google.com') == true ? 'COLLEGATO' : 'NON COLLEGATO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: currentUser?.authProviders.contains('google.com') == true
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                            theme.colorScheme.tertiary.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'ATTIVO', 
                        style: TextStyle(
                          color: theme.colorScheme.primary, 
                          fontSize: 10, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        )
                      ),
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
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 2.5,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
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

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.theme,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final ThemeData theme;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  void _submit() async {
    if (widget.currentPasswordController.text.isEmpty || widget.newPasswordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    context.read<AuthBloc>().add(
          AuthEvent.changePasswordRequested(
            currentPassword: widget.currentPasswordController.text,
            newPassword: widget.newPasswordController.text,
          ),
        );
        
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password aggiornata con successo'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.theme.colorScheme.primary.withValues(alpha: 0.15),
                        widget.theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.theme.colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.lock_reset_rounded, color: widget.theme.colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cambia Password',
                      style: widget.theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    Text(
                      'Assicurati che sia complessa e sicura',
                      style: widget.theme.textTheme.bodySmall?.copyWith(color: widget.theme.colorScheme.outline),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildField(
              controller: widget.currentPasswordController,
              label: 'PASSWORD ATTUALE',
              icon: Icons.lock_open_rounded,
              obscure: _obscureCurrent,
              onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 24),
            _buildField(
              controller: widget.newPasswordController,
              label: 'NUOVA PASSWORD',
              icon: Icons.security_rounded,
              obscure: _obscureNew,
              onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.colorScheme.primary,
                  foregroundColor: widget.theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: widget.theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) 
                    : const Text(
                        'AGGIORNA PASSWORD',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: widget.theme.textTheme.labelSmall?.copyWith(
              color: widget.theme.colorScheme.outline,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.theme.colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            enabled: !_isLoading,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: widget.theme.colorScheme.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                onPressed: onToggleObscure,
                color: widget.theme.colorScheme.outline,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              hintText: '••••••••',
              hintStyle: TextStyle(color: widget.theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
