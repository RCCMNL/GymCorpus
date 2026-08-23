import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_session_widgets.dart';

/// Overlay a tutto schermo mostrato durante il recupero tra le serie:
/// countdown ad anello, azioni rapide e possibilita' di terminare la
/// sessione.
class RestTimerOverlay extends StatelessWidget {
  const RestTimerOverlay({
    required this.pulseController,
    required this.progress,
    required this.secondsRemaining,
    required this.accentColor,
    required this.onRestart,
    required this.onSkip,
    required this.onConfirmEnd,
    super.key,
  });

  final AnimationController? pulseController;
  final double progress;
  final int secondsRemaining;
  final Color accentColor;
  final VoidCallback onRestart;
  final VoidCallback onSkip;
  final VoidCallback onConfirmEnd;

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sc = (s % 60).toString().padLeft(2, '0');
    return '$m:$sc';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: AnimatedBuilder(
          animation: pulseController ?? kAlwaysCompleteAnimation,
          builder: (context, child) {
            final scale = 1.0 + ((pulseController?.value ?? 0.0) * 0.02);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CustomPaint(
                          painter: TimerRingPainter(
                            progress: progress,
                            color: accentColor,
                            trackColor: theme
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'RECUPERO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 2,
                              color: theme.colorScheme.outline,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _fmt(secondsRemaining),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lexend',
                              fontSize: 56,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionPill(
                      icon: Icons.refresh_rounded,
                      label: 'Riavvia',
                      onTap: onRestart,
                      filled: false,
                      theme: theme,
                    ),
                    ActionPill(
                      icon: Icons.skip_next_rounded,
                      label: 'Salta',
                      onTap: onSkip,
                      filled: true,
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: onConfirmEnd,
                  icon: const Icon(
                    Icons.stop_circle_outlined,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'TERMINA ALLENAMENTO',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
