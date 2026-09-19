import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/utils/decimal_input.dart';
import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_activity_style.dart';

/// Registrazione di una sessione cardio gia' fatta.
///
/// Serve a chi si dimentica di avviare il cronometro o si allena con un
/// altro dispositivo: senza, quell'allenamento non esisterebbe per l'app,
/// e mancherebbe anche da record e statistiche.
class ManualCardioEntryScreen extends StatefulWidget {
  const ManualCardioEntryScreen({super.key});

  @override
  State<ManualCardioEntryScreen> createState() =>
      _ManualCardioEntryScreenState();
}

class _ManualCardioEntryScreenState extends State<ManualCardioEntryScreen> {
  final _duration = TextEditingController();
  final _distance = TextEditingController();

  CardioActivity _activity = CardioActivity.run;
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _duration.dispose();
    _distance.dispose();
    super.dispose();
  }

  static double? _parse(String raw) => parseDecimalInput(raw);

  double get _userWeight {
    final state = context.read<TrainingBloc>().state;
    if (state is TrainingLoaded && state.bodyWeightLogs.isNotEmpty) {
      return state.bodyWeightLogs.first.weight;
    }

    return context.read<AuthBloc>().state.maybeWhen(
      authenticated: (user, _) => user.weight ?? 70.0,
      orElse: () => 70.0,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      // Una sessione non puo' essere stata fatta domani.
      lastDate: now,
      locale: const Locale('it', 'IT'),
    );

    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _save() {
    // L'errore racconta questo tentativo, non quello di prima: senza
    // ripulirlo restava a schermo anche dopo aver corretto il campo.
    setState(() => _error = null);

    final minutes = _parse(_duration.text);
    if (minutes == null || minutes <= 0 || minutes > 1440) {
      setState(() => _error = 'Indica la durata in minuti.');
      return;
    }

    final distance = _activity.tracksDistance
        ? (_parse(_distance.text) ?? 0)
        : 0.0;
    if (distance < 0 || distance > 500) {
      setState(() => _error = 'Controlla la distanza: sembra fuori scala.');
      return;
    }

    final seconds = (minutes * 60).round();
    final speed = CardioActivity.averageSpeed(
      distanceKm: distance,
      seconds: seconds,
    );

    context.read<TrainingBloc>().add(
      SaveCardioSessionEvent(
        type: _activity.id,
        distance: double.parse(distance.toStringAsFixed(2)),
        duration: seconds,
        avgSpeed: double.parse(speed.toStringAsFixed(1)),
        pace: formatPace(seconds: seconds, distanceKm: distance),
        calories: _activity
            .caloriesFor(
              speedKmh: speed,
              weightKg: _userWeight,
              seconds: seconds,
            )
            .round(),
        // Nessun percorso: la sessione non e' stata seguita dal GPS, e
        // inventarne uno renderebbe falsi mappa e passaggi al chilometro.
        date: _date,
      ),
    );

    // Navigator invece di GoRouter: la schermata puo' essere aperta anche
    // come foglio, e cosi' si chiude in entrambi i casi.
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = _error;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(title: 'Sessione gia fatta'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Registra un allenamento che hai gia fatto: entra nello storico '
              'e conta per record e statistiche.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('ATTIVITA', tone: SectionTitleTone.muted),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final activity in CardioActivity.values)
                  _ActivityChip(
                    activity: activity,
                    selected: activity == _activity,
                    onTap: () => setState(() => _activity = activity),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionTitle('QUANDO', tone: SectionTitleTone.muted),
            const SizedBox(height: 10),
            InkWell(
              key: const Key('manual-date'),
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                size: AppCardSize.tight,
                tone: AppCardTone.sunken,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        formatFullDate(_date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('DURATA (MINUTI)', tone: SectionTitleTone.muted),
            const SizedBox(height: 10),
            _NumberField(
              key: const Key('manual-duration'),
              controller: _duration,
              hint: '45',
            ),
            if (_activity.tracksDistance) ...[
              const SizedBox(height: 24),
              const SectionTitle(
                'DISTANZA (KM, FACOLTATIVA)',
                tone: SectionTitleTone.muted,
              ),
              const SizedBox(height: 10),
              _NumberField(
                key: const Key('manual-distance'),
                controller: _distance,
                hint: '8,5',
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'SALVA SESSIONE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.hint, super.key});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.activity,
    required this.selected,
    required this.onTap,
  });

  final CardioActivity activity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = activity.accent(theme);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? accent
                : theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(activity.icon, size: 16, color: accent),
            const SizedBox(width: 8),
            Text(
              activity.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected ? accent : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
