import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/confirm_dialog.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/detailed_cardio_card.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';

/// Gruppo di sessioni cardio (es. "RECENTI" o "PRECEDENTI") in
/// CardioHistoryScreen, con titolo, sottotitolo e le relative card.
class CardioHistoryGroup extends StatelessWidget {
  const CardioHistoryGroup({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.sessions,
    super.key,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final List<CardioSessionEntity> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: AppRadius.pill,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sessions.map(
            (session) => DismissibleCardioCard(
              session: session,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card di sessione cardio eliminabile con swipe, con conferma prima della
/// cancellazione definitiva.
class DismissibleCardioCard extends StatelessWidget {
  const DismissibleCardioCard({
    required this.session,
    required this.accentColor,
    super.key,
  });

  final CardioSessionEntity session;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('cardio_${session.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => ConfirmDialog.ask(
        context,
        title: 'Elimina sessione',
        message:
            'Sei sicuro di voler eliminare definitivamente questa '
            'sessione di cardio?',
      ),
      onDismissed: (direction) {
        context.read<TrainingBloc>().add(DeleteCardioSessionEvent(session.id));
        AppSnackBar.show(
          context,
          'Sessione eliminata',
          icon: Icons.delete_outline_rounded,
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppPalette.coral.tintedFill,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppPalette.coral.tintedBorder),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppPalette.coral,
        ),
      ),
      child: DetailedCardioCard(
        session: session,
        accentColor: accentColor,
        onTap: () =>
            context.push('/analytics/cardio-history/session', extra: session),
      ),
    );
  }
}
