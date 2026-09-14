import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/services/external_links.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Il rimando al video di riferimento di un esercizio.
///
/// Il video non si guarda dentro l'app: [ExerciseEntity.referenceVideoUrl]
/// punta a un filmato che sta gia' da qualche parte, e qui si apre dove lo
/// si guarda di solito. Ospitare e riprodurre centocinquantasette clip
/// costerebbe molto piu' di quanto valga, e il campo resta li' se un
/// giorno la scelta cambia.
///
/// Senza un indirizzo non occupa spazio: gli esercizi che un video non ce
/// l'hanno - oggi tutti - non devono mostrare un pulsante spento.
class ExerciseVideoLink extends StatelessWidget {
  const ExerciseVideoLink({required this.exercise, super.key});

  final ExerciseEntity exercise;

  Future<void> _open(BuildContext context, String url) async {
    final aperto = await GetIt.I<ExternalLinks>().open(url);
    if (aperto || !context.mounted) return;

    AppSnackBar.showWarning(context, 'Non riesco ad aprire il video');
  }

  @override
  Widget build(BuildContext context) {
    final url = exercise.referenceVideoUrl;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _open(context, url),
      borderRadius: BorderRadius.circular(AppCardSize.card.radius),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconBadge(
              Icons.play_arrow_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('VIDEO DI RIFERIMENTO'),
                  const SizedBox(height: 4),
                  Text(
                    'Guarda il video',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 20,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
