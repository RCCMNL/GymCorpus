import 'package:flutter/material.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:intl/intl.dart';

/// Una riga della cronologia accessi.
class LoginHistoryTile extends StatelessWidget {
  const LoginHistoryTile({
    required this.login,
    required this.isCurrent,
    super.key,
  });

  final LoginEntry login;

  /// L'accesso in corso: e' il primo dell'elenco e porta il badge.
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('dd MMM yyyy, HH:mm', 'it_IT').format(login.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                Text(
                  login.device,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isCurrent
                      ? 'Ultimo accesso: $date'
                      : 'Accesso precedente: $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
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
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'ATTIVO',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
