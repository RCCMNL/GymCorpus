import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/utils/decimal_input.dart';
import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_activity_style.dart';

/// Sfondo delle sessioni al chiuso, al posto della mappa.
///
/// Su tapis roulant, ellittica e vogatore non c'e' un percorso da mostrare:
/// quello che serve sotto gli occhi e' il tempo.
class IndoorSessionBackdrop extends StatelessWidget {
  const IndoorSessionBackdrop({
    required this.activity,
    required this.elapsedSeconds,
    required this.isTracking,
    super.key,
  });

  final CardioActivity activity;
  final int elapsedSeconds;
  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = activity.accent(theme);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.16), theme.colorScheme.surface],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(activity.icon, size: 56, color: accent),
            const SizedBox(height: 16),
            Text(
              activity.label.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                letterSpacing: 3,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              formatClock(elapsedSeconds),
              style: theme.textTheme.displayMedium?.copyWith(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTracking ? 'Sessione in corso' : 'Pronto quando lo sei tu',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chiede la distanza al termine di una sessione al chiuso.
///
/// Nessun sensore puo' misurarla: la si legge dal display dell'attrezzo,
/// oppure si tira dritto senza indicarla.
class IndoorDistanceDialog extends StatefulWidget {
  const IndoorDistanceDialog({super.key});

  @override
  State<IndoorDistanceDialog> createState() => _IndoorDistanceDialogState();
}

class _IndoorDistanceDialogState extends State<IndoorDistanceDialog> {
  final _controller = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = parseDecimalInput(_controller.text);
    if (value == null || value < 0 || value > 500) {
      setState(() => _invalid = true);
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xl),
      title: const Text(
        'Quanta distanza?',
        style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Leggila dal display dell'attrezzo, se c'e'.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
            ],
            decoration: InputDecoration(
              suffixText: 'km',
              errorText: _invalid ? 'Inserisci un numero di chilometri' : null,
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<double>(0),
          child: const Text('NON LA SO'),
        ),
        FilledButton(onPressed: _save, child: const Text('SALVA')),
      ],
    );
  }
}
