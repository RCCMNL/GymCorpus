import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/confirm_dialog.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_activity_style.dart';

/// Le tre sessioni cardio piu' recenti, con link alla cronologia
/// completa.
class CardioHistorySection extends StatelessWidget {
  const CardioHistorySection({required this.state, super.key});
  final TrainingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var sessions = state is TrainingLoaded
        ? (state as TrainingLoaded).cardioSessions
        : <CardioSessionEntity>[];

    // Sort by date newest first
    sessions = List<CardioSessionEntity>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final displaySessions = sessions.take(3).toList();

    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFF9494), Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SectionTitle(
                    'RECENTI CARDIO',
                    tone: SectionTitleTone.muted,
                  ),
                ],
              ),
              if (sessions.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/analytics/cardio-history'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.05,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GUARDA TUTTE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Nessuna sessione registrata',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            )
          else
            ...displaySessions.map(
              (session) => CompactCardioCard(session: session),
            ),
        ],
      ),
    );
  }
}

class CompactCardioCard extends StatelessWidget {
  const CompactCardioCard({required this.session, super.key});
  final CardioSessionEntity session;

  String _formatDate(DateTime date) {
    final months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activity = CardioActivity.fromId(session.type);
    final accentColor = activity.accent(theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    fontSize: 13,
                  ),
                ),
                Text(
                  _formatDate(session.date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.distance.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  fontFamily: 'Lexend',
                ),
              ),
              Text(
                '${session.calories} kcal',
                style: TextStyle(
                  fontSize: 10,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Elimina sessione',
            onPressed: () => _confirmDelete(context),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await ConfirmDialog.ask(
      context,
      title: 'Elimina sessione',
      message: 'Vuoi eliminare definitivamente questa sessione di cardio?',
    );

    if (!shouldDelete || !context.mounted) return;

    context.read<TrainingBloc>().add(DeleteCardioSessionEvent(session.id));
    AppSnackBar.show(
      context,
      'Sessione cardio eliminata',
      icon: Icons.delete_outline_rounded,
    );
  }
}
