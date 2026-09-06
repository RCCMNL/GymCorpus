import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_activity_style.dart';

/// Foglio di avvio di una sessione cardio: attivita' e obiettivo.
///
/// L'obiettivo si sceglie qui perche' durante la sessione le mani sono
/// occupate e il telefono spesso in tasca.
class CardioSelectorSheet extends StatefulWidget {
  const CardioSelectorSheet({
    required this.onStart,
    required this.onManualEntry,
    super.key,
  });

  final void Function(CardioLaunchArgs args) onStart;

  /// Registrazione di una sessione gia' fatta, senza cronometro.
  final VoidCallback onManualEntry;

  @override
  State<CardioSelectorSheet> createState() => _CardioSelectorSheetState();
}

class _CardioSelectorSheetState extends State<CardioSelectorSheet> {
  /// Obiettivi proposti: coprono i casi comuni senza chiedere di digitare
  /// un numero mentre ci si sta scaldando.
  static const _presets = <CardioGoal>[
    CardioGoal(type: CardioGoalType.distance, value: 3),
    CardioGoal(type: CardioGoalType.distance, value: 5),
    CardioGoal(type: CardioGoalType.distance, value: 10),
    CardioGoal(type: CardioGoalType.duration, value: 30),
    CardioGoal(type: CardioGoalType.duration, value: 45),
    CardioGoal(type: CardioGoalType.calories, value: 300),
    CardioGoal(type: CardioGoalType.calories, value: 500),
  ];

  CardioGoal? _goal;

  void _toggle(CardioGoal goal) {
    setState(() => _goal = _goal == goal ? null : goal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(text: 'OBIETTIVO (OPZIONALE)', theme: theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final preset in _presets)
                _GoalChip(
                  goal: preset,
                  selected: _goal == preset,
                  onTap: () => _toggle(preset),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel(text: "ALL'APERTO", theme: theme),
          const SizedBox(height: 12),
          _ActivityRow(
            activities: CardioActivity.outdoor,
            onTap: _start,
          ),
          const SizedBox(height: 20),
          _SectionLabel(text: 'AL CHIUSO', theme: theme),
          const SizedBox(height: 12),
          _ActivityRow(
            activities: CardioActivity.indoor,
            onTap: _start,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: widget.onManualEntry,
              icon: const Icon(Icons.edit_calendar_rounded, size: 18),
              label: const Text('Registra una sessione gia fatta'),
            ),
          ),
        ],
      ),
    );
  }

  void _start(CardioActivity activity) {
    widget.onStart(CardioLaunchArgs(activity: activity, goal: _goal));
  }
}

/// Riga di attivita' selezionabili.
class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activities, required this.onTap});

  final List<CardioActivity> activities;
  final void Function(CardioActivity activity) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (final activity in activities) ...[
          if (activity != activities.first) const SizedBox(width: 12),
          Expanded(
            child: CardioOptionTile(
              icon: activity.icon,
              label: activity.label,
              color: activity.accent(theme),
              onTap: () => onTap(activity),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        fontSize: 10,
        color: theme.colorScheme.outline,
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final CardioGoal goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          goal.label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Riquadro di scelta dell'attivita' cardio.
class CardioOptionTile extends StatelessWidget {
  const CardioOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
