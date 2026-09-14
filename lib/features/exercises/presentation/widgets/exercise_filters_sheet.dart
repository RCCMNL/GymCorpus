import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/exercises/domain/equipment_tags.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_catalog_view.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Risultato del pannello filtri: valori scelti dall'utente dopo aver
/// premuto "Applica".
class ExerciseFiltersResult {
  const ExerciseFiltersResult({
    required this.difficulty,
    required this.equipment,
  });

  final String difficulty;
  final Set<String> equipment;
}

/// Apre il pannello filtri (difficoltà + attrezzatura) come bottom sheet.
/// Ritorna `null` se l'utente lo chiude senza applicare (tap fuori,
/// pulsante indietro), altrimenti i valori scelti.
Future<ExerciseFiltersResult?> showExerciseFiltersSheet(
  BuildContext context, {
  required String initialDifficulty,
  required Set<String> initialEquipment,
}) {
  return showModalBottomSheet<ExerciseFiltersResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ExerciseFiltersSheet(
      initialDifficulty: initialDifficulty,
      initialEquipment: initialEquipment,
    ),
  );
}

class _ExerciseFiltersSheet extends StatefulWidget {
  const _ExerciseFiltersSheet({
    required this.initialDifficulty,
    required this.initialEquipment,
  });

  final String initialDifficulty;
  final Set<String> initialEquipment;

  @override
  State<_ExerciseFiltersSheet> createState() => _ExerciseFiltersSheetState();
}

class _ExerciseFiltersSheetState extends State<_ExerciseFiltersSheet> {
  late String _difficulty = widget.initialDifficulty;
  late Set<String> _equipment = {...widget.initialEquipment};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SheetSurface(
        gap: 20,
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtri',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _difficulty = kAllDifficultiesFilter;
                    _equipment = {};
                  }),
                  child: const Text('AZZERA'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const SectionTitle('DIFFICOLTÀ', tone: SectionTitleTone.muted),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    kAllDifficultiesFilter,
                    ...ExerciseEntity.difficultyLevels,
                  ].map((difficulty) {
                    final isSelected = _difficulty == difficulty;
                    return ChoiceChip(
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _difficulty = difficulty),
                      showCheckmark: false,
                      side: BorderSide.none,
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            const SectionTitle('ATTREZZATURA', tone: SectionTitleTone.muted),
            const SizedBox(height: 4),
            Text(
              'Puoi selezionarne più di una.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kEquipmentTags.map((tag) {
                final isSelected = _equipment.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _equipment.add(tag);
                    } else {
                      _equipment.remove(tag);
                    }
                  }),
                  showCheckmark: false,
                  side: BorderSide.none,
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  ExerciseFiltersResult(
                    difficulty: _difficulty,
                    equipment: _equipment,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'APPLICA',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
