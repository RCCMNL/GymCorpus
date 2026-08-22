import 'package:flutter/material.dart';

/// Pillola con icona opzionale e testo, usata nell'header di
/// RoutineDetailHeader.
class HeaderTag extends StatelessWidget {
  const HeaderTag({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
    super.key,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}
