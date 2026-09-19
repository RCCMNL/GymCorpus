import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/profile/domain/services/achievement_catalog.dart';

/// Come si presenta una categoria di trofei: icona e colore.
///
/// Le due funzioni erano copiate identiche in RecordsScreen e nella
/// bacheca dei trofei, e i colori venivano da Material: arancione, teal,
/// viola, giallo. Quattro tinte che non stanno nella tavolozza dell'app
/// e, fra giallo e arancione, due che a schermo erano quasi la stessa.
///
/// Sei categorie, sei tinte della casa, tutte distinte: se due ne
/// condividessero una, il colore smetterebbe di dire di che categoria si
/// tratta.
IconData achievementCategoryIcon(AchievementCategory category) {
  return switch (category) {
    AchievementCategory.consistency => Icons.local_fire_department_rounded,
    AchievementCategory.performance => Icons.fitness_center_rounded,
    AchievementCategory.cardio => Icons.directions_run_rounded,
    AchievementCategory.variety => Icons.auto_awesome_mosaic_rounded,
    AchievementCategory.specialization => Icons.ads_click_rounded,
    AchievementCategory.streak => Icons.bolt_rounded,
  };
}

Color achievementCategoryColor(AchievementCategory category) {
  return switch (category) {
    AchievementCategory.consistency => AppPalette.gold,
    AchievementCategory.performance => AppPalette.periwinkle,
    AchievementCategory.cardio => AppPalette.mint,
    AchievementCategory.variety => AppPalette.blue,
    AchievementCategory.specialization => AppPalette.onSurface,
    AchievementCategory.streak => AppPalette.coral,
  };
}
