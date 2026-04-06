import 'package:flutter/material.dart';

class StitchSpacing extends ThemeExtension<StitchSpacing> {
  const StitchSpacing({
    required this.tiny,
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
  });

  final double tiny;
  final double small;
  final double medium;
  final double large;
  final double extraLarge;

  @override
  StitchSpacing copyWith({
    double? tiny,
    double? small,
    double? medium,
    double? large,
    double? extraLarge,
  }) {
    return StitchSpacing(
      tiny: tiny ?? this.tiny,
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
    );
  }

  @override
  StitchSpacing lerp(ThemeExtension<StitchSpacing>? other, double t) {
    if (other is! StitchSpacing) {
      return this;
    }
    return StitchSpacing(
      tiny: tiny + (other.tiny - tiny) * t,
      small: small + (other.small - small) * t,
      medium: medium + (other.medium - medium) * t,
      large: large + (other.large - large) * t,
      extraLarge: extraLarge + (other.extraLarge - extraLarge) * t,
    );
  }

  // Valori standard di base
  static const standard = StitchSpacing(
    tiny: 4,
    small: 8,
    medium: 16,
    large: 24,
    extraLarge: 32,
  );
}
