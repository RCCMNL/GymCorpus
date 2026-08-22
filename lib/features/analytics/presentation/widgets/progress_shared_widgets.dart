import 'package:flutter/material.dart';

/// Selettore a due tab (Peso / Misure) usato in cima a ProgressScreen.
class ProgressTabBar extends StatelessWidget {
  const ProgressTabBar({required this.controller, super.key});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.outline,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontFamily: 'Lexend',
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Lexend',
          fontSize: 13,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Peso'),
          Tab(text: 'Misure'),
        ],
      ),
    );
  }
}

/// Intestazione di sezione con titolo, sottotitolo e un'azione a destra.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.subtitle,
    required this.action,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        action,
      ],
    );
  }
}

/// Riga per un singolo log storico (peso o misura), con azione di cancellazione.
class LogTile extends StatelessWidget {
  const LogTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onDelete,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stato di errore a schermo intero per ProgressScreen, con azione di retry.
class ProgressErrorState extends StatelessWidget {
  const ProgressErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh.withValues(
              alpha: 0.4,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.error,
                size: 44,
              ),
              const SizedBox(height: 14),
              Text(
                'Non riesco a caricare i progressi',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Ricarica dati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card generica per liste vuote (nessun log, nessuna misura, ecc.).
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga con icona di spunta per un singolo suggerimento, usata nelle card
/// di "buone pratiche".
class TipLine extends StatelessWidget {
  const TipLine({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
