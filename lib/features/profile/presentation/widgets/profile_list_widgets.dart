import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_info.dart';

/// Sezione della lista profilo/impostazioni: titolo con accento colorato e
/// una card contenente le sue [ProfileItem].
class ProfileSection extends StatelessWidget {
  const ProfileSection({required this.title, required this.items, super.key});

  final String title;
  final List<ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: AppRadius.pill,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: SectionTitle(
                    title.toUpperCase(),
                    tone: SectionTitleTone.muted,
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemBuilder: (context, index) => items[index],
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga di menu con icona, etichetta e un trailing opzionale (badge, testo,
/// switch o freccia di navigazione).
class ProfileItem extends StatelessWidget {
  const ProfileItem({
    required this.icon,
    required this.label,
    this.trailingText,
    this.trailing,
    this.isBadge = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final Widget? trailing;
  final bool isBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComingSoon = isBadge && trailingText == 'Prossimamente';
    final iconColor = isComingSoon
        ? theme.colorScheme.outline
        : label == 'Calendario ciclo'
        ? CyclePalette.period
        : (label == 'Sicurezza' || label == 'Esercizi Preferiti'
              ? theme.colorScheme.tertiary
              : (label == 'Valuta GymCorpus'
                    ? Colors.orangeAccent
                    : theme.colorScheme.primary));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lg,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: label == 'Calendario ciclo'
                ? CyclePalette.period.withValues(alpha: 0.05)
                : null,
            borderRadius: AppRadius.lg,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isComingSoon ? theme.colorScheme.outline : null,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                if (isBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isComingSoon
                          ? theme.colorScheme.outline.withValues(alpha: 0.12)
                          : theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.lg,
                    ),
                    child: Text(
                      trailingText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isComingSoon
                            ? theme.colorScheme.outline
                            : theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else
                  Text(
                    trailingText!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
              if (trailing != null) trailing!,
              if (trailingText == null && trailing == null && !isBadge)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
