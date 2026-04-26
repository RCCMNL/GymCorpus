import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

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
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.construction_rounded, color: theme.colorScheme.tertiary, size: 20),
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
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                ).createShader(bounds),
                child: Text(
                  'Nutrizione',
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
                'IL TUO CARBURANTE QUOTIDIANO',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildMacroSection(theme),
              const SizedBox(height: 24),
              _buildWaterTracker(theme),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('PASTI DI OGGI', theme),
                  TextButton(
                    onPressed: () {},
                    child: Text('Aggiungi +', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMealItem(theme, 'Colazione', '450 kcal', Icons.bakery_dining, Colors.orange),
              _buildMealItem(theme, 'Pranzo', '820 kcal', Icons.lunch_dining, Colors.green),
              
              const SizedBox(height: 32),
              _buildSectionTitle('ARTICOLI E CONSIGLI', theme),
              const SizedBox(height: 16),
              _buildArticleCard(
                context,
                theme,
                'Importanza delle Proteine',
                'Scopri perché le proteine sono fondamentali per la crescita muscolare.',
                'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&q=80&w=300',
              ),
              _buildArticleCard(
                context,
                theme,
                'Idratazione e Performance',
                "Quanto influisce l'acqua sui tuoi allenamenti?",
                'https://images.unsplash.com/photo-1550583760-583c1029c00b?auto=format&fit=crop&q=80&w=300',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Calorico',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                '2.400 kcal',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Prot', '180g', Colors.redAccent),
              _buildMacroItem('Carb', '250g', Colors.blueAccent),
              _buildMacroItem('Grassi', '70g', Colors.yellowAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(
              label[0],
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWaterTracker(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 12),
                  const Text(
                    'Idratazione',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Text(
                '1.2 / 2.5 L',
                style: TextStyle(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.48,
              minHeight: 8,
              backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.tertiary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(8, (index) {
              final isFilled = index < 4;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.local_drink,
                  size: 20,
                  color: isFilled ? theme.colorScheme.tertiary : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(ThemeData theme, String title, String calories, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            calories,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ],
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

  Widget _buildArticleCard(BuildContext context, ThemeData theme, String title, String summary, String imageUrl) {
    return GestureDetector(
      onTap: () {
        context.push('/training/nutrition/article', extra: {
          'title': title,
          'body': summary,
          'imageUrl': imageUrl,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.broken_image_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
