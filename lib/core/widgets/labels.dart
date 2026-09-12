import 'package:flutter/material.dart';

/// Che peso ha l'etichetta nella pagina.
///
/// I due toni sostituiscono le tre manopole libere - colore, spaziatura e
/// corpo - con cui ogni schermata si era scelta la propria etichetta: sette
/// spaziature diverse fra 1.1 e 3, sei corpi fra 8 e 12, e nove sfumature
/// di colore.
enum SectionTitleTone {
  /// Il titolo di una sezione della pagina: nel colore del brand.
  primary(1.5),

  /// L'etichetta di servizio sopra un gruppo di campi o di scelte:
  /// smorzata, perche' non deve competere con quello che introduce.
  muted(2);

  const SectionTitleTone(this.letterSpacing);

  final double letterSpacing;
}

/// Etichetta di sezione in maiuscolo, con letter-spacing largo e peso
/// massimo: lo stile usato in tutte le schermate per introdurre un gruppo
/// di contenuti (es. "AUTENTICAZIONE", "PASTI DI OGGI").
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    this.tone = SectionTitleTone.primary,
    this.withAccentBar = false,
    super.key,
  });

  final String title;
  final SectionTitleTone tone;

  /// Se vero, antepone la barretta verticale sfumata che marca l'inizio
  /// delle sezioni in SecurityScreen.
  final bool withAccentBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: tone.letterSpacing,
        fontWeight: FontWeight.w900,
        fontSize: 11,
        color: switch (tone) {
          SectionTitleTone.primary => theme.colorScheme.primary,
          SectionTitleTone.muted => theme.colorScheme.outline,
        },
      ),
    );

    if (!withAccentBar) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        text,
      ],
    );
  }
}

/// L'occhiello: la riga piccola sopra il titolo di una scheda.
///
/// Non introduce una sezione della pagina - quello e' [SectionTitle] - ma
/// dice che cos'e' la scheda sotto cui sta: "PROSSIMO", "RECUPERO",
/// "ROUTINE ATTUALE".
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color, super.key});

  final String text;

  /// L'accento della scheda a cui appartiene, quando ne ha uno: l'arancio
  /// del riquadro consigli, il verde della schermata di fine allenamento.
  /// Il resto - misura, peso, spaziatura - non si sceglie.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 2,
        fontWeight: FontWeight.w900,
        fontSize: 10,
        color: color ?? theme.colorScheme.outline,
      ),
    );
  }
}

/// L'etichetta che dice quale numero si sta guardando.
///
/// Sta accanto al valore che nomina - sopra, sotto o a fianco - e non ha
/// niente da configurare: due statistiche vicine devono leggersi uguali.
class StatLabel extends StatelessWidget {
  const StatLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.w900,
        fontSize: 10,
        color: theme.colorScheme.outline,
      ),
    );
  }
}
