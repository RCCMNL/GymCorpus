import 'package:flutter/material.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';

/// Colori del calendario ciclo, raccolti in un punto solo.
///
/// Restano fuori dal ColorScheme perche' appartengono a questa sola
/// funzionalita': erano gia' sparsi tra schermata e voce di menu.
abstract final class CyclePalette {
  static const period = Color(0xFFFF4B72);
  static const follicular = Color(0xFFFF8FA3);
  static const ovulatory = Color(0xFFFFAEBC);
  static const luteal = Color(0xFFF0A8D0);
}

/// Come si presenta una fase: nome, colore, icona e consiglio di allenamento.
class CyclePhaseInfo {
  const CyclePhaseInfo({
    required this.name,
    required this.color,
    required this.advice,
    required this.icon,
  });

  factory CyclePhaseInfo.of(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return const CyclePhaseInfo(
          name: 'Fase Mestruale',
          color: CyclePalette.period,
          advice:
              'Ottimo per il recupero attivo, yoga dolce e camminate. '
              'Ascolta il tuo corpo.',
          icon: Icons.water_drop_rounded,
        );
      case CyclePhase.follicular:
        return const CyclePhaseInfo(
          name: 'Fase Follicolare',
          color: CyclePalette.follicular,
          advice:
              'Perfetto per aumentare i carichi, HIIT e allenamenti ad '
              'alta intensita.',
          icon: Icons.bolt_rounded,
        );
      case CyclePhase.ovulatory:
        return const CyclePhaseInfo(
          name: 'Fase Ovulatoria',
          color: CyclePalette.ovulatory,
          advice:
              'Picco di energia: e il momento giusto per tentare un '
              'massimale o una sfida impegnativa.',
          icon: Icons.local_fire_department_rounded,
        );
      case CyclePhase.luteal:
        return const CyclePhaseInfo(
          name: 'Fase Luteale',
          color: CyclePalette.luteal,
          advice:
              "L'energia inizia a calare. Concentrati su forza a media "
              'intensita o pilates.',
          icon: Icons.self_improvement_rounded,
        );
    }
  }

  final String name;
  final Color color;
  final String advice;
  final IconData icon;
}
