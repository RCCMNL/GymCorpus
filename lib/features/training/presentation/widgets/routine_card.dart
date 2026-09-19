import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// Il guscio di una scheda routine: sfumatura, bordo di accento, tocco.
///
/// Le due schede di CustomWorkoutsScreen - la routine dell'utente e quella
/// consigliata - se lo ripetevano identico per trentacinque righe l'una:
/// stessa sfumatura, stesso raggio, stessa ombra. Cambiava solo il
/// contenuto, che ora e' l'unica cosa che passa da fuori.
class RoutineCardShell extends StatelessWidget {
  const RoutineCardShell({
    required this.accent,
    required this.onTap,
    required this.child,
    super.key,
  });

  /// Colore che tinge il bordo: distingue una routine dall'altra.
  final Color accent;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
            theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        border: Border.all(color: accent.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}

/// L'etichetta piccola di una scheda routine: "5 ESERCIZI", "45 MIN",
/// "CONSIGLIATA".
class RoutineTagChip extends StatelessWidget {
  const RoutineTagChip({
    required this.label,
    required this.color,
    this.icon,
    this.background,
    super.key,
  });

  final String label;

  /// Colore del testo e dell'icona.
  final Color color;
  final IconData? icon;

  /// Sfondo alternativo; senza, e' una velatura di [color].
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = this.icon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.1),
        borderRadius: AppRadius.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                fontSize: 9,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il titolo di una scheda routine.
class RoutineCardTitle extends StatelessWidget {
  const RoutineCardTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        fontFamily: 'Lexend',
        fontSize: 18,
        color: theme.colorScheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
