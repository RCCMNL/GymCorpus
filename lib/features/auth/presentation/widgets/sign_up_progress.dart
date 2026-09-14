import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';

/// La barra in cima alla registrazione: indietro e a che punto siamo.
class SignUpTopBar extends StatelessWidget {
  const SignUpTopBar({
    required this.currentStep,
    required this.onBack,
    super.key,
  });

  /// Zero o uno: la registrazione ha due passi.
  final int currentStep;

  /// Torna al passo precedente, o esce se siamo al primo.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.tintedFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.primary.tintedBorder),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.primary,
              ),
              onPressed: onBack,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.18),
                  theme.colorScheme.tertiary.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Text(
              'Passo ${currentStep + 1} di 2',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// I due pallini uniti dalla linea che si accende passando al secondo passo.
class SignUpStepIndicator extends StatelessWidget {
  const SignUpStepIndicator({required this.currentStep, super.key});

  static const _animation = Duration(milliseconds: 300);

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        children: [
          _dot(context, 0),
          Expanded(child: _line(context, 0)),
          _dot(context, 1),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, int step) {
    final theme = Theme.of(context);
    final isActive = currentStep >= step;

    return AnimatedContainer(
      duration: _animation,
      width: isActive ? 12 : 10,
      height: isActive ? 12 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _line(BuildContext context, int step) {
    final theme = Theme.of(context);
    final isActive = currentStep > step;

    return AnimatedContainer(
      duration: _animation,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [theme.colorScheme.primary, theme.colorScheme.tertiary]
              : [
                  theme.colorScheme.outline.withValues(alpha: 0.22),
                  theme.colorScheme.outline.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
