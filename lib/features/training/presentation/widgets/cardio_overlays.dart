import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_location_issue.dart';

/// Overlay a schermo intero mostrato mentre si cerca il segnale GPS prima
/// di poter avviare una sessione cardio.
class GpsSearchingOverlay extends StatelessWidget {
  const GpsSearchingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'RICERCA SEGNALE GPS...',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Resta all'aperto per una migliore precisione",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay mostrato quando una sessione all'aperto non puo' partire perche'
/// manca la posizione.
///
/// Prima di questo la schermata restava sulla ricerca del segnale per
/// sempre: niente spiegazione, niente pulsante di avvio, nessuna via
/// d'uscita che non fosse il tasto indietro.
class GpsUnavailableOverlay extends StatelessWidget {
  const GpsUnavailableOverlay({
    required this.issue,
    required this.onRetry,
    super.key,
  });

  final CardioLocationIssue issue;
  final VoidCallback onRetry;

  String get _title {
    switch (issue) {
      case CardioLocationIssue.serviceDisabled:
        return 'Attiva la localizzazione del telefono';
      case CardioLocationIssue.permissionDenied:
      case CardioLocationIssue.permissionDeniedForever:
        return 'Serve il permesso di accedere alla posizione';
    }
  }

  String get _explanation {
    switch (issue) {
      case CardioLocationIssue.serviceDisabled:
        return 'Senza posizione non si puo tracciare il percorso. '
            'Accendi il GPS e riprova, oppure registra la sessione a mano '
            'quando hai finito.';
      case CardioLocationIssue.permissionDenied:
        return 'Concedi il permesso a GymCorpus e riprova, oppure registra '
            'la sessione a mano quando hai finito.';
      case CardioLocationIssue.permissionDeniedForever:
        return 'Il permesso e stato negato in modo definitivo: puoi '
            'riattivarlo dalle impostazioni del telefono, oppure registrare '
            'la sessione a mano quando hai finito.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_disabled_rounded,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _explanation,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: onRetry,
                child: const Text(
                  'RIPROVA',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Countdown a schermo intero (3-2-1-VIA!) prima dell'avvio del tracking.
class CountdownOverlay extends StatelessWidget {
  const CountdownOverlay({required this.countdown, super.key});

  final int countdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.primary.withValues(alpha: 0.9),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            countdown > 0 ? '$countdown' : 'VIA!',
            key: ValueKey<int>(countdown),
            style: const TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay mostrato quando l'utente mette in pausa manualmente la sessione.
class ManualPauseOverlay extends StatelessWidget {
  const ManualPauseOverlay({required this.onResume, super.key});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_filled_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'SESSIONE IN PAUSA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('RIPRENDI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.xxl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay mostrato quando il tracker rileva automaticamente una fermata
/// prolungata e mette in pausa la sessione.
class AutoPauseOverlay extends StatelessWidget {
  const AutoPauseOverlay({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onDismiss,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: ColoredBox(
          color: theme.colorScheme.surface.withValues(alpha: 0.4),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: AppRadius.xxl,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconBadge(
                    Icons.motion_photos_paused_rounded,
                    color: theme.colorScheme.primary,
                    size: IconBadgeSize.large,
                    circle: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'IN PAUSA',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rilevato stop.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: AppRadius.lg,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'TOCCA PER RIPRENDERE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
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

/// Avviso comparso a meta' schermo quando si completa un chilometro o si
/// raggiunge l'obiettivo di sessione.
///
/// Accompagna la vibrazione: durante una corsa il telefono e' spesso in
/// tasca o al braccio, e il solo aggiornamento dei numeri passerebbe
/// inosservato.
class CardioMilestoneBanner extends StatelessWidget {
  const CardioMilestoneBanner({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = subtitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
          ),
          if (detail != null)
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }
}
