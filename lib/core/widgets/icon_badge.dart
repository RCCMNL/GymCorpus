import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';

/// Quanto e' grande la pastiglia che regge l'icona.
///
/// Le tre misure sostituiscono i sei bordi interni - 4, 8, 10, 12, 20 e 24 -
/// e le altrettante misure d'icona che ogni schermata si era scelta.
enum IconBadgeSize {
  /// Accanto al titolo di una riga in elenco.
  small(padding: 8, icon: 18, radius: 12),

  /// In testa a una sezione o a una scheda.
  medium(padding: 12, icon: 22, radius: 16),

  /// L'icona grande di uno schermo vuoto.
  large(padding: 24, icon: 48, radius: 24);

  const IconBadgeSize({
    required this.padding,
    required this.icon,
    required this.radius,
  });

  final double padding;
  final double icon;
  final double radius;
}

/// Un'icona dentro la sua pastiglia tinta.
///
/// Con un [color] la pastiglia si tinge di quell'accento - lo stesso
/// `tintedFill` delle altre pillole - e l'icona lo prende pieno. Senza,
/// resta neutra. Bordi interni e misura dell'icona non si scelgono: le
/// decide [size], perche' erano l'unica cosa che variava davvero da un
/// file all'altro, e senza motivo.
class IconBadge extends StatelessWidget {
  const IconBadge(
    this.icon, {
    this.color,
    this.size = IconBadgeSize.medium,
    this.circle = false,
    super.key,
  });

  final IconData icon;

  /// L'accento a cui l'icona appartiene: il verde dei passi, il colore
  /// dell'attivita' cardio. Senza, la pastiglia e' neutra.
  final Color? color;

  final IconBadgeSize size;

  /// Tonda invece che a angoli arrotondati.
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color;

    return Container(
      padding: EdgeInsets.all(size.padding),
      decoration: BoxDecoration(
        color: color?.tintedFill ?? theme.colorScheme.surfaceContainerHigh,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size.radius),
      ),
      child: Icon(
        icon,
        size: size.icon,
        color: color ?? theme.colorScheme.outline,
      ),
    );
  }
}
