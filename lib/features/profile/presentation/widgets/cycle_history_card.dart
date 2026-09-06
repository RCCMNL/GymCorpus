import 'package:flutter/material.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_info.dart';
import 'package:intl/intl.dart';

/// Storico dei cicli registrati e previsione del prossimo.
///
/// Ogni registrazione si puo' cancellare: un tocco sbagliato altrimenti
/// resterebbe per sempre dentro le medie.
class CycleHistoryCard extends StatelessWidget {
  const CycleHistoryCard({
    required this.logs,
    required this.summary,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  final List<CycleLogEntity> logs;
  final CycleSummary summary;
  final ValueChanged<int> onDelete;

  /// Correzione di una registrazione: una data sbagliata si sistema, non
  /// si cancella e riscrive.
  final ValueChanged<CycleLogEntity> onEdit;

  /// Quante registrazioni mostrare: lo storico serve a controllare le ultime
  /// e a correggerle, non a scorrere anni di dati.
  static const _maxVisible = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = [...logs]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            icon: Icons.event_repeat_rounded,
            label: 'Prossimo ciclo',
            value: _nextPeriodText(),
            highlight: summary.daysLate != null,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.timelapse_rounded,
            label: 'Durata media',
            value: summary.isEstimatedLength
                ? '${summary.cycleLength} giorni (stima)'
                : '${summary.cycleLength} giorni',
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'REGISTRAZIONI',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            for (final log in recent.take(_maxVisible))
              _LogRow(
                log: log,
                onDelete: () => _confirmDelete(context, log),
                onEdit: () => onEdit(log),
              ),
          ],
        ],
      ),
    );
  }

  String _nextPeriodText() {
    final late = summary.daysLate;
    if (late != null) {
      return 'In ritardo di $late ${late == 1 ? 'giorno' : 'giorni'}';
    }

    final next = summary.nextPeriodStart;
    if (next == null) return 'Non ancora prevedibile';

    return DateFormat('d MMMM yyyy', 'it_IT').format(next);
  }

  Future<void> _confirmDelete(BuildContext context, CycleLogEntity log) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Eliminare la registrazione?',
          style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend'),
        ),
        content: Text(
          'Il ciclo ${_dateRange(log)} verra cancellato e non contera piu '
          'nelle medie.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'ELIMINA',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) onDelete(log.id);
  }

  static String _dateRange(CycleLogEntity log) {
    final start = log.startDate;
    final end = log.endDate;

    if (end == null) {
      return 'Dal ${DateFormat('d MMMM yyyy', 'it_IT').format(start)}';
    }

    // Dentro lo stesso mese il mese si scrive una volta sola: "2 - 6
    // settembre 2026" invece di ripeterlo su entrambe le date.
    if (start.year == end.year && start.month == end.month) {
      return '${start.day} - '
          '${DateFormat('d MMMM yyyy', 'it_IT').format(end)}';
    }

    final format = DateFormat('d MMMM', 'it_IT');
    return '${format.format(start)} - '
        '${DateFormat('d MMMM yyyy', 'it_IT').format(end)}';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight ? CyclePalette.period : theme.colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: highlight ? CyclePalette.period : null,
          ),
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({
    required this.log,
    required this.onDelete,
    required this.onEdit,
  });

  final CycleLogEntity log;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final end = log.endDate;
    final days = end == null ? null : end.difference(log.startDate).inDays + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Text(
                CycleHistoryCard._dateRange(log),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          Text(
            days == null
                ? 'In corso'
                : '$days ${days == 1 ? 'giorno' : 'giorni'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            key: Key('cycle-delete-${log.id}'),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: theme.colorScheme.outline,
            tooltip: 'Elimina registrazione',
          ),
        ],
      ),
    );
  }
}
