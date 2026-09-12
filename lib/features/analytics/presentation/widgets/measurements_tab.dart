import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/decimal_input.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/features/analytics/domain/progress_formatters.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/monthly_accordion.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/progress_shared_widgets.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:intl/intl.dart';

/// Tab "Misure" di ProgressScreen: hero riassuntivo seguito dallo storico
/// delle sessioni di misurazione raggruppate per mese.
class MeasurementsTab extends StatelessWidget {
  const MeasurementsTab({
    required this.measurements,
    required this.logs,
    required this.settings,
    required this.hero,
    super.key,
  });

  final List<BodyMeasurementEntity> measurements;
  final List<BodyWeightLogEntity> logs;
  final Map<String, String> settings;
  final Widget hero;

  @override
  Widget build(BuildContext context) {
    final sortedMeasurements = List<BodyMeasurementEntity>.from(measurements)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by session (minute precision)
    final sessions = <DateTime, List<BodyMeasurementEntity>>{};
    for (final m in sortedMeasurements) {
      final sessionKey = DateTime(
        m.date.year,
        m.date.month,
        m.date.day,
        m.date.hour,
        m.date.minute,
      );
      sessions.putIfAbsent(sessionKey, () => []).add(m);
    }
    final sortedSessionKeys = sessions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Group sessions by month
    final groupedSessions = <String, List<DateTime>>{};
    for (final key in sortedSessionKeys) {
      final monthKey = getMonthKey(key);
      groupedSessions.putIfAbsent(monthKey, () => []).add(key);
    }
    final sortedMonths = groupedSessions.keys.toList();

    final latestByPart = <String, BodyMeasurementEntity>{};
    for (final measurement in sortedMeasurements) {
      latestByPart.putIfAbsent(measurement.part, () => measurement);
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          sliver: SliverToBoxAdapter(child: hero),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionHeader(
                title: 'Misure corporee',
                subtitle: latestByPart.isEmpty
                    ? 'Ancora nessuna misura disponibile'
                    : '${latestByPart.length} aree monitorate',
                action: FilledButton.icon(
                  onPressed: () => _showAddMeasurementSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Check-in'),
                ),
              ),
              const SizedBox(height: 8),
              if (sortedSessionKeys.isEmpty)
                const EmptyStateCard(
                  icon: Icons.straighten_rounded,
                  title: 'Nessuna misura salvata',
                  message:
                      'Inserisci le prime circonferenze per confrontare i cambiamenti nel tempo.',
                )
              else
                ...sortedMonths.asMap().entries.map((monthEntry) {
                  final monthIdx = monthEntry.key;
                  final monthKey = monthEntry.value;
                  final monthSessions = groupedSessions[monthKey]!;

                  return MonthlyAccordion(
                    title: formatMonthKey(monthKey),
                    count: monthSessions.length,
                    initiallyExpanded: monthIdx == 0,
                    child: Column(
                      children: monthSessions.map((sessionDate) {
                        final items = sessions[sessionDate]!;
                        return _MeasurementSessionCard(
                          date: sessionDate,
                          items: items,
                        );
                      }).toList(),
                    ),
                  );
                }),
              const SizedBox(height: 8),
              const _MeasurementTipsCard(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MeasurementSessionCard extends StatelessWidget {
  const _MeasurementSessionCard({required this.date, required this.items});

  final DateTime date;
  final List<BodyMeasurementEntity> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm', 'it_IT').format(date),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${items.length} MISURE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((m) {
                return _MiniMeasurementChip(measurement: m);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMeasurementChip extends StatelessWidget {
  const _MiniMeasurementChip({required this.measurement});
  final BodyMeasurementEntity measurement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canEdit = measurement.id != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        // Unico punto d'accesso alla modifica di una misurazione: il foglio
        // esisteva gia' completo ma non era raggiungibile da nessuna parte.
        onTap: canEdit
            ? () => _showEditMeasurementSheet(context, measurement)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                measurement.part,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                measurement.value.toStringAsFixed(1),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
              Text(
                ' cm',
                style: TextStyle(fontSize: 8, color: theme.colorScheme.outline),
              ),
              if (canEdit) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  size: 10,
                  color: theme.colorScheme.outline,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementTipsCard extends StatelessWidget {
  const _MeasurementTipsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: theme.colorScheme.tertiary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Buone pratiche',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const TipLine(
            text:
                'Misura sempre nello stesso momento della giornata, meglio al mattino.',
          ),
          const TipLine(
            text: 'Usa un metro morbido e mantieni la tensione costante.',
          ),
          const TipLine(
            text: 'Confronta soprattutto i trend, non la singola rilevazione.',
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddMeasurementSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddMeasurementSheet(),
  );
}

/// Foglio di registrazione delle misure.
///
/// Possiede i propri controller: creandoli nella funzione che apre il foglio
/// restavano vivi per sempre, uno per parte del corpo a ogni apertura, e
/// distruggerli dopo l'await arrivava troppo presto, mentre il foglio e'
/// ancora in chiusura.
class _AddMeasurementSheet extends StatefulWidget {
  const _AddMeasurementSheet();

  @override
  State<_AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<_AddMeasurementSheet> {
  static const parts = [
    'Petto',
    'Vita',
    'Fianchi',
    'Bicipite DX',
    'Bicipite SX',
    'Coscia DX',
    'Coscia SX',
    'Polpaccio',
  ];

  late final Map<String, TextEditingController> controllers = {
    for (final part in parts) part: TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainingBloc = context.read<TrainingBloc>();
    final state = trainingBloc.state;

    // Pre-fill with latest values if available
    final latestValues = <String, double>{};
    if (state is TrainingLoaded) {
      for (final m in state.bodyMeasurements) {
        latestValues.putIfAbsent(m.part, () => m.value);
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return SheetSurface(
          gap: 0,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Check-in Misure',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Inserisci le circonferenze attuali. Lascia vuoto per non aggiornare.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...parts.map(
                      (part) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                part,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: DecimalField(
                                controller: controllers[part]!,
                                label: part,
                                suffix: 'cm',
                                dense: true,
                                hint:
                                    latestValues[part]?.toStringAsFixed(1) ??
                                    '0.0',
                                textInputAction: part == parts.last
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final measurements = <String, double>{};
                              controllers.forEach((part, controller) {
                                final value = parseDecimalInput(
                                  controller.text,
                                );
                                if (value != null) measurements[part] = value;
                              });

                              if (measurements.isNotEmpty) {
                                trainingBloc.add(
                                  AddMultipleBodyMeasurementsEvent(
                                    measurements,
                                  ),
                                );
                              }
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Salva Check-in'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _showEditMeasurementSheet(
  BuildContext context,
  BodyMeasurementEntity measurement,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditMeasurementSheet(measurement: measurement),
  );
}

/// Foglio di modifica di una misura, con il controller che vive quanto lui.
class _EditMeasurementSheet extends StatefulWidget {
  const _EditMeasurementSheet({required this.measurement});

  final BodyMeasurementEntity measurement;

  @override
  State<_EditMeasurementSheet> createState() => _EditMeasurementSheetState();
}

class _EditMeasurementSheetState extends State<_EditMeasurementSheet> {
  late final TextEditingController controller = TextEditingController(
    text: widget.measurement.value.toStringAsFixed(1),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _update() {
    final value = parseDecimalInput(controller.text);
    if (value == null) return;

    context.read<TrainingBloc>().add(
      UpdateBodyMeasurementEvent(widget.measurement.id!, value),
    );
    Navigator.pop(context);
  }

  void _delete() {
    context.read<TrainingBloc>().add(
      DeleteBodyMeasurementEvent(widget.measurement.id!),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompactSheet(
      title: 'Modifica ${widget.measurement.part}',
      children: [
        DecimalField(
          controller: controller,
          label: 'Circonferenza',
          suffix: 'cm',
        ),
        const SizedBox(height: 18),
        SheetActions(confirmLabel: 'Aggiorna', onConfirm: _update),
        const SizedBox(height: 4),
        // DeleteBodyMeasurementEvent esisteva in bloc e repository ma
        // non veniva inviato da nessuna schermata: le misurazioni si
        // potevano solo aggiungere.
        TextButton.icon(
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline, size: 18),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          label: const Text('Elimina misurazione'),
        ),
      ],
    );
  }
}
