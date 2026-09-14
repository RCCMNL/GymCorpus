import 'package:flutter/material.dart';

/// Quanto e' importante il titolo.
///
/// Le tre misure sostituiscono i cinque corpi diversi - 22, 24, 28, 32 e il
/// valore di default del tema - che le schermate si erano scelte una per
/// una.
enum GradientTitleScale {
  /// Titoli di barra, sopra un sottotitolo: 22.
  compact(22),

  /// Il titolo normale di una schermata: 28.
  screen(28),

  /// L'apertura di una schermata che non ha barra: 32.
  hero(32);

  const GradientTitleScale(this.fontSize);

  final double fontSize;
}

/// Dipinge con la sfumatura del brand qualunque cosa gli si dia.
///
/// Serve per le icone e per il logo: il testo ha [GradientTitle].
class GradientMask extends StatelessWidget {
  const GradientMask({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
      ).createShader(bounds),
      child: child,
    );
  }
}

/// Il titolo sfumato che apre le schermate dell'app.
///
/// Le stesse quindici righe di `ShaderMask` con dentro un `Text` bianco in
/// Lexend nero stavano in dodici schermate. Il bianco non e' una scelta di
/// colore: e' quello che lascia passare la sfumatura.
class GradientTitle extends StatelessWidget {
  const GradientTitle(
    this.text, {
    this.scale = GradientTitleScale.screen,
    this.style,
    this.maxLines,
    super.key,
  });

  final String text;
  final GradientTitleScale scale;

  /// Ritocchi sopra lo stile di base, per i casi che ne hanno davvero
  /// bisogno: il corsivo del marchio, l'interlinea di un titolo su due
  /// righe.
  final TextStyle? style;

  /// Oltre questo numero di righe il titolo viene troncato.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = (theme.textTheme.headlineMedium ?? const TextStyle()).copyWith(
      fontFamily: 'Lexend',
      fontWeight: FontWeight.w900,
      color: Colors.white,
      fontSize: scale.fontSize,
    );

    return GradientMask(
      child: Text(
        text,
        style: base.merge(style),
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
      ),
    );
  }
}
