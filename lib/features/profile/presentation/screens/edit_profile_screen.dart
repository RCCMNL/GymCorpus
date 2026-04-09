import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  DateTime? _birthDate;
  String? _selectedObjective;
  String? _selectedGender;
  bool _isSaving = false;
  bool _isImperial = false;

  final List<String> _objectives = [
    'Massa',
    'Definizione',
    'Forza',
    'Mantenimento',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded ? trainingState.settings : <String, String>{};
    _isImperial = (settings['units'] ?? 'KG') == 'LB';

    var w = user?.weight;
    if (w != null && _isImperial) w = UnitConverter.kgToLb(w);

    var h = user?.height;
    if (h != null && _isImperial) h = UnitConverter.cmToInch(h);

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _weightController = TextEditingController(
      text: w != null ? w.toStringAsFixed(1) : '',
    );
    _heightController = TextEditingController(
      text: h != null ? h.round().toString() : '',
    );
    _birthDate = user?.birthDate;
    _selectedObjective = user?.trainingObjective;
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('it', 'IT'),
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final localTheme = Theme.of(context);
        return Theme(
          data: localTheme.copyWith(
            colorScheme: localTheme.colorScheme.copyWith(
              primary: const Color(0xFF3367FF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      var finalWeight = double.tryParse(_weightController.text);
      if (finalWeight != null && _isImperial) {
        finalWeight = UnitConverter.lbToKg(finalWeight);
      }

      var finalHeight = double.tryParse(_heightController.text);
      if (finalHeight != null && _isImperial) {
        finalHeight = UnitConverter.inchToCm(finalHeight);
      }

      // Dispatch the update — BLoC handles save in background
      context.read<AuthBloc>().add(
            AuthEvent.updateProfileRequested(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              username: _usernameController.text,
              gender: _selectedGender,
              weight: finalWeight,
              height: finalHeight,
              birthDate: _birthDate,
              trainingObjective: _selectedObjective,
            ),
          );

      // Sync weight with Analytics history
      if (finalWeight != null) {
        context.read<TrainingBloc>().add(AddBodyWeightLogEvent(finalWeight));
      }

      // Wait 500ms for user feedback and to allow background save to kick in
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        context.pop();
      }
    }
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
                Text(
                  'Modifica Profilo',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'NOME',
                        hint: 'Inserisci il nome',
                        theme: theme,
                        enabled: !_isSaving,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'COGNOME',
                        hint: 'Inserisci il cognome',
                        theme: theme,
                        enabled: !_isSaving,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('SESSO', theme),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderCard(
                        'uomo',
                        Icons.male_rounded,
                        'Uomo',
                        theme,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderCard(
                        'donna',
                        Icons.female_rounded,
                        'Donna',
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _usernameController,
                  label: 'USERNAME',
                  hint: '@username',
                  theme: theme,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _weightController,
                        label: _isImperial ? 'PESO (LB)' : 'PESO (KG)',
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                        theme: theme,
                        enabled: !_isSaving,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _heightController,
                        label: _isImperial ? 'ALTEZZA (IN)' : 'ALTEZZA (CM)',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        theme: theme,
                        enabled: !_isSaving,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('DATA DI NASCITA', theme),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isSaving ? null : () => _selectDate(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _birthDate == null
                              ? 'Seleziona data'
                              : DateFormat('dd/MM/yyyy').format(_birthDate!),
                          style: theme.textTheme.bodyLarge,
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('OBIETTIVO DI ALLENAMENTO', theme),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _objectives.map((obj) {
                    final isSelected = _selectedObjective == obj;
                    return ChoiceChip(
                      label: Text(obj),
                      selected: isSelected,
                      onSelected: _isSaving
                          ? null
                          : (selected) {
                              setState(() {
                                _selectedObjective = selected ? obj : null;
                              });
                            },
                      selectedColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                        ),
                      ),
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      disabledBackgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                          )
                        : const Text(
                            'SALVA MODIFICHE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.outline,
      ),
    );
  }

  Widget _buildGenderCard(String value, IconData icon, String label, ThemeData theme) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: _isSaving ? null : () => setState(() => _selectedGender = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1) 
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, theme),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
