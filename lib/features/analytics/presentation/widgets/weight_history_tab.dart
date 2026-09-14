import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/utils/decimal_input.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/features/analytics/domain/progress_formatters.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/monthly_accordion.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/progress_shared_widgets.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';

/// Tab "Peso" di ProgressScreen: hero riassuntivo seguito dallo storico
/// dei check-in di peso raggruppati per mese.
class WeightHistoryTab extends StatelessWidget {
  const WeightHistoryTab({
    required this.logs,
    required this.profileWeight,
    required this.settings,
    required this.hero,
    super.key,
  });

  final List<BodyWeightLogEntity> logs;
  final double? profileWeight;
  final Map<String, String> settings;
  final Widget hero;

  @override
  Widget build(BuildContext context) {
    final isImperial = settings['units'] == 'LB';
    final sortedLogs = List<BodyWeightLogEntity>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group logs by month
    final groupedLogs = <String, List<BodyWeightLogEntity>>{};
    for (final log in sortedLogs) {
      final monthKey = getMonthKey(log.date);
      groupedLogs.putIfAbsent(monthKey, () => []).add(log);
    }

    final sortedMonths = groupedLogs.keys.toList();

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
                title: 'Storico peso',
                subtitle: sortedLogs.isEmpty
                    ? 'Nessuna registrazione disponibile'
                    : '${sortedLogs.length} check-in registrati',
                action: FilledButton.icon(
                  onPressed: () => _showAddWeightSheet(context, isImperial),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Aggiungi'),
                ),
              ),
              const SizedBox(height: 16),
              if (sortedLogs.isEmpty)
                profileWeight != null
                    ? EmptyStateCard(
                        icon: Icons.monitor_weight_outlined,
                        title:
                            'Peso profilo disponibile: ${formatWeight(profileWeight!, isImperial: isImperial)}',
                        message:
                            'Il peso attuale del profilo e disponibile. Aggiungi un check-in per iniziare la cronologia dei progressi.',
                      )
                    : const EmptyStateCard(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Ancora nessun peso registrato',
                        message:
                            'Aggiungi il primo check-in per iniziare a seguire l andamento nel tempo.',
                      )
              else
                ...sortedMonths.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final monthKey = entry.value;
                  final monthLogs = groupedLogs[monthKey]!;

                  return MonthlyAccordion(
                    title: formatMonthKey(monthKey),
                    count: monthLogs.length,
                    initiallyExpanded: idx == 0,
                    child: Column(
                      children: monthLogs
                          .map(
                            (log) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LogTile(
                                title: formatWeight(
                                  log.weight,
                                  isImperial: isImperial,
                                ),
                                subtitle: formatDateTimeShort(log.date),
                                icon: Icons.scale_rounded,
                                onDelete: () => context
                                    .read<TrainingBloc>()
                                    .add(DeleteBodyWeightLogEvent(log.id!)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),
            ]),
          ),
        ),
      ],
    );
  }
}

Future<void> _showAddWeightSheet(BuildContext context, bool isImperial) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddWeightSheet(isImperial: isImperial),
  );
}

/// Foglio di registrazione del peso.
///
/// Possiede il proprio controller: creandolo nella funzione che apre il
/// foglio restava vivo per sempre, e distruggerlo dopo l'await arrivava
/// troppo presto, mentre il foglio e' ancora in chiusura.
class _AddWeightSheet extends StatefulWidget {
  const _AddWeightSheet({required this.isImperial});

  final bool isImperial;

  @override
  State<_AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends State<_AddWeightSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = parseDecimalInput(_controller.text);
    if (value == null) return;

    context.read<TrainingBloc>().add(
      AddBodyWeightLogEvent(
        widget.isImperial ? UnitConverter.lbToKg(value) : value,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CompactSheet(
      title: 'Registra peso',
      subtitle: 'Salva il valore attuale per aggiornare la tua cronologia.',
      children: [
        DecimalField(
          controller: _controller,
          label: 'Peso',
          suffix: widget.isImperial ? 'lb' : 'kg',
          autofocus: true,
        ),
        const SizedBox(height: 18),
        SheetActions(confirmLabel: 'Salva', onConfirm: _save),
      ],
    );
  }
}
