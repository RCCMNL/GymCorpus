import 'package:flutter/material.dart';

/// Come una schermata entra e come quella sotto se ne va.
///
/// Prima era quella di fabbrica del sistema: su Android lo zoom di
/// Material, su iOS lo scorrimento di Cupertino. Due app diverse a
/// seconda del telefono, e nessuna delle due dice da dove arrivi quello
/// che stai guardando.
///
/// Qui la nuova schermata entra da destra e quella vecchia arretra di
/// poco verso sinistra, entrambe con una dissolvenza: il movimento e'
/// breve, e chi torna indietro lo vede rifare al contrario.
class AppPageTransition extends PageTransitionsBuilder {
  const AppPageTransition();

  /// Quanto arretra la schermata che esce, in frazione di larghezza.
  /// Un quarto: abbastanza da far capire che e' rimasta li' sotto, non
  /// cosi' tanto da sembrare che se ne vada anche lei.
  static const _outgoingShift = 0.25;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // A riposo `secondaryAnimation` vale 0: li' la pagina deve stare
    // esattamente al suo posto, e arretrare solo mentre un'altra le
    // sale sopra. Con il tween al contrario resterebbe spostata per
    // sempre - e non si vedrebbe, perche' si sposta tutta insieme.
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-_outgoingShift, 0),
      ).animate(outgoing),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(incoming),
        child: FadeTransition(opacity: incoming, child: child),
      ),
    );
  }
}

/// Lo stesso movimento su tutte le piattaforme.
const appPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: AppPageTransition(),
    TargetPlatform.iOS: AppPageTransition(),
    TargetPlatform.macOS: AppPageTransition(),
    TargetPlatform.windows: AppPageTransition(),
    TargetPlatform.linux: AppPageTransition(),
    TargetPlatform.fuchsia: AppPageTransition(),
  },
);
