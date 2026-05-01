import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reloadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadProgressData() {
    final bloc = context.read<TrainingBloc>();
    bloc
      ..add(LoadBodyWeightLogsEvent())
      ..add(LoadBodyMeasurementsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            if (state is TrainingError) {
              return _ProgressErrorState(
                message: state.message,
                onRetry: _reloadProgressData,
              );
            }

            if (state is! TrainingLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                        child: _ProgressHero(
                          logs: state.bodyWeightLogs,
                          measurements: state.bodyMeasurements,
                          settings: state.settings,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: _ProgressTabBar(controller: _tabController),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _WeightHistoryTab(
                              logs: state.bodyWeightLogs,
                              settings: state.settings,
                            ),
                            _MeasurementsTab(
                              measurements: state.bodyMeasurements,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.logs,
    required this.measurements,
    required this.settings,
  });

  final List<BodyWeightLogEntity> logs;
  final List<BodyMeasurementEntity> measurements;
  final Map<String, String> settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedLogs = List<BodyWeightLogEntity>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));
    final sortedMeasurements = List<BodyMeasurementEntity>.from(measurements)
      ..sort((a, b) => b.date.compareTo(a.date));

    final isImperial = settings['units'] == 'LB';
    final latestWeight = sortedLogs.isNotEmpty ? sortedLogs.first : null;
    final previousWeight = sortedLogs.length > 1 ? sortedLogs[1] : null;
    final latestMeasurement =
        sortedMeasurements.isNotEmpty ? sortedMeasurements.first : null;
    final latestCheckIn = _latestDate([
      latestWeight?.date,
      latestMeasurement?.date,
    ]);

    final weightDelta = latestWeight != null && previousWeight != null
        ? latestWeight.weight - previousWeight.weight
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progressi',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Controlla peso e misure con una vista piu pulita e aggiornata.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.16),
                theme.colorScheme.tertiary.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface.withValues(alpha: 0.24),
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latestWeight != null
                              ? _formatWeight(latestWeight.weight, isImperial)
                              : '--',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          latestWeight != null
                              ? 'Ultimo peso registrato'
                              : 'Aggiungi il primo check-in',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (weightDelta != null)
                    _DeltaBadge(
                      value: weightDelta,
                      isImperial: isImperial,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _HeroMetricChip(
                      icon: Icons.straighten_rounded,
                      label: 'Misure salvate',
                      value: measurements.length.toString(),
                    ),
                    const SizedBox(width: 10),
                    _HeroMetricChip(
                      icon: Icons.history_toggle_off_rounded,
                      label: 'Ultimo check-in',
                      value: latestCheckIn != null
                          ? DateFormat('dd MMM', 'it_IT').format(latestCheckIn)
                          : 'Nessuno',
                    ),
                    const SizedBox(width: 10),
                    _HeroMetricChip(
                      icon: Icons.insights_rounded,
                      label: 'Ultima misura',
                      value: latestMeasurement?.part ?? 'Non disponibile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressTabBar extends StatelessWidget {
  const _ProgressTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        splashBorderRadius: BorderRadius.circular(14),
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.outline,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontFamily: 'Lexend',
          fontSize: 13,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Peso'),
          Tab(text: 'Misure'),
        ],
      ),
    );
  }
}

class _WeightHistoryTab extends StatelessWidget {
  const _WeightHistoryTab({
    required this.logs,
    required this.settings,
  });

  final List<BodyWeightLogEntity> logs;
  final Map<String, String> settings;

  @override
  Widget build(BuildContext context) {
    final isImperial = settings['units'] == 'LB';
    final sortedLogs = List<BodyWeightLogEntity>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionHeader(
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
              _WeightInsightCard(
                logs: sortedLogs,
                isImperial: isImperial,
              ),
              const SizedBox(height: 16),
              if (sortedLogs.isEmpty)
                const _EmptyStateCard(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Ancora nessun peso registrato',
                  message:
                      'Aggiungi il primo check-in per iniziare a seguire l andamento nel tempo.',
                )
              else
                ...sortedLogs.map(
                  (log) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LogTile(
                      title: _formatWeight(log.weight, isImperial),
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
                ),
            ]),
          ),
        ),
      ],
    );
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Peso',
                    suffixText: isImperial ? 'lb' : 'kg',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHigh
                        .withValues(alpha: 0.35),
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
                          context
                              .read<TrainingBloc>()
                              .add(AddBodyWeightLogEvent(value));
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
}

class _MeasurementsTab extends StatelessWidget {
  const _MeasurementsTab({
    required this.measurements,
  });

  final List<BodyMeasurementEntity> measurements;

