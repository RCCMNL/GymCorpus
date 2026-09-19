import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Riga di statistiche fisiche rapide (peso, altezza, eta') nella card
/// utente della ProfileScreen. Se mancano dati apre la modifica profilo.
class PhysicalStatsRow extends StatelessWidget {
  const PhysicalStatsRow({
    required this.user,
    required this.trainingState,
    super.key,
  });

  final UserEntity? user;
  final TrainingState trainingState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = this.user;
    if (user == null) return const SizedBox.shrink();

    final state = trainingState;
    final settings = state is TrainingLoaded
        ? state.settings
        : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';
    final latestWeight =
        state is TrainingLoaded && state.bodyWeightLogs.isNotEmpty
        ? state.bodyWeightLogs.first.weight
        : user.weight;

    var weightLabel = '? kg';
    if (latestWeight != null) {
      final value = isImperial
          ? UnitConverter.kgToLb(latestWeight)
          : latestWeight;
      weightLabel = '${value.toStringAsFixed(1)}${isImperial ? 'lb' : 'kg'}';
    }

    var heightLabel = '? cm';
    final heightValue = user.height;
    if (heightValue != null) {
      final value = isImperial
          ? UnitConverter.cmToInch(heightValue)
          : heightValue;
      heightLabel = '${value.toInt()}${isImperial ? 'in' : 'cm'}';
    }

    var age = '? anni';
    if (user.birthDate != null) {
      final now = DateTime.now();
      final birthDate = user.birthDate!;
      var calculatedAge = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        calculatedAge--;
      }
      age = '$calculatedAge anni';
    }

    final hasMissingData =
        latestWeight == null || user.height == null || user.birthDate == null;

    return GestureDetector(
      onTap: hasMissingData ? () => context.push('/profile/edit') : null,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatItem(
            icon: Icons.monitor_weight_outlined,
            value: weightLabel,
            theme: theme,
          ),
          _StatItem(icon: Icons.height, value: heightLabel, theme: theme),
          _StatItem(icon: Icons.cake_outlined, value: age, theme: theme),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      size: AppCardSize.tight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: icon == Icons.monitor_weight_outlined
                ? theme.colorScheme.primary
                : (icon == Icons.height
                      ? theme.colorScheme.tertiary
                      : AppPalette.gold),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'Lexend',
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
