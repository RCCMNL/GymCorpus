import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

class YogaScreen extends StatelessWidget {
  const YogaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.tintedFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.tintedBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'SEZIONE IN SVILUPPO: Alcune funzionalità potrebbero non essere disponibili.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const GradientTitle('Yoga & Mind'),
              const SizedBox(height: 8),
              Text(
                'EQUILIBRIO E CONSAPEVOLEZZA',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const SectionTitle('LIVELLO'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDifficultyChip(theme, 'Tutti', true),
                    _buildDifficultyChip(theme, 'Principiante', false),
                    _buildDifficultyChip(theme, 'Intermedio', false),
                    _buildDifficultyChip(theme, 'Avanzato', false),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const SectionTitle('SESSIONI CONSIGLIATE'),
              const SizedBox(height: 16),
              _buildYogaCard(
                theme,
                'Vinyasa Flow',
                '25 min • Intermedio',
                Icons.self_improvement,
                Colors.orangeAccent,
              ),
              _buildYogaCard(
                theme,
                'Hatha Yoga',
                '40 min • Principiante',
                Icons.spa,
                Colors.tealAccent,
              ),
              const SizedBox(height: 32),
              const SectionTitle('FLOW DEL GIORNO'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // Sfondo disegnato invece di una foto scaricata da un
                  // servizio esterno: nessuna chiamata di rete silenziosa, e
                  // niente card rotta se quell'indirizzo cambia.
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                      theme.colorScheme.surfaceContainerHighest,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NUOVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Deep Zen Flow',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Una sessione immersiva per eliminare lo stress quotidiano.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nessun pulsante di avvio: le sessioni guidate non
                    // esistono ancora, e un tasto che non fa niente sembra
                    // un difetto dell'app invece di una funzione in arrivo.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.tintedFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.tintedBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Le sessioni guidate non sono ancora disponibili',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(ThemeData theme, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildYogaCard(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white54, size: 32),
        ],
      ),
    );
  }
}
