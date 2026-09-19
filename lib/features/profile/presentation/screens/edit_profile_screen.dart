import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/utils/decimal_input.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_form_fields.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
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
  double? _initialWeightKg;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _objectives = [
    'Massa',
    'Definizione',
    'Forza',
    'Mantenimento',
  ];

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'Maschio', 'icon': Icons.male_rounded, 'label': 'M'},
    {'value': 'Femmina', 'icon': Icons.female_rounded, 'label': 'F'},
    {'value': 'Altro', 'icon': Icons.transgender_rounded, 'label': 'Altro'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    final user = context.read<AuthBloc>().state.maybeWhen(
      authenticated: (u, _) => u,
      orElse: () => null,
    );
    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};
    _isImperial = (settings['units'] ?? 'KG') == 'LB';

    _initialWeightKg =
        trainingState is TrainingLoaded &&
            trainingState.bodyWeightLogs.isNotEmpty
        ? trainingState.bodyWeightLogs.first.weight
        : user?.weight;
    var w = _initialWeightKg;
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

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
        final t = Theme.of(context);
        return Theme(
          data: t.copyWith(
            colorScheme: t.colorScheme.copyWith(
              primary: const Color(0xFF3367FF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      var finalWeight = parseDecimalInput(_weightController.text);
      if (finalWeight != null && _isImperial) {
        finalWeight = UnitConverter.lbToKg(finalWeight);
      }
      var finalHeight = parseDecimalInput(_heightController.text);
      if (finalHeight != null && _isImperial) {
        finalHeight = UnitConverter.inchToCm(finalHeight);
      }

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

      await Future<void>.delayed(const Duration(milliseconds: 1000));
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const GradientTitle('Modifica Profilo'),
                    const SizedBox(height: 4),
                    const SectionTitle('INFORMAZIONI PERSONALI'),
                    const SizedBox(height: 28),
                    const SectionTitle(
                      'DATI ANAGRAFICI',
                      tone: SectionTitleTone.muted,
                      withAccentBar: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            controller: _firstNameController,
                            label: 'NOME',
                            hint: 'Inserisci il nome',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ProfileTextField(
                            controller: _lastNameController,
                            label: 'COGNOME',
                            hint: 'Inserisci il cognome',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ProfileTextField(
                      controller: _usernameController,
                      label: 'USERNAME',
                      hint: '@username',
                      icon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle(
                      'GENERE',
                      tone: SectionTitleTone.muted,
                      withAccentBar: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _genderOptions.map((opt) {
                        final sel = _selectedGender == opt['value'] as String;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: opt != _genderOptions.last ? 10 : 0,
                            ),
                            child: _GenderChip(
                              icon: opt['icon'] as IconData,
                              label: opt['label'] as String,
                              isSelected: sel,
                              onTap: _isSaving
                                  ? null
                                  : () => setState(
                                      () => _selectedGender =
                                          opt['value'] as String,
                                    ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle(
                      'DATI FISICI',
                      tone: SectionTitleTone.muted,
                      withAccentBar: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            controller: _weightController,
                            label: _isImperial ? 'PESO (LB)' : 'PESO (KG)',
                            hint: '0.0',
                            icon: Icons.monitor_weight_outlined,
                            keyboard: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ProfileTextField(
                            controller: _heightController,
                            label: _isImperial
                                ? 'ALTEZZA (IN)'
                                : 'ALTEZZA (CM)',
                            hint: '0',
                            icon: Icons.height_rounded,
                            keyboard: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProfileDateField(
                      label: 'DATA DI NASCITA',
                      value: _birthDate,
                      enabled: !_isSaving,
                      onTap: () => unawaited(_selectDate(context)),
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle(
                      'OBIETTIVO DI ALLENAMENTO',
                      tone: SectionTitleTone.muted,
                      withAccentBar: true,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _objectives.map((obj) {
                        final sel = _selectedObjective == obj;
                        return _ObjChip(
                          label: obj,
                          isSelected: sel,
                          onTap: _isSaving
                              ? null
                              : () => setState(
                                  () => _selectedObjective = sel ? null : obj,
                                ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                    ProfileSaveButton(
                      label: 'SALVA MODIFICHE',
                      isSaving: _isSaving,
                      onPressed: () => unawaited(_saveProfile()),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjChip extends StatelessWidget {
  const _ObjChip({required this.label, required this.isSelected, this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (label) {
      case 'Massa':
        return Icons.fitness_center_rounded;
      case 'Definizione':
        return Icons.local_fire_department_rounded;
      case 'Forza':
        return Icons.bolt_rounded;
      case 'Mantenimento':
        return Icons.balance_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
