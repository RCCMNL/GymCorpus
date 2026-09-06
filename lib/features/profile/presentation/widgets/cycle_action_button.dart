import 'package:flutter/material.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_info.dart';

/// Unica azione della schermata: apre o chiude la mestruazione in corso.
///
/// Un solo pulsante con due stati, invece di due pulsanti sempre presenti:
/// solo una delle due azioni ha senso in un dato momento.
class CycleActionButton extends StatelessWidget {
  const CycleActionButton({
    required this.hasOpenLog,
    required this.onStart,
    required this.onEnd,
    super.key,
  });

  final bool hasOpenLog;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: hasOpenLog ? onEnd : onStart,
      style: ElevatedButton.styleFrom(
        backgroundColor: hasOpenLog
            ? theme.colorScheme.surfaceContainerHigh
            : CyclePalette.period,
        foregroundColor: hasOpenLog
            ? theme.colorScheme.onSurface
            : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        hasOpenLog ? 'SEGNA FINE CICLO' : 'SEGNA INIZIO CICLO',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
