import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';

/// Conferma di eliminazione account.
///
/// Chi si e' registrato con email deve ridigitare la password: e' l'unica
/// barriera tra un tocco e la perdita dell'account. Con un provider esterno
/// la conferma la chiede il provider stesso.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({
    required this.authProviders,
    required this.onDeleted,
    required this.onError,
    super.key,
  });

  final List<String> authProviders;
  final VoidCallback onDeleted;
  final void Function(String message) onError;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _password = TextEditingController();

  bool _isDeleting = false;
  String? _validationMessage;

  bool get _requiresPassword => widget.authProviders.contains('password');

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final currentPassword = _password.text.trim();
    if (_requiresPassword && currentPassword.isEmpty) {
      setState(() {
        _validationMessage = 'Inserisci la password attuale per continuare.';
      });
      return;
    }

    setState(() {
      _isDeleting = true;
      _validationMessage = null;
    });

    final result = await GetIt.I<AuthRepository>().deleteAccount(
      currentPassword: _requiresPassword ? currentPassword : null,
    );

    if (!mounted) return;
    Navigator.pop(context);

    result.fold(
      (failure) => widget.onError(failure.message),
      (_) => widget.onDeleted(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validationMessage = _validationMessage;

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: const Text(
        'Elimina Account',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      // Scorrevole: fra avviso, campo password e spiegazioni il dialogo
      // supera l'altezza disponibile su uno schermo basso.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sei sicuro di voler eliminare definitivamente il tuo account e '
              'tutti i dati associati? Questa operazione non puo essere '
              'annullata.',
            ),
            const SizedBox(height: 16),
            if (_requiresPassword) ...[
              TextField(
                controller: _password,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Password attuale',
                  border: OutlineInputBorder(),
                ),
              ),
              if (validationMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  validationMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ] else
              Text(
                'Ti verra richiesta una nuova conferma con il provider usato '
                'per il login.',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('ANNULLA'),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _delete,
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'ELIMINA PERMANENTEMENTE',
                  style: TextStyle(color: Colors.red),
                ),
        ),
      ],
    );
  }
}
