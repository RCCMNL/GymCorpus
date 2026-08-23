import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/analytics/domain/progress_formatters.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/monthly_accordion.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/progress_shared_widgets.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:intl/intl.dart';

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
                                subtitle: DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                  'it_IT',
                                ).format(log.date),
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
  final controller = TextEditingController();
  final theme = Theme.of(context);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          top: 24,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registra peso',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Salva il valore attuale per aggiornare la tua cronologia.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Peso',
                  suffixText: isImperial ? 'lb' : 'kg',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh.withValues(
                    alpha: 0.35,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final valStr = controller.text.replaceAll(',', '.');
                        var value = double.tryParse(valStr);
                        if (value == null) return;
                        if (isImperial) value = UnitConverter.lbToKg(value);
                        context.read<TrainingBloc>().add(
                          AddBodyWeightLogEvent(value),
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Salva'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
