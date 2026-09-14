import 'package:flutter/material.dart';

class StitchColors extends ThemeExtension<StitchColors> {
  const StitchColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.onError,
  });

  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final Color onError;

  @override
  StitchColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? error,
    Color? onPrimary,
    Color? onSecondary,
    Color? onBackground,
    Color? onSurface,
    Color? onError,
  }) {
    return StitchColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onError: onError ?? this.onError,
    );
  }

  @override
  StitchColors lerp(ThemeExtension<StitchColors>? other, double t) {
    if (other is! StitchColors) {
      return this;
    }
    return StitchColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      error: Color.lerp(error, other.error, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }

  // Costanti statiche per inizializzazione comoda. I valori rispecchiano
  // la palette Stitch dichiarata in AppTheme: questa estensione viene
  // registrata nel tema, quindi tenerla sui colori demo di Flutter
  // significherebbe servire un viola/grigio estraneo al brand al primo
  // widget che la legge.
  static const light = StitchColors(
    primary: Color(0xFF94AAFF),
    secondary: Color(0xFF3367FF),
    background: Color(0xFF08082F),
    surface: Color(0xFF131342),
    error: Color(0xFFFF8A80),
    onPrimary: Color(0xFF00257B),
    onSecondary: Color(0xFFFFFFFF),
    onBackground: Color(0xFFE5E3FF),
    onSurface: Color(0xFFE5E3FF),
    onError: Color(0xFF3E0100),
  );

  static const dark = StitchColors(
    primary: Color(0xFF94AAFF),
    secondary: Color(0xFF3367FF),
    background: Color(0xFF08082F),
    surface: Color(0xFF131342),
    error: Color(0xFFFF8A80),
    onPrimary: Color(0xFF00257B),
    onSecondary: Color(0xFFFFFFFF),
    onBackground: Color(0xFFE5E3FF),
    onSurface: Color(0xFFE5E3FF),
    onError: Color(0xFF3E0100),
  );
}
