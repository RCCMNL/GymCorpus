import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
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

            final profileWeight = context.read<AuthBloc>().state.maybeWhen(
                  authenticated: (user) => user.weight,
                  orElse: () => null,
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Text(
                    'Progressi',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _ProgressTabBar(controller: _tabController),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _tabController,
                    builder: (context, _) {
                      final isWeightTab = _tabController.index == 0;
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _WeightHistoryTab(
                            logs: state.bodyWeightLogs,
                            profileWeight: profileWeight,
                            settings: state.settings,
                            hero: _ProgressHero(
                              logs: state.bodyWeightLogs,
                              profileWeight: profileWeight,
                              measurements: state.bodyMeasurements,
                              settings: state.settings,
                              activeTab: 0,
                            ),
                          ),
                          _MeasurementsTab(
                            measurements: state.bodyMeasurements,
                            logs: state.bodyWeightLogs,
                            settings: state.settings,
                            hero: _ProgressHero(
                              logs: state.bodyWeightLogs,
                              profileWeight: profileWeight,
                              measurements: state.bodyMeasurements,
                              settings: state.settings,
                              activeTab: 1,
                            ),
                          ),
                        ],
                      );
                    },
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

class _ProgressHero extends StatefulWidget {
  const _ProgressHero({
    required this.logs,
    required this.profileWeight,
    required this.measurements,
    required this.settings,
    required this.activeTab,
  });

  final List<BodyWeightLogEntity> logs;
  final double? profileWeight;
  final List<BodyMeasurementEntity> measurements;
  final Map<String, String> settings;
  final int activeTab;

  @override
  State<_ProgressHero> createState() => _ProgressHeroState();
}

