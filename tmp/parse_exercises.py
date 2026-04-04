import re

with open(r'C:\Users\ricca\Downloads\stitch_design\AppDatabase.java', 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern for Esercizio constructor
# esercizi.add(new Esercizio(
#     "Name", "Category", icon,
#     "Equipment",
#     "FocusArea",
#     "Preparation",
#     "Execution",
#     "Tips"
# ));

pattern = r'esercizi\.add\(new Esercizio\(\s*"([^"]*)",\s*"([^"]*)",\s*[^,]*,\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]*)",\s*"([^"]*)"\s*\)\);'

matches = re.finditer(pattern, content, re.MULTILINE | re.DOTALL)

companions = []
for match in matches:
    name, category, equipment, focus, prep, exec_, tips = match.groups()
    
    def escape_dart(s):
        return s.replace("'", "\\'").replace('"', '\\"').replace("\n", " ").replace("\r", "")

    companion = f"""      ExercisesCompanion(
        name: const Value('{escape_dart(name)}'),
        targetMuscle: const Value('{escape_dart(category)}'),
        equipment: const Value('{escape_dart(equipment)}'),
        focusArea: const Value('{escape_dart(focus)}'),
        preparation: const Value('{escape_dart(prep)}'),
        execution: const Value('{escape_dart(exec_)}'),
        tips: const Value('{escape_dart(tips)}'),
      ),"""
    companions.append(companion)

with open(r'c:\Users\ricca\Desktop\GymCorpus\tmp\initial_exercises.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(companions))
print(f"Successfully wrote {len(companions)} exercises.")
