import 'package:flutter/material.dart';

/// La domanda che l'app fa prima di un'azione che non si torna indietro.
///
/// Le cinque schermate che eliminavano qualcosa avevano ognuna il proprio
/// AlertDialog: chi col bordo a 24 e chi senza, chi con "ELIMINA" rosso
/// acceso e chi col rosso della palette, chi restituiva un bool e chi
/// eseguiva l'azione da dentro il dialogo. Ora la domanda e' una sola e
/// risponde sempre nello stesso modo.
class ConfirmDialog {
  const ConfirmDialog._();

  /// Chiede conferma e ritorna `true` solo se l'utente ha confermato.
  ///
  /// Chiudere il dialogo senza scegliere vale come un no.
  static Future<bool> ask(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'ELIMINA',
    String cancelLabel = 'ANNULLA',
    bool destructive = true,
  }) async {
    final theme = Theme.of(context);
    final confirmColor = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontFamily: 'Lexend',
          ),
        ),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              cancelLabel,
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: confirmColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return answer ?? false;
  }
}
