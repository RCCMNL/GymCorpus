import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_bloc.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_event.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_action_button.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_history_card.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_month_calendar.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_info.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_ring.dart';

/// Calendario del ciclo mestruale.
///
/// Tutto quello che mostra viene dalle date registrate dall'utente e resta
/// nel database locale cifrato: non viene sincronizzato ne' incluso nel
/// report PDF.
class CycleCalendarScreen extends StatefulWidget {
  const CycleCalendarScreen({super.key});

  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  final DateTime _today = DateTime.now();
  late DateTime _visibleMonth = DateTime(_today.year, _today.month);

  void _shiftMonth(int months) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + months);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(title: 'Ciclo & Fitness'),
      body: SafeArea(
        child: BlocConsumer<CycleBloc, CycleState>(
          listenWhen: (previous, current) =>
              current.errorMessage != null &&
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.error,
              ),
            );
          },
          builder: (context, state) {
            final summary = state.summary;
            if (state.isLoading || summary == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final bloc = context.read<CycleBloc>();
            final phase = summary.phase;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                Text(
                  'Calendario Ciclo',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    color: CyclePalette.period,
                  ),
                ),
                Text(
                  'Ottimizza i tuoi allenamenti in base al tuo corpo.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),
                CyclePhaseRing(summary: summary),
                const SizedBox(height: 24),
                CycleActionButton(
                  hasOpenLog: summary.hasOpenLog,
                  onStart: () => bloc.add(StartPeriodEvent()),
                  onEnd: () => bloc.add(EndPeriodEvent()),
                ),
                if (phase != null) ...[
                  const SizedBox(height: 24),
                  _PhaseAdviceCard(phase: phase),
                ],
                const SizedBox(height: 32),
                Text(
                  'STORICO & PREVISIONI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                CycleMonthCalendar(
                  month: _visibleMonth,
                  logs: state.logs,
                  summary: summary,
                  today: _today,
                  onPreviousMonth: () => _shiftMonth(-1),
                  onNextMonth: () => _shiftMonth(1),
                ),
                const SizedBox(height: 16),
                CycleHistoryCard(
                  logs: state.logs,
                  summary: summary,
                  onDelete: (id) => bloc.add(DeleteCycleLogEvent(id)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Consiglio di allenamento per la fase corrente.
class _PhaseAdviceCard extends StatelessWidget {
  const _PhaseAdviceCard({required this.phase});

  final CyclePhase phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = CyclePhaseInfo.of(phase);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, color: info.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allenamento ideale',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                Text(info.advice, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
