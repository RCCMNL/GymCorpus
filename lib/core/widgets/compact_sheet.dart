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

/// La presa in cima a un foglio che si trascina.
///
/// Era ricopiata in dodici schermate, e le copie si erano scostate: chi la
/// smorzava al 20%, chi al 25, chi al 30. Adesso e' una sola.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Il guscio di un foglio che sale dal basso: superficie, angoli tondi in
/// cima, ombra verso l'alto e la [SheetHandle] gia' al suo posto.
///
/// Undici fogli se lo riscrivevano, e due avevano preso raggi diversi - 28
/// e 40 - senza che nessuno lo avesse deciso.
class SheetSurface extends StatelessWidget {
  const SheetSurface({
    required this.child,
    this.padding,
    this.constraints,
    this.gap = 24,
    super.key,
  });

  final Widget child;

  /// Bordi interni del contenuto, maniglia esclusa: i fogli con un elenco
  /// che scorre fin sotto il bordo lo lasciano vuoto.
  final EdgeInsetsGeometry? padding;

  /// Serve ai fogli che contengono un elenco: senza un tetto l'elenco
  /// crescerebbe all'infinito.
  final BoxConstraints? constraints;

  /// Spazio fra la maniglia e il contenuto.
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = this.padding;

    return Container(
      constraints: constraints,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const SheetHandle(),
          SizedBox(height: gap),
          Flexible(
            child: padding == null
                ? child
                : Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}
