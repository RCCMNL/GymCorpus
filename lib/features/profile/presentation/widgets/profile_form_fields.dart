import 'package:flutter/material.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

/// Un campo di testo del profilo: etichetta sopra, riquadro pieno sotto.
class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboard = TextInputType.text,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType keyboard;

  /// Durante il salvataggio i campi si bloccano.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = this.icon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(label, tone: SectionTitleTone.muted),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          enabled: enabled,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _border(theme, alpha: 0.1),
            enabledBorder: _border(theme, alpha: 0.1),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            disabledBorder: _border(theme, alpha: 0.05),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _border(ThemeData theme, {required double alpha}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: alpha),
      ),
    );
  }
}

/// La riga che apre il calendario e mostra la data scelta.
class ProfileDateField extends StatelessWidget {
  const ProfileDateField({
    required this.label,
    required this.onTap,
    this.value,
    this.enabled = true,
    super.key,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(label, tone: SectionTitleTone.muted),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value == null ? 'Seleziona data' : formatDateInput(value),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Il pulsante di salvataggio, con l'alone e la rotella al posto del testo.
class ProfileSaveButton extends StatelessWidget {
  const ProfileSaveButton({
    required this.label,
    required this.onPressed,
    this.isSaving = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          disabledBackgroundColor: theme.colorScheme.primary.withValues(
            alpha: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: isSaving
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                ),
              ),
      ),
    );
  }
}