class _ProgressHeroState extends State<_ProgressHero> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedLogs = List<BodyWeightLogEntity>.from(widget.logs)
      ..sort((a, b) => b.date.compareTo(a.date));
    final sortedMeasurements = List<BodyMeasurementEntity>.from(widget.measurements)
      ..sort((a, b) => b.date.compareTo(a.date));

    final isImperial = widget.settings['units'] == 'LB';
    final latestWeight = sortedLogs.isNotEmpty ? sortedLogs.first : null;
    final previousWeight = sortedLogs.length > 1 ? sortedLogs[1] : null;
    final latestMeasurement =
        sortedMeasurements.isNotEmpty ? sortedMeasurements.first : null;

    final isWeightTab = widget.activeTab == 0;
    
    // For measurements summary grid
    final latestByPart = <String, BodyMeasurementEntity>{};
    for (final measurement in sortedMeasurements) {
      latestByPart.putIfAbsent(measurement.part, () => measurement);
    }
    final sortedParts = latestByPart.keys.toList()..sort();

    final weightDelta = latestWeight != null && previousWeight != null
        ? latestWeight.weight - previousWeight.weight
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isWeightTab 
            ? 'Controlla l\'andamento del tuo peso.'
            : 'Monitora le tue circonferenze corporee.',
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
              colors: isWeightTab 
                ? [
                    theme.colorScheme.primary.withValues(alpha: 0.16),
                    theme.colorScheme.tertiary.withValues(alpha: 0.10),
                  ]
                : [
                    theme.colorScheme.tertiary.withValues(alpha: 0.16),
                    theme.colorScheme.primary.withValues(alpha: 0.10),
                  ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: (isWeightTab ? theme.colorScheme.primary : theme.colorScheme.tertiary).withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeightTab) ...[
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
                                : widget.profileWeight != null
                                    ? _formatWeight(
                                        widget.profileWeight!,
                                        isImperial,
                                      )
                                : '--',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            latestWeight != null
                                ? 'Ultimo peso registrato'
                                : widget.profileWeight != null
                                    ? 'Peso attuale dal profilo'
                                : 'Nessun peso registrato',
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
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetricChip(
                        icon: Icons.history_toggle_off_rounded,
                        label: 'Ultimo log peso',
                        value: latestWeight != null
                            ? DateFormat('dd MMM yyyy', 'it_IT').format(latestWeight.date)
                            : widget.profileWeight != null
                                ? 'Profilo'
                            : 'Nessun dato',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.straighten_rounded,
                          size: 18,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stato Attuale',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Lexend',
                              ),
                            ),
                            Text(
                              '${latestByPart.length} aree monitorate',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: sortedParts.length,
                    itemBuilder: (context, index) {
                      final part = sortedParts[index];
                      final m = latestByPart[part]!;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              part.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.outline,
                                fontSize: 8,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${m.value.toStringAsFixed(1)} cm',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Lexend',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.outline,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontFamily: 'Lexend',
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
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
    required this.profileWeight,
    required this.settings,
    required this.hero,
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
      final monthKey = _getMonthKey(log.date);
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
              if (sortedLogs.isEmpty)
                profileWeight != null
                    ? _EmptyStateCard(
                        icon: Icons.monitor_weight_outlined,
                        title:
                            'Peso profilo disponibile: ${_formatWeight(profileWeight!, isImperial)}',
                        message:
                            'Il peso attuale del profilo e disponibile. Aggiungi un check-in per iniziare la cronologia dei progressi.',
                      )
                    : const _EmptyStateCard(
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
                  
                  return _MonthlyAccordion(
                    title: _formatMonthKey(monthKey),
                    count: monthLogs.length,
                    initiallyExpanded: idx == 0,
                    child: Column(
                      children: monthLogs.map(
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
                      ).toList(),
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

class _MeasurementsTab extends StatelessWidget {
  const _MeasurementsTab({
    required this.measurements,
    required this.logs,
    required this.settings,
    required this.hero,
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
      final sessionKey = DateTime(m.date.year, m.date.month, m.date.day, m.date.hour, m.date.minute);
      sessions.putIfAbsent(sessionKey, () => []).add(m);
    }
    final sortedSessionKeys = sessions.keys.toList()..sort((a, b) => b.compareTo(a));

    // Group sessions by month
    final groupedSessions = <String, List<DateTime>>{};
    for (final key in sortedSessionKeys) {
      final monthKey = _getMonthKey(key);
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
              _SectionHeader(
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
                const _EmptyStateCard(
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
                  
                  return _MonthlyAccordion(
                    title: _formatMonthKey(monthKey),
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
  const _MeasurementSessionCard({
    required this.date,
    required this.items,
  });

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
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
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
                    Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.primary),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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
            '${measurement.value.toStringAsFixed(1)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
          const Text(
            ' cm',
            style: TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _MonthlyAccordion extends StatefulWidget {
  const _MonthlyAccordion({
    required this.title,
    required this.count,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final int count;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_MonthlyAccordion> createState() => _MonthlyAccordionState();
}

class _MonthlyAccordionState extends State<_MonthlyAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _expanded ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                    color: _expanded ? theme.colorScheme.onSurface : theme.colorScheme.outline.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) widget.child,
      ],
    );
  }
}

String _getMonthKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

String _formatMonthKey(String key) {
  final parts = key.split('-');
  final year = parts[0];
  final month = int.parse(parts[1]);
  final monthName = [
    '', 'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
  ][month];
  return '$monthName $year'.toUpperCase();
}

Future<void> _showAddMeasurementSheet(BuildContext context) async {
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

    final parts = [
      'Petto',
      'Vita',
      'Fianchi',
      'Bicipite DX',
      'Bicipite SX',
      'Coscia DX',
      'Coscia SX',
      'Polpaccio',
    ];

    final controllers = {
      for (var part in parts) part: TextEditingController()
    };

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
                        ...parts.map((part) => Padding(
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
                                child: TextField(
                                  controller: controllers[part],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: part == parts.last ? TextInputAction.done : TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: latestValues[part]?.toStringAsFixed(1) ?? '0.0',
                                    suffixText: 'cm',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    filled: true,
                                    fillColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                    final val = double.tryParse(controller.text.replaceAll(',', '.'));
                                    if (val != null) {
                                      measurements[part] = val;
                                    }
                                  });
                                  
                                  if (measurements.isNotEmpty) {
                                    trainingBloc.add(AddMultipleBodyMeasurementsEvent(measurements));
                                  }
                                  Navigator.pop(sheetContext);
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
