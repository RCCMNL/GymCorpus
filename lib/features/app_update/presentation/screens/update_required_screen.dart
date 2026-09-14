import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/services/external_links.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_info.dart';

/// Schermata mostrata quando la versione installata e' sotto la soglia
/// minima supportata: senza pulsante indietro, ne' altra via d'uscita,
/// perche' a quella versione l'app non e' piu' garantita funzionare
/// correttamente (rotture di compatibilita', fix critici).
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({required this.info, super.key});

  final AppUpdateInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.system_update_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aggiornamento necessario',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Questa versione di GymCorpus non e piu supportata. '
                    'Aggiorna alla ${info.latestVersionName} per continuare.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (info.changelog.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      info.changelog,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => GetIt.I<ExternalLinks>().open(info.apkUrl),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Scarica aggiornamento'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
