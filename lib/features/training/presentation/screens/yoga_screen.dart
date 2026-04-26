import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';

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
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                ).createShader(bounds),
                child: Text(
                  'Yoga & Mind',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
              ),
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
              
              _buildSectionTitle('LIVELLO', theme),
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
              
              _buildSectionTitle('SESSIONI CONSIGLIATE', theme),
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
              _buildSectionTitle('FLOW DEL GIORNO', theme),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const NetworkImage('https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=600'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.6),
                      BlendMode.darken,
                    ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NUOVO',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Inizia Sessione'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildYogaCard(ThemeData theme, String title, String subtitle, IconData icon, Color iconColor) {
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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