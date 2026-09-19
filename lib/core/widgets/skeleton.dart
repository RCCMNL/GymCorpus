import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// L'attesa, disegnata come la cosa che sta arrivando.
///
/// Ventidue schermate mostravano la stessa rotella al centro dello
/// schermo vuoto: dice "sto caricando" e nient'altro. Un elenco di
/// blocchi della forma giusta dice anche quanto starai ad aspettare e
/// che cosa comparira', e quando i dati arrivano la pagina non salta:
/// era gia' disposta cosi'.
///
/// [Shimmer] fa passare un riflesso sopra tutto quello che contiene, con
/// un'animazione sola: dentro ci vanno i blocchi, che sono forme ferme.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  /// Dove si trova il riflesso, da -1 (prima del bordo sinistro) a 2
  /// (oltre il destro). Esposto per i test: e' l'unica prova osservabile
  /// che l'animazione gira davvero.
  @visibleForTesting
  double get debugPosition => _controller.value * 3 - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = theme.colorScheme.onSurface.withValues(alpha: 0.08);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = debugPosition;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.transparent, highlight, Colors.transparent],
              stops: [
                (position - 0.3).clamp(0.0, 1.0),
                position.clamp(0.0, 1.0),
                (position + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Un blocco al posto di un pezzo di contenuto che non c'e' ancora.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width = double.infinity,
    this.height = 12,
    this.radius = AppRadius.xs,
    super.key,
  });

  final double width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: radius,
      ),
    );
  }
}

/// Una riga finta: il quadrato dell'immagine, il titolo, il sottotitolo.
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({this.hasLeading = true, super.key});

  /// Il quadrato a sinistra: le righe senza immagine non ce l'hanno.
  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (hasLeading) ...[
            const SkeletonBox(width: 56, height: 56, radius: AppRadius.md),
            const SizedBox(width: 16),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14),
                SizedBox(height: 8),
                // Il sottotitolo e' piu' corto del titolo, come nelle
                // righe vere: se fossero uguali si vedrebbe che e' finto.
                FractionallySizedBox(
                  widthFactor: 0.55,
                  child: SkeletonBox(height: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un elenco che sta arrivando.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    this.rows = 5,
    this.hasLeading = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    super.key,
  });

  final int rows;
  final bool hasLeading;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < rows; i++) SkeletonTile(hasLeading: hasLeading),
          ],
        ),
      ),
    );
  }
}
