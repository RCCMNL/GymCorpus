import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

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
                  color: theme.colorScheme.tertiary.tintedFill,
                  borderRadius: AppRadius.md,
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
              const GradientTitle('Nutrizione'),
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
              _buildMacroSection(context, theme),
              const SizedBox(height: 24),
              _buildWaterTracker(theme),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle('PASTI DI OGGI'),
                  // Niente pulsante "Aggiungi": la sezione e' ancora in
                  // sviluppo (vedi il banner in cima) e un controllo che
                  // al tocco non fa nulla non si legge come "in arrivo",
                  // si legge come app rotta. Meglio dichiararlo.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: AppRadius.xs,
                    ),
                    child: Text(
                      'PRESTO DISPONIBILE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMealItem(
                theme,
                'Colazione',
                '450 kcal',
                Icons.bakery_dining,
                AppPalette.gold,
              ),
              _buildMealItem(
                theme,
                'Pranzo',
                '820 kcal',
                Icons.lunch_dining,
                AppPalette.mint,
              ),
              const SizedBox(height: 32),
              const SectionTitle('ARTICOLI E CONSIGLI'),
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

  Widget _buildMacroSection(BuildContext context, ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      tone: AppCardTone.sunken,
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
              _buildMacroItem(
                context,
                'Prot',
                '180g',
                theme.colorScheme.primary,
              ),
              _buildMacroItem(context, 'Carb', '250g', const Color(0xFF37CBFD)),
              _buildMacroItem(
                context,
                'Grassi',
                '70g',
                const Color(0xFFFFC46B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
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
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
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
        borderRadius: AppRadius.xl,
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
        ),
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
            borderRadius: AppRadius.xs,
            child: LinearProgressIndicator(
              value: 0.48,
              minHeight: 8,
              backgroundColor: theme.colorScheme.tertiary.withValues(
                alpha: 0.1,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.tertiary,
              ),
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
                  color: isFilled
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(
    ThemeData theme,
    String title,
    String calories,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      size: AppCardSize.tight,
      tone: AppCardTone.sunken,
      child: Row(
        children: [
          IconBadge(icon, color: color, size: IconBadgeSize.small),
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
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String summary,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/training/nutrition/article',
          extra: {'title': title, 'body': summary, 'imageUrl': imageUrl},
        );
      },
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 16),
        tone: AppCardTone.sunken,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppRadius.topXxl,
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
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
