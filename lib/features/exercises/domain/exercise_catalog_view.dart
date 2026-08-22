import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Voce speciale del selettore muscoli che mostra tutti gli esercizi.
const String kAllMusclesFilter = 'Tutti';

/// Voce speciale del selettore muscoli che mostra solo i preferiti.
const String kFavoritesMuscleFilter = 'Preferiti';

/// Etichetta di sezione per gli esercizi senza una categoria valorizzata.
const String kUncategorizedSection = 'Altro';

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
  });

  factory ExerciseCatalogView.build({
    required List<ExerciseEntity> exercises,
    required String searchQuery,
    required String selectedMuscle,
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
      return matchesSearch && matchesMuscle;
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
}
