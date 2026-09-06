import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';

/// Misure corporee, entrambe facoltative.
class ProfileStats {
  const ProfileStats({this.weight, this.height});

  final double? weight;
  final double? height;
}

/// Secondo passo dell'onboarding: peso e altezza.
///
/// Non sono obbligatori, ma senza il peso il cardio stima le calorie su un
/// valore fisso e il BMI resta vuoto: si chiedono una volta, spiegando a
/// cosa servono, e si possono rimandare.
class ProfileStatsForm extends StatefulWidget {
  const ProfileStatsForm({
    required this.onSubmit,
    required this.onSkip,
    this.initial,
    this.isLoading = false,
    super.key,
  });

  final void Function(ProfileStats stats) onSubmit;
  final VoidCallback onSkip;
  final ProfileStats? initial;
  final bool isLoading;

  /// Intervalli oltre i quali il valore e' quasi certamente un errore di
  /// battitura: 700 al posto di 70, o l'altezza scritta in metri.
  static const minWeight = 25.0;
  static const maxWeight = 350.0;
  static const minHeight = 90.0;
  static const maxHeight = 250.0;

  @override
  State<ProfileStatsForm> createState() => _ProfileStatsFormState();
}

class _ProfileStatsFormState extends State<ProfileStatsForm> {
  late final TextEditingController _weight = TextEditingController(
    text: _initialText(widget.initial?.weight),
  );
  late final TextEditingController _height = TextEditingController(
    text: _initialText(widget.initial?.height),
  );

  String? _error;

  static String _initialText(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  /// Sulla tastiera italiana il separatore decimale e' la virgola.
  static double? _parse(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _submit() {
    final weightText = _weight.text.trim();
    final heightText = _height.text.trim();
    final weight = _parse(weightText);
    final height = _parse(heightText);

    if (weightText.isNotEmpty &&
        (weight == null ||
            weight < ProfileStatsForm.minWeight ||
            weight > ProfileStatsForm.maxWeight)) {
      setState(() => _error = 'Controlla il peso: sembra fuori scala.');
      return;
    }
    if (heightText.isNotEmpty &&
        (height == null ||
            height < ProfileStatsForm.minHeight ||
            height > ProfileStatsForm.maxHeight)) {
      setState(() => _error = "Controlla l'altezza: sembra fuori scala.");
      return;
    }

    setState(() => _error = null);
    widget.onSubmit(ProfileStats(weight: weight, height: height));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = _error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servono a calcolare le calorie bruciate e il tuo indice di massa '
          'corporea. Puoi aggiungerli anche piu tardi dal profilo.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authLabel(theme, 'Peso (kg)'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    key: const Key('profile-weight'),
                    controller: _weight,
                    hint: '70',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                    ],
                    action: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authLabel(theme, 'Altezza (cm)'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    key: const Key('profile-height'),
                    controller: _height,
                    hint: '175',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                    ],
                    action: TextInputAction.done,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 22),
        AuthPrimaryButton(
          label: 'ENTRA IN GYMCORPUS',
          isLoading: widget.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: widget.onSkip,
            child: const Text('Lo faccio dopo'),
          ),
        ),
      ],
    );
  }
}
