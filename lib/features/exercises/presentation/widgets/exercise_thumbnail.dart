import 'package:flutter/material.dart';
import 'package:gym_corpus/features/exercises/domain/muscle_groups.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Miniatura di un esercizio: la foto quando c'e', altrimenti un
/// segnaposto disegnato.
///
/// Prima ogni schermata se la cavava da sola e lo stesso caso ("non ho
/// una foto") aveva tre rese diverse: il PNG grigio di stock nelle liste
/// esercizi, un'icona manubrio piatta nel picker e nelle card di
/// allenamento, e una terza variante ancora nel dettaglio routine. Il PNG
/// in particolare, ripetuto su ogni riga, si leggeva come "immagine
/// rotta" invece che come "foto non ancora disponibile".
///
/// Qui il segnaposto e' un riquadro tinto sulla regione muscolare
/// dell'esercizio: si legge come una scelta di design, non come un
/// errore. Quando arriveranno le foto vere questo resta comunque il
/// fallback per gli esercizi custom dell'utente, che una foto non
/// l'avranno mai.
class ExerciseThumbnail extends StatelessWidget {
  const ExerciseThumbnail({
    required this.exercise,
    this.size = 60,
    this.borderRadius = 16,
    super.key,
  }) : _expand = false;

  /// Variante che riempie lo spazio disponibile invece di avere un lato
  /// fisso: serve all'hero del dettaglio esercizio.
  const ExerciseThumbnail.expand({required this.exercise, super.key})
    : size = 0,
      borderRadius = 0,
      _expand = true;

  final ExerciseEntity exercise;
  final double size;
  final double borderRadius;
  final bool _expand;

  /// Tinta associata alla regione muscolare. Le quattro tinte vengono
  /// tutte dalla palette del brand: le prime due dal tema, le altre due
  /// sono le costanti gia' usate a mano altrove nell'app (l'arancione
  /// delle intestazioni di sezione) e il ciano del fulmine nel logo.
  static Color accentFor(ExerciseEntity exercise, ColorScheme scheme) {
    switch (muscleRegionFor(exercise.targetMuscle)) {
      case MuscleRegion.spinta:
        return scheme.primary;
      case MuscleRegion.trazione:
        return scheme.tertiary;
      case MuscleRegion.gambe:
        return const Color(0xFFFFAB40);
      case MuscleRegion.core:
        return const Color(0xFF37CBFD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentFor(exercise, theme.colorScheme);
    final placeholder = _Placeholder(
      accent: accent,
      iconSize: _expand ? 72 : size * 0.42,
      surface: theme.colorScheme.surfaceContainerHigh,
    );

    final url = exercise.imageUrl;
    final content = url == null
        ? placeholder
        : Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => placeholder,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return placeholder;
            },
          );

    if (_expand) return content;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: size, height: size, child: content),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.accent,
    required this.iconSize,
    required this.surface,
  });

  final Color accent;
  final double iconSize;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accent.withValues(alpha: 0.22), surface),
            Color.alphaBlend(accent.withValues(alpha: 0.06), surface),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          size: iconSize,
          color: accent.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
