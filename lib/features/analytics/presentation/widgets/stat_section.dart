import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

/// Riquadro con un titolo di sezione e una riga di [StatItem].
class StatSection extends StatelessWidget {
  const StatSection({
    required this.title,
    required this.color,
    required this.stats,
    super.key,
  });

  final String title;
  final Color color;
  final List<StatItem> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title.toUpperCase(), tone: SectionTitleTone.muted),
          const SizedBox(height: 10),
          // Le statistiche si dividono la larghezza in parti uguali: a
          // spaziatura libera la piu' lunga spingeva le altre fuori.
          Row(children: [for (final stat in stats) Expanded(child: stat)]),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
