import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';

/// Apre il foglio del recupero password, gia' compilato con [initialEmail].
Future<void> showForgotPasswordSheet(
  BuildContext context, {
  String initialEmail = '',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider<AuthBloc>.value(
      value: context.read<AuthBloc>(),
      child: ForgotPasswordSheet(initialEmail: initialEmail),
    ),
  );
}

/// "Ho dimenticato la password": si scrive l'email e arriva il link.
///
/// E' un widget suo perche' il controller deve vivere quanto il foglio, non
/// quanto la schermata di login che lo apre.
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({this.initialEmail = '', super.key});

  /// L'email gia' scritta nel login, cosi' non va riscritta.
  final String initialEmail;

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackBar.showWarning(context, "Inserisci un'email valida.");
      return;
    }

    context.read<AuthBloc>().add(
      AuthEvent.forgotPasswordRequested(email: email),
    );
    Navigator.of(context).pop();
    AppSnackBar.show(context, 'Email di recupero inviata a $email');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: SheetHandle()),
            const SizedBox(height: 24),
            Row(
              children: [
                IconBadge(
                  Icons.lock_reset_rounded,
                  color: theme.colorScheme.primary,
                  size: IconBadgeSize.small,
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    'Recupera Password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Inserisci la tua email e ti invieremo un link per reimpostare '
              'la password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _email,
              hint: 'La tua email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              autofill: const [AutofillHints.email],
              action: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _send,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'INVIA LINK DI RECUPERO',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
