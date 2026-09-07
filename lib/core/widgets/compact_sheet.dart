import 'package:flutter/material.dart';

/// Il foglio modale piccolo dell'app: quello che chiede un valore e si
/// chiude.
///
/// Il registra-peso, il modifica-misura e il check-in se lo riscrivevano
/// uguale: stessa spaziatura sopra la tastiera, stesso raggio, stesso
/// titolo in Lexend. Chi lo usa passa solo titolo e contenuto.
class CompactSheet extends StatelessWidget {
  const CompactSheet({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final String title;

  /// Riga di spiegazione sotto il titolo, quando serve.
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// La coppia di pulsanti in fondo a un foglio: si annulla o si conferma.
class SheetActions extends StatelessWidget {
  const SheetActions({
    required this.confirmLabel,
    required this.onConfirm,
    super.key,
  });

  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
        ),
      ],
    );
  }
}

/// Il campo per un numero con la virgola: peso, circonferenza, distanza.
///
/// Leggilo con `parseDecimalInput`, che accetta sia la virgola sia il
/// punto.
class DecimalField extends StatelessWidget {
  const DecimalField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.hint,
    this.autofocus = false,
    this.dense = false,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;

  /// Etichetta interna al campo; se [hint] e' valorizzato diventa
  /// l'etichetta sopra il campo di una riga gia' intestata.
  final String label;

  /// L'unita' di misura mostrata a destra.
  final String suffix;
  final String? hint;
  final bool autofocus;

  /// Bordi interni stretti, per le righe di un elenco di campi.
  final bool dense;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autofocus: autofocus,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: hint == null ? label : null,
        hintText: hint,
        suffixText: suffix,
        contentPadding: dense
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHigh.withValues(
          alpha: 0.35,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
