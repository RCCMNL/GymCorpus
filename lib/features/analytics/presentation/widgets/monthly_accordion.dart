import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// Sezione comprimibile con titolo, contatore e contenuto, usata per
/// raggruppare log peso e misure per mese.
class MonthlyAccordion extends StatefulWidget {
  const MonthlyAccordion({
    required this.title,
    required this.count,
    required this.child,
    super.key,
    this.initiallyExpanded = false,
  });

  final String title;
  final int count;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<MonthlyAccordion> createState() => _MonthlyAccordionState();
}

class _MonthlyAccordionState extends State<MonthlyAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _expanded
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: AppRadius.pill,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                    color: _expanded
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: AppRadius.xs,
                  ),
                  child: Text(
                    widget.count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) widget.child,
      ],
    );
  }
}
