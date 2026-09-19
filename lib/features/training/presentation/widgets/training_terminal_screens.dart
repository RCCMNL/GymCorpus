import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/empty_state.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

/// Schermata mostrata al termine di una sessione di allenamento, con tutti
/// gli esercizi completati.
class WorkoutCompletedScreen extends StatelessWidget {
  const WorkoutCompletedScreen({required this.routineTitle, super.key});

  final String routineTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(
        // Scorrevole: su uno schermo basso, o col testo ingrandito, il
        // contenuto non ci stava e veniva tagliato in fondo.
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8DE8C7).withValues(alpha: 0.25),
                        const Color(0xFF8DE8C7).withValues(alpha: 0.05),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8DE8C7).withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFF8DE8C7),
                    size: 56,
                  ),
                ),
                const SizedBox(height: 32),
                const Eyebrow('ALLENAMENTO', color: Color(0xFF8DE8C7)),
                const SizedBox(height: 4),
                Text(
                  'COMPLETATO!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    color: const Color(0xFF8DE8C7),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ottimo lavoro! Hai completato tutti gli esercizi.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Text(
                    routineTitle.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: AppRadius.lg,
                      gradient: LinearGradient(
                        colors: [Color(0xFF3367FF), Color(0xFF94AAFF)],
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/training'),
                        borderRadius: AppRadius.lg,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: Text(
                              'TORNA ALLA DASHBOARD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                fontSize: 14,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Schermata mostrata quando la routine selezionata non ha esercizi.
class EmptyRoutineScreen extends StatelessWidget {
  const EmptyRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(
        // Scorrevole: su uno schermo basso, o col testo ingrandito, il
        // contenuto non ci stava e veniva tagliato in fondo.
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: EmptyState(
              icon: Icons.fitness_center_outlined,
              title: 'Nessun esercizio in questa routine',
              message: 'Aggiungine almeno uno per poterla allenare.',
              // Unica via d'uscita da questa schermata: merita un
              // bottone pieno, non un link di testo.
              action: FilledButton(
                onPressed: () => context.go('/training'),
                child: const Text('TORNA INDIETRO'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
