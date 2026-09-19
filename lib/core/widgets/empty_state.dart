import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';

/// Quello che c'e' quando non c'e' ancora niente.
///
/// Dodici schermate se lo scrivevano per conto loro, ed erano dodici
/// cose diverse: un cerchio disegnato a mano da 80 punti con l'icona al
/// cinquanta per cento, una pastiglia tinta, una neutra; pesi w800 e
/// w900; il messaggio ora in bodyMedium ora in bodySmall, con
/// interlinea 1.5 o senza. E' anche il momento in cui l'app parla di
/// piu' a chi ha appena installato, che di stati vuoti ne vede piu' di
/// chiunque altro.
///
/// Il testo resta libero perche' e' l'unica cosa che cambia davvero: che
/// cosa manca, e che cosa fare per riempirlo.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;

  /// Che cosa non c'e'. Una riga, senza punto finale.
  final String title;

  /// Perche' non c'e', o come farcelo arrivare.
  final String message;

  /// Il gesto che riempie il vuoto, quando ce n'e' uno solo ovvio.
  /// Senza, lo stato vuoto si limita a spiegare.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconBadge(icon, size: IconBadgeSize.large, circle: true),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
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
            height: 1.5,
          ),
        ),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    );
  }
}

/// Lo stesso messaggio, dentro un riquadro.
///
/// Serve dove lo stato vuoto e' una sezione di una pagina che scorre -
/// lo storico peso, le misure - e deve staccarsi da quello che ha
/// sopra e sotto. A schermo pieno il riquadro sarebbe di troppo: li' si
/// usa [EmptyState] nudo.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: EmptyState(
        icon: icon,
        title: title,
        message: message,
        action: action,
      ),
    );
  }
}
