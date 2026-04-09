import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
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

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<TrainingBloc>().add(LoadBodyWeightLogsEvent());
    context.read<TrainingBloc>().add(LoadBodyMeasurementsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.outline,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 13),
              tabs: const [
                Tab(text: 'STORICO PESO'),
                Tab(text: 'MISURE CORPO'),
              ],
            ),
            Expanded(
              child: BlocBuilder<TrainingBloc, TrainingState>(
                builder: (context, state) {
                  if (state is! TrainingLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _WeightHistoryTab(logs: state.bodyWeightLogs, settings: state.settings),
                      _MeasurementsTab(measurements: state.bodyMeasurements, settings: state.settings),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progressi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              Text(
                'MONITORAGGIO FISICO',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton.outlined(
            onPressed: () {
              context.read<TrainingBloc>().add(ReseedWeightHistoryEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dati peso resettati e rigenerati (10gg)')),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Rigenera Dati Test',
          ),
        ],
      ),
    );
  }
}

class _WeightHistoryTab extends StatelessWidget {
  const _WeightHistoryTab({required this.logs, required this.settings});
  final List<BodyWeightLogEntity> logs;
  final Map<String, String> settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImperial = settings['units'] == 'LB';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOG PESO RECENTI',
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              IconButton.filled(
                onPressed: () => _showAddWeightDialog(context, isImperial),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: logs.isEmpty
              ? const Center(child: Text('Nessun dato registrato.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final weight = isImperial ? UnitConverter.kgToLb(log.weight) : log.weight;
                    return _StatsTile(
                      title: '${weight.toStringAsFixed(1)} ${isImperial ? 'lb' : 'kg'}',
                      subtitle: DateFormat('dd MMM yyyy, HH:mm', 'it_IT').format(log.date),
                      icon: Icons.scale_rounded,
                      onDelete: () => context.read<TrainingBloc>().add(DeleteBodyWeightLogEvent(log.id!)),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddWeightDialog(BuildContext context, bool isImperial) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registra Peso'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Peso (${isImperial ? 'lb' : 'kg'})',
            suffixText: isImperial ? 'lb' : 'kg',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              final valStr = controller.text.replaceAll(',', '.');
              var val = double.tryParse(valStr);
              if (val != null) {
                if (isImperial) val = UnitConverter.lbToKg(val);
                context.read<TrainingBloc>().add(AddBodyWeightLogEvent(val));
                Navigator.pop(context);
              }
            }, 
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}


class _MeasurementsTab extends StatelessWidget {
  const _MeasurementsTab({required this.measurements, required this.settings});
  final List<BodyMeasurementEntity> measurements;
  final Map<String, String> settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LE TUE MISURE',
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              IconButton.filled(
                onPressed: () => _showAddMeasurementDialog(context),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: measurements.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: measurements.length + 1,
                  itemBuilder: (context, index) {
                    if (index == measurements.length) return _buildTipsSection(theme);
                    final m = measurements[index];
                    return _StatsTile(
                      title: '${m.part}: ${m.value.toStringAsFixed(1)} cm',
                      subtitle: DateFormat('dd MMM yyyy', 'it_IT').format(m.date),
                      icon: Icons.straighten_rounded,
                      onDelete: () => context.read<TrainingBloc>().add(DeleteBodyMeasurementEvent(m.id!)),
                      onEdit: () => _showEditMeasurementDialog(context, m),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.straighten, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Nessuna misura salvata', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildTipsSection(theme),
        ],
      ),
    );
  }

  Widget _buildTipsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'TIPS PER LE MISURAZIONI',
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Misura sempre nello stesso momento della giornata (meglio al mattino a stomaco vuoto).'),
          _buildTipItem('Usa un metro da sarta flessibile, senza stringere troppo sulla pelle.'),
          _buildTipItem('Mantieni i muscoli rilassati durante la misurazione.'),
          _buildTipItem('Effettua la misura nel punto di massima circonferenza.'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

  void _showAddMeasurementDialog(BuildContext context) {
    final partController = TextEditingController();
    final valueController = TextEditingController();
    final parts = ['Petto', 'Vita', 'Fianchi', 'Bicipite DX', 'Bicipite SX', 'Coscia DX', 'Coscia SX', 'Polpaccio'];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova Misura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Parte del corpo'),
              items: parts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => partController.text = val ?? '',
            ),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Circonferenza', suffixText: 'cm'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(valueController.text.replaceAll(',', '.'));
              if (val != null && partController.text.isNotEmpty) {
                context.read<TrainingBloc>().add(AddBodyMeasurementEvent(partController.text, val));
                Navigator.pop(context);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _showEditMeasurementDialog(BuildContext context, BodyMeasurementEntity m) {
    final valueController = TextEditingController(text: m.value.toStringAsFixed(1));
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifica ${m.part}'),
        content: TextField(
          controller: valueController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Circonferenza', suffixText: 'cm'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(valueController.text.replaceAll(',', '.'));
              if (val != null) {
                context.read<TrainingBloc>().add(UpdateBodyMeasurementEvent(m.id!, val));
                Navigator.pop(context);
              }
            },
            child: const Text('Aggiorna'),
          ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  const _StatsTile({
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Lexend')),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null) IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
            IconButton(icon: Icon(Icons.delete_outline_rounded, size: 20, color: theme.colorScheme.error), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
