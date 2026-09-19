import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';

/// Casella di accettazione di Termini e Privacy Policy.
///
/// Serve in due punti: nel form di registrazione con email e prima di
/// autenticarsi con un provider esterno, perche' l'account non deve essere
/// creato se i termini non sono stati accettati.
class LegalConsentField extends StatelessWidget {
  const LegalConsentField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        authLabel(theme, 'Consensi e privacy'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.7,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
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
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    // Il consenso copre entrambi i documenti, come dice il
                    // messaggio di errore mostrato se non viene spuntato:
                    // l'etichetta deve nominarli tutti e due.
                    'Accetto Termini e Privacy Policy',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // Cede insieme all'etichetta quando la riga si stringe:
              // casella, testo e link insieme non ci stavano.
              Flexible(
                child: TextButton(
                  onPressed: () => context.push('/legal/consent'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(right: 12),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Leggi i termini',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
