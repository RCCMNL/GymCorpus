import 'package:flutter/material.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_info.dart';

/// Calendario mensile del ciclo.
///
/// Ogni casella viene dalle registrazioni: prima erano sempre 31 giorni con
/// i primi cinque colorati, indipendentemente dal mese e dai dati.
class CycleMonthCalendar extends StatelessWidget {
  const CycleMonthCalendar({
    required this.month,
    required this.logs,
    required this.summary,
    required this.today,
    required this.onPreviousMonth,
    required this.onNextMonth,
    super.key,
  });

  final DateTime month;
  final List<CycleLogEntity> logs;
  final CycleSummary summary;
  final DateTime today;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const _weekdays = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    // weekday va da 1 (lunedi) a 7: le caselle vuote iniziali sono i giorni
    // della settimana che precedono il primo del mese.
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;
    final periodDays = _periodDays();
    final predictedDays = _predictedDays().difference(periodDays);
    final showsToday = today.year == month.year && today.month == month.month;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  formatMonthYear(month).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    key: const Key('cycle-previous-month'),
                    onPressed: onPreviousMonth,
                    icon: const Icon(Icons.chevron_left),
                    color: theme.colorScheme.outline,
                    tooltip: 'Mese precedente',
                  ),
                  IconButton(
                    key: const Key('cycle-next-month'),
                    onPressed: onNextMonth,
                    icon: const Icon(Icons.chevron_right),
                    color: theme.colorScheme.outline,
                    tooltip: 'Mese successivo',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final label in _weekdays)
                Expanded(child: Center(child: StatLabel(label))),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();

              final day = index - leadingBlanks + 1;
              return CycleDayCell(
                day: day,
                isPeriod: periodDays.contains(day),
                isPredicted: predictedDays.contains(day),
                isToday: showsToday && today.day == day,
              );
            },
          ),
          const SizedBox(height: 16),
          const _CalendarLegend(),
        ],
      ),
    );
  }

  /// Giorni di mestruazione registrati che cadono nel mese mostrato.
  ///
  /// Un ciclo ancora aperto arriva fino a oggi: e' quello che l'utente sta
  /// vivendo, e fermarlo al giorno di inizio lo farebbe quasi sparire dal
  /// calendario.
  Set<int> _periodDays() {
    final days = <int>{};

    for (final log in logs) {
      final start = DateUtils.dateOnly(log.startDate);
      final end = DateUtils.dateOnly(log.endDate ?? today);

      for (
        var date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))
      ) {
        if (date.year == month.year && date.month == month.month) {
          days.add(date.day);
        }
      }
    }

    return days;
  }

  Set<int> _predictedDays() {
    final start = summary.nextPeriodStart;
    if (start == null) return const {};

    final days = <int>{};
    for (var i = 0; i < summary.periodLength; i++) {
      final date = start.add(Duration(days: i));
      if (date.year == month.year && date.month == month.month) {
        days.add(date.day);
      }
    }
    return days;
  }
}

/// Una casella del calendario.
class CycleDayCell extends StatelessWidget {
  const CycleDayCell({
    required this.day,
    required this.isPeriod,
    required this.isPredicted,
    required this.isToday,
    super.key,
  });

  final int day;
  final bool isPeriod;
  final bool isPredicted;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Border? border;
    final Color textColor;
    if (isPeriod) {
      border = Border.all(color: CyclePalette.period, width: 1.5);
      textColor = CyclePalette.period;
    } else if (isPredicted) {
      border = Border.all(color: CyclePalette.period.withValues(alpha: 0.4));
      textColor = CyclePalette.period.withValues(alpha: 0.7);
    } else if (isToday) {
      border = Border.all(color: theme.colorScheme.primary);
      textColor = theme.colorScheme.primary;
    } else {
      border = null;
      textColor = theme.colorScheme.onSurface;
    }

    return Container(
      decoration: BoxDecoration(
        color: isPeriod
            ? CyclePalette.period.withValues(alpha: 0.2)
            : isToday
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontWeight: isPeriod || isToday || isPredicted
                ? FontWeight.bold
                : FontWeight.normal,
            color: textColor,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        const _LegendDot(color: CyclePalette.period, label: 'Registrato'),
        _LegendDot(
          color: CyclePalette.period.withValues(alpha: 0.4),
          label: 'Previsto',
        ),
        _LegendDot(color: theme.colorScheme.primary, label: 'Oggi'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
