import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';

/// Riga della schermata Sicurezza: icona o logo, etichetta, e a scelta un
/// comando in coda o la freccia di navigazione.
class SecurityItem extends StatelessWidget {
  const SecurityItem({
    required this.label,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData? icon;
  final Widget? leading;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      size: AppCardSize.tight,
      tone: AppCardTone.sunken,
      child: ListTile(
        onTap: onTap,
        leading:
            leading ??
            (icon != null
                ? Icon(icon, color: theme.colorScheme.primary)
                : null),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        // La freccia solo dove si va davvero da qualche parte: su una riga
        // senza azione prometterebbe una navigazione che non esiste.
        trailing:
            trailing ??
            (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
    );
  }
}

/// Stato di collegamento di un provider di accesso esterno.
class AuthProviderBadge extends StatelessWidget {
  const AuthProviderBadge({required this.isLinked, super.key});

  final bool isLinked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isLinked
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.xs,
      ),
      child: Text(
        isLinked ? 'COLLEGATO' : 'NON COLLEGATO',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}
