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

  // Costanti statiche per inizializzazione comoda
  static const light = StitchColors(
    primary: Color(0xFF6200EE),
    secondary: Color(0xFF03DAC6),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFB00020),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFF000000),
    onSurface: Color(0xFF000000),
    onError: Color(0xFFFFFFFF),
  );

  static const dark = StitchColors(
    primary: Color(0xFFBB86FC),
    secondary: Color(0xFF03DAC6),
    background: Color(0xFF121212),
    surface: Color(0xFF121212),
    error: Color(0xFFCF6679),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFFFFFFFF),
    onSurface: Color(0xFFFFFFFF),
    onError: Color(0xFF000000),
  );
}