  @override
  Widget build(BuildContext context) {
    final sortedMeasurements = List<BodyMeasurementEntity>.from(measurements)
      ..sort((a, b) => b.date.compareTo(a.date));
    final latestByPart = <String, BodyMeasurementEntity>{};
    for (final measurement in sortedMeasurements) {
      latestByPart.putIfAbsent(measurement.part, () => measurement);
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionHeader(
                title: 'Misure corporee',
                subtitle: latestByPart.isEmpty
                    ? 'Ancora nessuna misura disponibile'
                    : '${latestByPart.length} aree monitorate',
                action: FilledButton.icon(
                  onPressed: () => _showAddMeasurementSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nuova misura'),
                ),
              ),
              const SizedBox(height: 16),
              if (latestByPart.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: latestByPart.values
                      .map(
                        (measurement) => _MeasurementChip(
                          measurement: measurement,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
              ],
              if (sortedMeasurements.isEmpty)
                const _EmptyStateCard(
                  icon: Icons.straighten_rounded,
                  title: 'Nessuna misura salvata',
                  message:
                      'Inserisci le prime circonferenze per confrontare i cambiamenti nel tempo.',
                )
              else
                ...sortedMeasurements.map(
                  (measurement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LogTile(
                      title:
                          '${measurement.part} - ${measurement.value.toStringAsFixed(1)} cm',
                      subtitle: DateFormat(
                        'dd MMM yyyy',
                        'it_IT',
                      ).format(measurement.date),
                      icon: Icons.straighten_rounded,
                      onDelete: () => context
                          .read<TrainingBloc>()
                          .add(DeleteBodyMeasurementEvent(measurement.id!)),
                      onEdit: () =>
                          _showEditMeasurementSheet(context, measurement),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const _MeasurementTipsCard(),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddMeasurementSheet(BuildContext context) async {
    const parts = [
      'Petto',
      'Vita',
      'Fianchi',
      'Bicipite DX',
      'Bicipite SX',
      'Coscia DX',
      'Coscia SX',
      'Polpaccio',
    ];

    String selectedPart = parts.first;
    final valueController = TextEditingController();
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      'Nuova misura',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: selectedPart,
                      decoration: InputDecoration(
                        labelText: 'Parte del corpo',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: parts
                          .map(
                            (part) =>
                                DropdownMenuItem(value: part, child: Text(part)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedPart = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Circonferenza',
                        suffixText: 'cm',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.35),
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
                              final value = double.tryParse(
                                valueController.text.replaceAll(',', '.'),
                              );
                              if (value == null) return;
                              context.read<TrainingBloc>().add(
                                    AddBodyMeasurementEvent(selectedPart, value),
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
      },
    );
  }

  Future<void> _showEditMeasurementSheet(
    BuildContext context,
    BodyMeasurementEntity measurement,
  ) async {
    final controller = TextEditingController(
      text: measurement.value.toStringAsFixed(1),
    );
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
                  'Modifica ${measurement.part}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Circonferenza',
                    suffixText: 'cm',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHigh
                        .withValues(alpha: 0.35),
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
                          final value = double.tryParse(
                            controller.text.replaceAll(',', '.'),
                          );
                          if (value == null) return;
                          context.read<TrainingBloc>().add(
                                UpdateBodyMeasurementEvent(
                                  measurement.id!,
                                  value,
                                ),
                              );
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Aggiorna'),
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
}

class _WeightInsightCard extends StatelessWidget {
  const _WeightInsightCard({
    required this.logs,
    required this.isImperial,
  });

  final List<BodyWeightLogEntity> logs;
  final bool isImperial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
              ),
              child: Icon(
                Icons.timeline_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Quando registrerai almeno due pesi vedrai subito l andamento recente.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final latest = logs.first;
    final oldest = logs.last;
    final change = latest.weight - oldest.weight;
    final totalEntries = logs.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Attuale',
                  value: _formatWeight(latest.weight, isImperial),
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniMetric(
                  label: 'Trend',
                  value: _formatSignedWeight(change, isImperial),
                  icon: change <= 0
                      ? Icons.south_east_rounded
                      : Icons.north_east_rounded,
                  accent: change <= 0 ? Colors.tealAccent : Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniMetric(
                  label: 'Log',
                  value: '$totalEntries',
                  icon: Icons.history_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dal ${DateFormat('dd MMM', 'it_IT').format(oldest.date)} al ${DateFormat('dd MMM yyyy', 'it_IT').format(latest.date)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ],
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
          const _TipLine(
            text:
                'Misura sempre nello stesso momento della giornata, meglio al mattino.',
          ),
          const _TipLine(
            text: 'Usa un metro morbido e mantieni la tensione costante.',
          ),
          const _TipLine(
            text: 'Confronta soprattutto i trend, non la singola rilevazione.',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        action,
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onDelete,
    this.onEdit,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressErrorState extends StatelessWidget {
  const _ProgressErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.error,
                size: 44,
              ),
              const SizedBox(height: 14),
              Text(
                'Non riesco a caricare i progressi',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Ricarica dati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricChip extends StatelessWidget {
  const _HeroMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeasurementChip extends StatelessWidget {
  const _MeasurementChip({
    required this.measurement,
  });

  final BodyMeasurementEntity measurement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            measurement.part,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${measurement.value.toStringAsFixed(1)} cm',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({
    required this.value,
    required this.isImperial,
  });

  final double value;
  final bool isImperial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDown = value <= 0;
    final accent = isDown ? theme.colorScheme.tertiary : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDown ? Icons.south_rounded : Icons.north_rounded,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 4),
              Text(
                _formatSignedWeight(value, isImperial),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'vs ultimo log',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  const _TipLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

DateTime? _latestDate(List<DateTime?> dates) {
  final filtered = dates.whereType<DateTime>().toList();
  if (filtered.isEmpty) return null;
  filtered.sort((a, b) => b.compareTo(a));
  return filtered.first;
}

String _formatWeight(double weightKg, bool isImperial) {
  final value = isImperial ? UnitConverter.kgToLb(weightKg) : weightKg;
  final unit = isImperial ? 'lb' : 'kg';
  return '${value.toStringAsFixed(1)} $unit';
}

String _formatSignedWeight(double weightKg, bool isImperial) {
  final value = isImperial ? UnitConverter.kgToLb(weightKg) : weightKg;
  final unit = isImperial ? 'lb' : 'kg';
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(1)} $unit';
}
