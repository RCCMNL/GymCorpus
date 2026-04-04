"""Generate seed_data.dart from the extracted exercises text."""

header = """import 'package:drift/drift.dart';
import 'database.dart';

/// All 157 exercises extracted from the legacy Stitch Design database.
/// Organized by muscle group: Petto, Dorso, Spalle, Bicipiti, Tricipiti,
/// Avambracci, Gambe, Polpacci, Addominali.
List<ExercisesCompanion> getSeedExercises() {
  return [
"""

footer = """  ];
}
"""

with open(r'c:\Users\ricca\Desktop\GymCorpus\tmp\initial_exercises.txt', 'r', encoding='utf-8') as f:
    exercises_block = f.read()

# Fix: remove \r from line endings
exercises_block = exercises_block.replace('\r\n', '\n')

with open(r'c:\Users\ricca\Desktop\GymCorpus\lib\core\database\seed_data.dart', 'w', encoding='utf-8') as f:
    f.write(header)
    f.write(exercises_block)
    f.write('\n')
    f.write(footer)

print("seed_data.dart written successfully!")
