import 'package:gym_corpus/features/exercises/domain/equipment_tags.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Voce speciale del selettore muscoli che mostra tutti gli esercizi.
const String kAllMusclesFilter = 'Tutti';

/// Voce speciale del selettore muscoli che mostra solo i preferiti.
const String kFavoritesMuscleFilter = 'Preferiti';

/// Etichetta di sezione per gli esercizi senza una categoria valorizzata.
const String kUncategorizedSection = 'Altro';

/// Voce speciale del selettore difficoltà che mostra tutti gli esercizi,
/// indipendentemente dalla difficoltà assegnata (o dalla sua assenza).
const String kAllDifficultiesFilter = 'Tutte';

/// Catalogo esercizi filtrato per ricerca testuale e muscolo selezionato,
/// raggruppato per sezione e con l'elenco dei muscoli disponibili per il
/// selettore orizzontale.
///
/// Prima questo calcolo viveva inline nel `build()` di ExercisesScreen,
/// quindi non testabile senza montare l'intero widget.
class ExerciseCatalogView {
  const ExerciseCatalogView({
    required this.sections,
    required this.exercisesBySection,
    required this.muscleGroups,
    required this.difficultyOptions,
  });

  factory ExerciseCatalogView.build({
    required List<ExerciseEntity> exercises,
    required String searchQuery,
    required String selectedMuscle,
    required String selectedDifficulty,
    Set<String> selectedEquipment = const {},
  }) {
    final search = searchQuery.toLowerCase();
    final filtered = exercises.where((e) {
      final matchesSearch =
          e.name.toLowerCase().contains(search) ||
          (e.equipment?.toLowerCase().contains(search) ?? false) ||
          e.categories.any(
            (category) => category.toLowerCase().contains(search),
          );
      final matchesMuscle =
          selectedMuscle == kAllMusclesFilter ||
          (selectedMuscle == kFavoritesMuscleFilter && e.isFavorite) ||
          e.categories.contains(selectedMuscle);
      final matchesDifficulty =
          selectedDifficulty == kAllDifficultiesFilter ||
          e.difficulty == selectedDifficulty;
      // Multiselezione: un esercizio con anche solo uno dei tag scelti
      // corrisponde (OR tra i tag), non deve averli tutti.
      final matchesEquipment =
          selectedEquipment.isEmpty ||
          equipmentTagsFor(e).any(selectedEquipment.contains);
      return matchesSearch &&
          matchesMuscle &&
          matchesDifficulty &&
          matchesEquipment;
    }).toList();

    final grouped = <String, List<ExerciseEntity>>{};
    for (final exercise in filtered) {
      // Con un muscolo specifico selezionato, un esercizio compare solo
      // nella sezione corrispondente, non in tutte le sue categorie: senza
      // questo filtro comparirebbe anche sotto "Corpo libero" mentre si
      // guarda, per esempio, solo "Petto".
      final sectionCategories =
          selectedMuscle == kAllMusclesFilter ||
              selectedMuscle == kFavoritesMuscleFilter
          ? exercise.categories
          : exercise.categories.where((c) => c == selectedMuscle);

      for (final category in sectionCategories) {
        final section = category.isEmpty ? kUncategorizedSection : category;
        grouped.putIfAbsent(section, () => []).add(exercise);
      }
    }
    final sections = grouped.keys.toList()..sort();

    final muscleGroups = [
      kAllMusclesFilter,
      kFavoritesMuscleFilter,
      ...exercises
          .expand((e) => e.categories)
          .where((m) => m.isNotEmpty)
          .toSet()
          .toList()
        ..sort(),
    ];

    return ExerciseCatalogView(
      sections: sections,
      exercisesBySection: grouped,
      muscleGroups: muscleGroups,
      difficultyOptions: const [
        kAllDifficultiesFilter,
        ...ExerciseEntity.difficultyLevels,
      ],
    );
  }

  /// Nomi di sezione ordinati alfabeticamente.
  final List<String> sections;

  /// Esercizi filtrati, raggruppati per sezione. Un esercizio con piu'
  /// categorie (es. corpo libero + un gruppo muscolare) compare in piu'
  /// sezioni.
  final Map<String, List<ExerciseEntity>> exercisesBySection;

  /// Voci per il selettore muscoli: sempre [kAllMusclesFilter] e
  /// [kFavoritesMuscleFilter] in testa, poi i gruppi muscolari presenti
  /// nel catalogo completo (non filtrato), ordinati alfabeticamente.
  final List<String> muscleGroups;

  /// Voci per il selettore difficoltà: [kAllDifficultiesFilter] seguito dai
  /// tre livelli in ordine crescente. A differenza di [muscleGroups] non è
  /// derivato dai dati (è un enum chiuso e ordinale, un ordinamento
  /// alfabetico delle etichette italiane romperebbe l'ordine naturale).
  final List<String> difficultyOptions;
}
