import 'package:flutter/material.dart';

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

  static ThemeData get lightTheme => darkTheme; // Defaulting to Dark for that premium feel

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        onPrimary: Color(0xFF00257B),
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
        outline: _outline,
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
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w900,
          color: _primary,
          letterSpacing: -1.0,
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
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          color: _onSurface,
        ),
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
