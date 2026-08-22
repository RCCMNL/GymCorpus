import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_session_widgets.dart';

/// Overlay a tutto schermo mostrato quando la sessione di allenamento e'
/// in pausa.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.accentColor,
    required this.onResume,
    super.key,
  });

  final Color accentColor;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Icon(Icons.pause_rounded, size: 64, color: accentColor),
            ),
            const SizedBox(height: 24),
            Text(
              'IN PAUSA',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ActionPill(
              icon: Icons.play_arrow_rounded,
              label: 'RIPRENDI',
              onTap: onResume,
              filled: true,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}
