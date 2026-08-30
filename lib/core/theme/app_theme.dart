import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/stitch_colors.dart';
import 'package:gym_corpus/core/theme/stitch_spacing.dart';

class AppTheme {
  // Stitch Design System - Deep Navy & Neon Blue
  static const Color _background = Color(0xFF08082F);
  static const Color _primary = Color(0xFF94AAFF);
  static const Color _onSurface = Color(0xFFE5E3FF);
  static const Color _surfaceContainer = Color(0xFF131342);
  static const Color _surfaceContainerHigh = Color(0xFF18194B);
  static const Color _outline = Color(0xFF71729D);
  static const Color _accent = Color(0xFF3367FF);
  static const Color _tertiary = Color(0xFFB5FFC2); // Mint Accent
  static const Color _onPrimary = Color(0xFF00257B);
  static const Color _error = Color(0xFFFF8A80);

  // Raggi condivisi: i valori sono quelli gia' usati a mano nei widget
  // curati, promossi a costanti cosi' che i widget lasciati al default
  // ereditino la stessa forma invece di quella di fabbrica di Material.
  static const double _radiusField = 16;
  static const double _radiusButton = 18;
  static const double _radiusDialog = 24;
  static const double _radiusSnackBar = 20;

  static ThemeData get lightTheme =>
      darkTheme; // Defaulting to Dark for that premium feel

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      extensions: const [StitchColors.dark, StitchSpacing.standard],
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
          borderRadius: BorderRadius.circular(16),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: BorderSide(color: _outline.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        errorStyle: const TextStyle(fontFamily: 'Inter', color: _error),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusDialog),
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

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _surfaceContainerHigh,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusSnackBar),
        ),
        contentTextStyle: const TextStyle(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primary,
        circularTrackColor: _primary.withValues(alpha: 0.12),
        linearTrackColor: _primary.withValues(alpha: 0.12),
      ),

      textTheme: const TextTheme(
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
        titleLarge: TextStyle(
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
