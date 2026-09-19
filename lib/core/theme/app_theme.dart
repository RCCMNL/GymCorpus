import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_page_transition.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// Le tinte dell'app, in un posto solo.
///
/// Prima meta' dei colori arrivava dalla tavolozza di fabbrica di
/// Material: `Colors.orangeAccent` e `Colors.deepOrange` e `Colors.amber`
/// e `Colors.yellowAccent`, quattro gialli diversi, a volte sulla stessa
/// schermata; `Colors.greenAccent.shade400` accanto al menta del tema,
/// abbastanza simile da sembrare un errore di stampa. Sono tinte pensate
/// per il bianco, e su un fondo navy si vedono per quello che sono.
///
/// Cinque tinte, ognuna con un mestiere. Dove c'e' un [BuildContext] si
/// passa comunque da `theme.colorScheme`: queste costanti servono dove
/// un colore va scelto senza contesto (una `switch` su una categoria,
/// una costante di modulo).
abstract final class AppPalette {
  /// Il fondo di tutto: navy profondo.
  static const background = Color(0xFF08082F);

  /// La voce normale dell'app.
  static const periwinkle = Color(0xFF94AAFF);

  /// Il blu pieno: azioni che spingono, stati attivi.
  static const blue = Color(0xFF3367FF);

  /// Il verde: quello che e' andato bene, i progressi, i traguardi.
  static const mint = Color(0xFFB5FFC2);

  /// L'oro: energia, primati, suggerimenti e avvisi. Uno solo, non
  /// cinque: due gialli che non combaciano si notano subito.
  static const gold = Color(0xFFFFC46B);

  /// Il rosso: errori e azioni che distruggono qualcosa.
  static const coral = Color(0xFFFF8A80);

  /// Inchiostro sulle superfici scure.
  static const onSurface = Color(0xFFE5E3FF);

  /// Inchiostro sull'oro e sul menta, che sono chiari.
  static const onLight = Color(0xFF3A2200);
}

class AppTheme {
  // Stitch Design System - Deep Navy & Neon Blue
  static const Color _background = AppPalette.background;
  static const Color _primary = AppPalette.periwinkle;
  static const Color _onSurface = AppPalette.onSurface;
  static const Color _surfaceContainer = Color(0xFF131342);
  static const Color _surfaceContainerHigh = Color(0xFF18194B);
  static const Color _outline = Color(0xFF71729D);
  static const Color _accent = AppPalette.blue;
  static const Color _tertiary = AppPalette.mint;
  static const Color _onPrimary = Color(0xFF00257B);
  static const Color _error = AppPalette.coral;

  /// Ambra della palette: e' l'avviso, quello che non e' ancora un errore.
  static const Color warning = AppPalette.gold;
  static const Color onWarning = AppPalette.onLight;

  static ThemeData get lightTheme =>
      darkTheme; // Defaulting to Dark for that premium feel

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      pageTransitionsTheme: appPageTransitionsTheme,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        onPrimary: _onPrimary,
        primaryContainer: Color(0xFF3738A1),
        onPrimaryContainer: _onSurface,
        secondary: _accent,
        onSecondary: Colors.white,
        tertiary: _tertiary,
        onTertiary: Color(0xFF00391C),
        surface: _background,
        onSurface: _onSurface,
        surfaceContainer: _surfaceContainer,
        surfaceContainerHigh: _surfaceContainerHigh,
        surfaceContainerHighest: Color(0xFF333544),
        surfaceContainerLowest: Color(0xFF0C0E13),
        outline: _outline,
        error: _error,
        onError: Color(0xFF3E0100),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: _primary,
        ),
        iconTheme: IconThemeData(color: _primary),
      ),
      cardTheme: CardThemeData(
        color: _surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
          side: BorderSide(color: _primary.withValues(alpha: 0.05)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _background.withValues(alpha: 0.9),
        indicatorColor: _primary.withValues(alpha: 0.1),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primary);
          }
          return IconThemeData(color: _onSurface.withValues(alpha: 0.5));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          const style = TextStyle(
            fontFamily: 'Lexend',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          );
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(color: _primary);
          }
          return style.copyWith(color: _onSurface.withValues(alpha: 0.5));
        }),
      ),

      // Un campo senza `decoration` esplicita deve gia' sembrare parte
      // dell'app: riempito, angoli morbidi, bordo di fuoco lavanda. I campi
      // che vivono dentro un Container gia' decorato passano `filled: false`
      // per non disegnare un secondo riempimento squadrato.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          color: _outline.withValues(alpha: 0.7),
        ),
        labelStyle: const TextStyle(fontFamily: 'Inter', color: _outline),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: _primary,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: _outline.withValues(alpha: 0.12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: _error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: _error, width: 1.5),
        ),
        errorStyle: const TextStyle(fontFamily: 'Inter', color: _error),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xl,
          side: BorderSide(color: _primary.withValues(alpha: 0.12)),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: _onSurface,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.5,
          color: _onSurface,
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _surfaceContainerHigh,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: _onSurface,
        ),
        actionTextColor: _tertiary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          textStyle: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          textStyle: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          side: BorderSide(color: _primary.withValues(alpha: 0.35)),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          textStyle: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return _outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary.withValues(alpha: 0.28);
          }
          return _surfaceContainerHigh;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return _outline.withValues(alpha: 0.4);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(_onPrimary),
        side: BorderSide(color: _outline.withValues(alpha: 0.6), width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xs),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primary,
        circularTrackColor: _primary.withValues(alpha: 0.12),
        linearTrackColor: _primary.withValues(alpha: 0.12),
      ),

      // La scala e' completa di proposito: uno stile lasciato fuori non
      // da' errore, Flutter lo riempie con la tipografia di Material e chi
      // lo usa scrive nel font di sistema. Restano fuori le dimensioni,
      // che continuano ad arrivare da Material: qui si decide solo di che
      // famiglia, peso e colore e' il testo.
      //
      // Lexend porta i titoli e le etichette (e' la voce del marchio),
      // Inter il testo che si legge a paragrafi.
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          color: _onSurface,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          color: _onSurface,
          letterSpacing: -1,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          color: _onSurface,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          color: _primary,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          color: _onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          color: _onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w600,
          color: _onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w600,
          color: _onSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w600,
          color: _onSurface,
        ),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: _onSurface),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          color: _onSurface,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          color: _onSurface,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: _onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: _onSurface,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 10,
          color: _outline,
        ),
      ),
    );
  }
}
