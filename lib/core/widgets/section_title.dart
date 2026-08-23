import 'package:flutter/material.dart';

/// Etichetta di sezione in maiuscolo, con letter-spacing largo e peso
/// massimo: lo stile usato in tutte le schermate per introdurre un gruppo
/// di contenuti (es. "AUTENTICAZIONE", "PASTI DI OGGI").
///
/// Prima ogni schermata aveva una propria copia privata di questo widget,
/// identica in tre file su sei e leggermente diversa negli altri tre: [color],
/// [letterSpacing], [fontSize] e [withAccentBar] coprono tutte le varianti
/// viste finora senza dover reintrodurre una copia locale.
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.color,
    this.letterSpacing = 1.5,
    this.fontSize,
    this.withAccentBar = false,
  });

  final String title;
  final Color? color;
  final double letterSpacing;
  final double? fontSize;

  /// Se vero, antepone la barretta verticale sfumata usata in
  /// SecurityScreen per marcare visivamente l'inizio della sezione.
  final bool withAccentBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: letterSpacing,
        fontWeight: FontWeight.w900,
        color: color ?? theme.colorScheme.primary,
        fontSize: fontSize,
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
