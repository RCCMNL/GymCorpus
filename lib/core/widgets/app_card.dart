import 'package:flutter/material.dart';

/// Quanto e' grande il riquadro.
///
/// Le tre misure sostituiscono i nove raggi - 10, 12, 14, 16, 20, 22, 24,
/// 28 e 32 - che i riquadri dell'app si erano scelti uno per uno, insieme
/// a nove sfumature di fondo e sette alfa di bordo. Restano tre perche' una
/// cella di input e un pannello a tutta larghezza sono davvero cose
/// diverse: quello che non doveva esistere e' la scala continua fra le due.
enum AppCardSize {
  /// Riquadri piccoli in linea: celle, campi, badge di misura: 16.
  tight(16),

  /// La scheda normale dell'app: 24.
  card(24),

  /// Il pannello grande che contiene altre schede: 32.
  panel(32);

  const AppCardSize(this.radius);

  final double radius;
}

/// Il riquadro dell'app: fondo, angoli e il filo di bordo che lo stacca.
///
/// Chi lo usa sceglie la misura e i bordi interni. Fondo e bordo non si
/// scelgono: due schede vicine devono leggersi come la stessa cosa.
///
/// Restano fuori i riquadri che non sono schede: quelli traslucidi sopra
/// la mappa, quelli con il bordo che cambia per dire qualcosa (il giorno
/// di oggi, un trofeo conquistato) e le pillole tinte di un accento, che
/// usano [TintedSurface].
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.size = AppCardSize.card,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.clipBehavior = Clip.none,
    super.key,
  });

  final Widget child;
  final AppCardSize size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Misure imposte dal layout, non dall'aspetto: la scheda che deve
  /// riempire la riga, la cella larga quanto la sua colonna.
  final double? width;
  final double? height;

  /// Serve quando il contenuto deborda dagli angoli tondi: un'immagine,
  /// una barra di avanzamento a tutta larghezza.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(size.radius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }
}

/// Il riempimento e il bordo di una pillola tinta di un accento.
///
/// Il colore e' una scelta vera - il blu del brand, il verde del cardio,
/// il rosso di una difficolta' alta - ma le trasparenze no: andavano da
/// 0.05 a 0.15 per il fondo e da 0.10 a 0.40 per il bordo, un valore per
/// file. Adesso sono due sole.
extension TintedSurface on Color {
  /// Il fondo di una pillola tinta.
  Color get tintedFill => withValues(alpha: 0.1);

  /// Il filo di bordo della stessa pillola.
  Color get tintedBorder => withValues(alpha: 0.2);
}
