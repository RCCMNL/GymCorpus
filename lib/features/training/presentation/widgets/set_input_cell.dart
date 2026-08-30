import 'package:flutter/material.dart';

/// Campo numerico compatto (peso o ripetizioni) con etichetta di unita' a
/// destra, usato dentro SelectedExerciseTile.
class SetInputCell extends StatelessWidget {
  const SetInputCell({
    required this.controller,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                // Il riempimento lo disegna il Container che avvolge il campo.
                filled: false,
                border: InputBorder.none,
                isDense: true,
                hintText: '-',
                hintStyle: TextStyle(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              fontWeight: FontWeight.w900,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
