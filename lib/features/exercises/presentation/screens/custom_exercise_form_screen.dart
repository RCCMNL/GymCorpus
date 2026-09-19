import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';

/// Gruppi muscolari canonici usati dal catalogo esercizi. Un esercizio
/// custom deve usarne uno di questi (non testo libero) per comparire
/// correttamente raggruppato/filtrato in ExercisesScreen.
const List<String> _kMuscleGroups = [
  'Addominali',
  'Avambracci',
  'Bicipiti',
  'Dorso',
  'Gambe',
  'Petto',
  'Polpacci',
  'Spalle',
  'Tricipiti',
];

/// Form di creazione/modifica di un esercizio custom dell'utente. Stesso
/// widget per entrambi i casi: se [exerciseToEdit] è nullo si crea un
/// nuovo esercizio, altrimenti si modifica quello passato (deve essere
/// un esercizio custom, la modifica di uno predefinito è bloccata lato
/// repository).
class CustomExerciseFormScreen extends StatefulWidget {
  const CustomExerciseFormScreen({this.exerciseToEdit, super.key});

  final ExerciseEntity? exerciseToEdit;

  @override
  State<CustomExerciseFormScreen> createState() =>
      _CustomExerciseFormScreenState();
}

class _CustomExerciseFormScreenState extends State<CustomExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _equipmentController;
  late final TextEditingController _focusAreaController;
  late final TextEditingController _preparationController;
  late final TextEditingController _executionController;
  late final TextEditingController _tipsController;

  String? _selectedMuscle;
  String? _selectedDifficulty;
  bool _isBodyweight = false;

  bool get _isEditing => widget.exerciseToEdit != null;

  @override
  void initState() {
    super.initState();
    final exercise = widget.exerciseToEdit;
    _nameController = TextEditingController(text: exercise?.name);
    _equipmentController = TextEditingController(text: exercise?.equipment);
    _focusAreaController = TextEditingController(text: exercise?.focusArea);
    _preparationController = TextEditingController(text: exercise?.preparation);
    _executionController = TextEditingController(text: exercise?.execution);
    _tipsController = TextEditingController(text: exercise?.tips);
    _selectedMuscle = exercise?.targetMuscle;
    _selectedDifficulty = exercise?.difficulty;
    _isBodyweight = exercise?.isBodyweight ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentController.dispose();
    _focusAreaController.dispose();
    _preparationController.dispose();
    _executionController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  String? _blankToNull(String text) => text.trim().isEmpty ? null : text.trim();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscle == null) {
      AppSnackBar.showWarning(context, 'Seleziona un gruppo muscolare.');
      return;
    }
    if (_selectedDifficulty == null) {
      AppSnackBar.showWarning(context, 'Seleziona una difficoltà.');
      return;
    }

    final bloc = context.read<TrainingBloc>();
    if (_isEditing) {
      bloc.add(
        UpdateCustomExerciseEvent(
          id: widget.exerciseToEdit!.id,
          name: _nameController.text.trim(),
          targetMuscle: _selectedMuscle!,
          difficulty: _selectedDifficulty!,
          equipment: _blankToNull(_equipmentController.text),
          focusArea: _blankToNull(_focusAreaController.text),
          preparation: _blankToNull(_preparationController.text),
          execution: _blankToNull(_executionController.text),
          tips: _blankToNull(_tipsController.text),
          isBodyweight: _isBodyweight,
        ),
      );
    } else {
      bloc.add(
        AddCustomExerciseEvent(
          name: _nameController.text.trim(),
          targetMuscle: _selectedMuscle!,
          difficulty: _selectedDifficulty!,
          equipment: _blankToNull(_equipmentController.text),
          focusArea: _blankToNull(_focusAreaController.text),
          preparation: _blankToNull(_preparationController.text),
          execution: _blankToNull(_executionController.text),
          tips: _blankToNull(_tipsController.text),
          isBodyweight: _isBodyweight,
        ),
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientTitle(
                  _isEditing ? 'Modifica Esercizio' : 'Nuovo Esercizio',
                ),
                const SizedBox(height: 28),

                const SectionTitle('NOME*', tone: SectionTitleTone.muted),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Es. Curl con elastici',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Il nome è obbligatorio'
                      : null,
                ),
                const SizedBox(height: 20),

                const SectionTitle(
                  'GRUPPO MUSCOLARE*',
                  tone: SectionTitleTone.muted,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kMuscleGroups.map((muscle) {
                    final isSelected = _selectedMuscle == muscle;
                    return ChoiceChip(
                      label: Text(muscle),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedMuscle = muscle),
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
                const SizedBox(height: 20),

                const SectionTitle('DIFFICOLTÀ*', tone: SectionTitleTone.muted),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExerciseEntity.difficultyLevels.map((difficulty) {
                    final isSelected = _selectedDifficulty == difficulty;
                    return ChoiceChip(
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedDifficulty = difficulty),
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
                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Corpo libero',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: _isBodyweight,
                  onChanged: (value) => setState(() => _isBodyweight = value),
                ),
                const SizedBox(height: 12),

                const SectionTitle(
                  'ATTREZZATURA',
                  tone: SectionTitleTone.muted,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _equipmentController,
                  decoration: const InputDecoration(
                    hintText: 'Es. Elastici (Resistance bands)',
                  ),
                ),
                const SizedBox(height: 20),

                const SectionTitle('AREA FOCUS', tone: SectionTitleTone.muted),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _focusAreaController,
                  decoration: const InputDecoration(
                    hintText: 'Es. Bicipite, capo lungo',
                  ),
                ),
                const SizedBox(height: 20),

                const SectionTitle(
                  'PREPARAZIONE',
                  tone: SectionTitleTone.muted,
                ),
                const SizedBox(height: 4),
                Text(
                  'Separa i passaggi con un punto per mostrarli come elenco numerato.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _preparationController,
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 20),

                const SectionTitle('ESECUZIONE', tone: SectionTitleTone.muted),
                const SizedBox(height: 4),
                Text(
                  'Due frasi separate da un punto: la prima è la salita, la seconda la discesa.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _executionController,
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 20),

                const SectionTitle('CONSIGLI', tone: SectionTitleTone.muted),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tipsController,
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.lg,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lg,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isEditing ? 'SALVA MODIFICHE' : 'CREA ESERCIZIO',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 14,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
