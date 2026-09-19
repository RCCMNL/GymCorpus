import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Indice di massa corporea calcolato dal peso piu' recente (log
/// giornaliero se presente, altrimenti il peso salvato nel profilo)
/// e dall'altezza del profilo.
class BMICard extends StatelessWidget {
  const BMICard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainingState = context.watch<TrainingBloc>().state;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        double? bmi;
        var category = 'N/A';
        var categoryColor = theme.colorScheme.outline;

        final user = state.maybeWhen(
          authenticated: (u, _) => u,
          orElse: () => null,
        );

        final latestWeight =
            trainingState is TrainingLoaded &&
                trainingState.bodyWeightLogs.isNotEmpty
            ? trainingState.bodyWeightLogs.first.weight
            : user?.weight;

        if (user != null && latestWeight != null && user.height != null) {
          final hMetri = user.height! / 100;
          final calculatedBmi = latestWeight / (hMetri * hMetri);
          bmi = calculatedBmi;

          if (calculatedBmi < 18.5) {
            category = 'UNDERWEIGHT';
            categoryColor = AppPalette.blue;
          } else if (calculatedBmi < 25) {
            category = 'NORMAL';
            categoryColor = theme.colorScheme.tertiary;
          } else if (calculatedBmi < 30) {
            category = 'OVERWEIGHT';
            categoryColor = AppPalette.gold;
          } else {
            category = 'OBESE';
            categoryColor = AppPalette.coral;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainer,
              ],
            ),
            borderRadius: AppRadius.lg,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icona e titolo cedono spazio al valore, che e' il dato
              // per cui si guarda questa scheda.
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Icon(Icons.person_search, color: categoryColor),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Indice BMI',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'BODY MASS INDEX',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bmi != null ? bmi.toStringAsFixed(1) : '--',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: categoryColor,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
