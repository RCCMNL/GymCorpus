import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Tag di attrezzatura riconosciuti nel campo libero `equipment` degli
/// esercizi. Il campo non è un elenco chiuso di valori (106 stringhe
/// diverse su 157 esercizi, es. "Panca inclinata (30-45°), Manubri (o
/// Bilanciere EZ)"), quindi i tag vengono derivati a runtime per parola
/// chiave invece di richiedere una colonna dedicata — stesso approccio
/// già usato dalla ricerca testuale in ExerciseCatalogView, che fa match
/// come sottostringa sullo stesso campo.
const List<String> kEquipmentTags = [
  'Bilanciere',
  'Manubri',
  'Corpo libero',
  'Cavi / Ercolina',
  'Macchinario',
  'Panca',
  'Rack',
  'Kettlebell',
  'Elastici',
  'Sbarra per trazioni',
  'Parallele / Dip',
  'Dischi / Pesi',
];

const Map<String, List<String>> _keywordsByTag = {
  'Bilanciere': ['bilanciere'],
  'Manubri': ['manubri', 'manubrio'],
  'Cavi / Ercolina': ['cavo', 'cavi', 'ercolina', 'pulley', 'corda'],
  'Macchinario': ['macchinario', 'macchina', 'machine', 'pressa'],
  'Panca': ['panca'],
  'Rack': ['rack'],
  'Kettlebell': ['kettlebell'],
  'Elastici': ['elastici', 'resistance band'],
  'Sbarra per trazioni': ['sbarra per trazioni', "captain's chair"],
  'Parallele / Dip': ['parallele', 'dip station'],
  'Dischi / Pesi': ['disco', 'dischi', 'pesi'],
};

/// Tag di attrezzatura corrispondenti a [exercise]. "Corpo libero" segue
/// [ExerciseEntity.isBodyweight] invece del testo (è già un flag
/// affidabile), gli altri tag vengono riconosciuti nel testo di
/// [ExerciseEntity.equipment]. Un esercizio può avere più tag (es.
/// "Bilanciere, Rack" → Bilanciere e Rack).
List<String> equipmentTagsFor(ExerciseEntity exercise) {
  final tags = <String>[];
  if (exercise.isBodyweight) {
    tags.add('Corpo libero');
  }
  final equipment = exercise.equipment?.toLowerCase();
  if (equipment != null) {
    for (final entry in _keywordsByTag.entries) {
      if (entry.value.any(equipment.contains)) {
        tags.add(entry.key);
      }
    }
  }
  return tags;
}
