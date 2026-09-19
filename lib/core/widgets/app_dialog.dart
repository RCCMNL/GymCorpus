import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';

/// Il guscio di un dialogo che chiede o mostra qualcosa.
///
/// Per una domanda secca - "sicuro di eliminare?" - c'e' `ConfirmDialog`.
/// Questo serve quando dentro ci va del contenuto: un campo, una nota, un
/// avviso lungo.
///
/// Nove schermate se lo riscrivevano, e ognuna si risceglieva il fondo
/// (surface o surfaceContainerHigh), il raggio, il peso del titolo e il
/// colore dei pulsanti. Qui si sceglie solo cosa c'e' dentro.
class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.child,
    this.actions = const [],
    this.icon,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  /// L'icona accanto al titolo, quando il dialogo ne ha una.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        fontFamily: 'Lexend',
      ),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xl),
      title: icon == null
          ? heading
          : Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(child: heading),
              ],
            ),
      // Scorrevole sempre: un campo con la tastiera aperta, o un avviso
      // lungo, superano l'altezza che resta su uno schermo basso.
      content: SingleChildScrollView(child: child),
      actions: actions,
    );
  }
}
