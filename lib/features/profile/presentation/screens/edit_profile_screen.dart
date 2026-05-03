import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:intl/intl.dart';

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

  final List<String> _objectives = ['Massa', 'Definizione', 'Forza', 'Mantenimento'];

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'Maschio', 'icon': Icons.male_rounded, 'label': 'M'},
    {'value': 'Femmina', 'icon': Icons.female_rounded, 'label': 'F'},
    {'value': 'Altro', 'icon': Icons.transgender_rounded, 'label': 'Altro'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    final user = context.read<AuthBloc>().state.maybeWhen(authenticated: (u) => u, orElse: () => null);
    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded ? trainingState.settings : <String, String>{};
    _isImperial = (settings['units'] ?? 'KG') == 'LB';

    _initialWeightKg = trainingState is TrainingLoaded && trainingState.bodyWeightLogs.isNotEmpty
        ? trainingState.bodyWeightLogs.first.weight
        : user?.weight;
    var w = _initialWeightKg;
    if (w != null && _isImperial) w = UnitConverter.kgToLb(w);
    var h = user?.height;
    if (h != null && _isImperial) h = UnitConverter.cmToInch(h);

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _weightController = TextEditingController(text: w != null ? w.toStringAsFixed(1) : '');
    _heightController = TextEditingController(text: h != null ? h.round().toString() : '');
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
        return Theme(data: t.copyWith(colorScheme: t.colorScheme.copyWith(primary: const Color(0xFF3367FF))), child: child!);
      },
    );
    if (picked != null && picked != _birthDate) setState(() => _birthDate = picked);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      var finalWeight = double.tryParse(_weightController.text.replaceAll(',', '.'));
      if (finalWeight != null && _isImperial) finalWeight = UnitConverter.lbToKg(finalWeight);
      var finalHeight = double.tryParse(_heightController.text.replaceAll(',', '.'));
      if (finalHeight != null && _isImperial) finalHeight = UnitConverter.inchToCm(finalHeight);

      context.read<AuthBloc>().add(AuthEvent.updateProfileRequested(
            firstName: _firstNameController.text, lastName: _lastNameController.text,
            username: _usernameController.text, gender: _selectedGender,
            weight: finalWeight, height: finalHeight, birthDate: _birthDate, trainingObjective: _selectedObjective,
          ));

      await Future<void>.delayed(const Duration(milliseconds: 1000));
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.tertiary]).createShader(b),
                    child: Text('Modifica Profilo', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  Text('INFORMAZIONI PERSONALI', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2.5, color: theme.colorScheme.primary.withValues(alpha: 0.5), fontWeight: FontWeight.w900)),
                  const SizedBox(height: 28),
                  _sectionLabel('DATI ANAGRAFICI', theme),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _field(controller: _firstNameController, label: 'NOME', hint: 'Inserisci il nome', icon: Icons.person_outline_rounded, theme: theme)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(controller: _lastNameController, label: 'COGNOME', hint: 'Inserisci il cognome', icon: Icons.badge_outlined, theme: theme)),
                  ]),
                  const SizedBox(height: 12),
                  _field(controller: _usernameController, label: 'USERNAME', hint: '@username', icon: Icons.alternate_email_rounded, theme: theme),
                  const SizedBox(height: 28),
                  _sectionLabel('GENERE', theme),
                  const SizedBox(height: 12),
                  Row(children: _genderOptions.map((opt) {
                    final sel = _selectedGender == opt['value'] as String;
                    return Expanded(child: Padding(
                      padding: EdgeInsets.only(right: opt != _genderOptions.last ? 10 : 0),
                      child: _GenderChip(icon: opt['icon'] as IconData, label: opt['label'] as String, isSelected: sel,
                        onTap: _isSaving ? null : () => setState(() => _selectedGender = opt['value'] as String)),
                    ));
                  }).toList()),
                  const SizedBox(height: 28),
                  _sectionLabel('DATI FISICI', theme),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _field(controller: _weightController, label: _isImperial ? 'PESO (LB)' : 'PESO (KG)', hint: '0.0', icon: Icons.monitor_weight_outlined, keyboard: TextInputType.number, theme: theme)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(controller: _heightController, label: _isImperial ? 'ALTEZZA (IN)' : 'ALTEZZA (CM)', hint: '0', icon: Icons.height_rounded, keyboard: TextInputType.number, theme: theme)),
                  ]),
                  const SizedBox(height: 16),
                  _lbl('DATA DI NASCITA', theme),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isSaving ? null : () => _selectDate(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_birthDate == null ? 'Seleziona data' : DateFormat('dd/MM/yyyy').format(_birthDate!), style: theme.textTheme.bodyLarge)),
                        Icon(Icons.chevron_right_rounded, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionLabel('OBIETTIVO DI ALLENAMENTO', theme),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: _objectives.map((obj) {
                    final sel = _selectedObjective == obj;
                    return _ObjChip(label: obj, isSelected: sel, onTap: _isSaving ? null : () => setState(() => _selectedObjective = sel ? null : obj));
                  }).toList()),
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))]),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18), disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('SALVA MODIFICHE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14, fontFamily: 'Lexend')),
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, ThemeData theme) => Row(children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.colorScheme.primary, theme.colorScheme.tertiary]),
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(text, style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.8, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
      ]);

  Widget _lbl(String t, ThemeData theme) => Text(t, style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w900, color: theme.colorScheme.outline));

  Widget _field({required TextEditingController controller, required String label, required String hint, required ThemeData theme, IconData? icon, TextInputType keyboard = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl(label, theme),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, keyboardType: keyboard, enabled: !_isSaving, style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: Icon(icon, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.6))) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
          filled: true, fillColor: theme.colorScheme.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.05))),
        ),
      ),
    ]);
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.icon, required this.label, required this.isSelected, this.onTap});
  final IconData icon; final String label; final bool isSelected; final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.1), width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Column(children: [
          Icon(icon, size: 24, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

class _ObjChip extends StatelessWidget {
  const _ObjChip({required this.label, required this.isSelected, this.onTap});
  final String label; final bool isSelected; final VoidCallback? onTap;

  IconData get _icon { switch (label) { case 'Massa': return Icons.fitness_center_rounded; case 'Definizione': return Icons.local_fire_department_rounded; case 'Forza': return Icons.bolt_rounded; case 'Mantenimento': return Icons.balance_rounded; default: return Icons.flag_rounded; } }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.15), width: isSelected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_icon, size: 16, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
        ]),
      ),
    );
  }
}
