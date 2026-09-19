import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';

/// Le informazioni di base che l'app chiede a chiunque crei un profilo.
class ProfileBasics {
  const ProfileBasics({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.birthDate,
    required this.gender,
  });

  final String firstName;
  final String lastName;
  final String username;
  final DateTime? birthDate;

  /// Nullo finche' l'utente non sceglie: il genere non ha un valore di
  /// partenza sensato, e un default finirebbe salvato come se fosse una
  /// scelta.
  final String? gender;
}

/// Form delle informazioni di base, condiviso tra registrazione e onboarding.
///
/// Vive in un widget solo perche' i due percorsi non possano divergere: era
/// gia' successo che la registrazione con Google e quella con email
/// chiedessero cose diverse.
class ProfileBasicsForm extends StatefulWidget {
  const ProfileBasicsForm({
    required this.submitLabel,
    required this.onSubmit,
    required this.onValidationError,
    this.initial,
    this.footer,
    this.isLoading = false,
    super.key,
  });

  final String submitLabel;

  /// Invocata solo quando i campi del form sono validi. Quello che c'e'
  /// dentro [footer], per esempio i consensi legali, resta responsabilita'
  /// della schermata ospite.
  final void Function(ProfileBasics basics) onSubmit;

  final void Function(String message) onValidationError;

  final ProfileBasics? initial;
  final Widget? footer;
  final bool isLoading;

  static const genders = ['Uomo', 'Donna', 'Altro'];

  @override
  State<ProfileBasicsForm> createState() => ProfileBasicsFormState();
}

class ProfileBasicsFormState extends State<ProfileBasicsForm> {
  late final TextEditingController _firstName = TextEditingController(
    text: widget.initial?.firstName ?? '',
  );
  late final TextEditingController _lastName = TextEditingController(
    text: widget.initial?.lastName ?? '',
  );
  late final TextEditingController _username = TextEditingController(
    text: widget.initial?.username ?? '',
  );

  late DateTime? _birthDate = widget.initial?.birthDate;
  late String? _gender = widget.initial?.gender;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final username = _username.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty) {
      widget.onValidationError('Compila tutti i campi obbligatori.');
      return;
    }
    if (_birthDate == null) {
      widget.onValidationError('Seleziona la tua data di nascita.');
      return;
    }
    if (_gender == null) {
      widget.onValidationError('Scegli il tuo genere.');
      return;
    }

    widget.onSubmit(
      ProfileBasics(
        firstName: firstName,
        lastName: lastName,
        username: username,
        birthDate: _birthDate,
        gender: _gender,
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 20);
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        var tempDate = initialDate;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: AppRadius.xl,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SheetHandle(),
                    const SizedBox(height: 12),
                    Text(
                      'Data di nascita',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 320,
                      child: CalendarDatePicker(
                        initialDate: tempDate,
                        firstDate: DateTime(1900),
                        lastDate: now,
                        onDateChanged: (value) {
                          setModalState(() => tempDate = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(tempDate),
                            child: const Text('Conferma'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authLabel(theme, 'Nome'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _firstName,
                    hint: 'nome',
                    autofill: const [AutofillHints.givenName],
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
                  authLabel(theme, 'Cognome'),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _lastName,
                    hint: 'cognome',
                    autofill: const [AutofillHints.familyName],
                    action: TextInputAction.next,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        authLabel(theme, 'Username'),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _username,
          hint: 'username',
          icon: Icons.alternate_email_rounded,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 30,
            minHeight: 18,
          ),
          autofill: const [AutofillHints.username],
          action: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDatePicker(theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderSelector(theme)),
          ],
        ),
        if (widget.footer != null) ...[
          const SizedBox(height: 18),
          widget.footer!,
        ],
        const SizedBox(height: 22),
        AuthPrimaryButton(
          label: widget.submitLabel,
          isLoading: widget.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    final date = _birthDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        authLabel(theme, 'Data di nascita'),
        const SizedBox(height: 8),
        InkWell(
          key: const Key('profile-birthdate'),
          onTap: _selectDate,
          borderRadius: AppRadius.md,
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            size: AppCardSize.tight,
            tone: AppCardTone.sunken,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date == null ? 'Seleziona' : formatDateInput(date),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: date == null
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        authLabel(theme, 'Genere'),
        const SizedBox(height: 8),
        AppCard(
          size: AppCardSize.tight,
          tone: AppCardTone.sunken,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('profile-gender'),
              value: _gender,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              borderRadius: AppRadius.sm,
              dropdownColor: theme.colorScheme.surfaceContainerHigh,
              // Nessun valore di partenza: il campo resta vuoto finche' non
              // viene scelto, e senza scelta non si prosegue.
              hint: Text(
                'Seleziona',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              items: [
                for (final gender in ProfileBasicsForm.genders)
                  DropdownMenuItem(value: gender, child: Text(gender)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _gender = value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
