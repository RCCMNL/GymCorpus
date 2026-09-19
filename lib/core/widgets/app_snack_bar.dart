import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';

/// Cosa sta dicendo il messaggio: decide colore e icona.
enum AppSnackBarTone { neutral, success, warning, error }

/// L'unico modo in cui l'app parla con una SnackBar.
///
/// Lo stesso blocco - SnackBar trasparente, pillola colorata, icona, testo
/// Lexend - era copiato in una quindicina di file, ogni volta con i suoi
/// `Colors.red.shade700` e `Colors.orangeAccent` fuori palette. Qui il
/// colore lo decide il tema e chi chiama sceglie solo il tono.
class AppSnackBar {
  const AppSnackBar._();

  /// Mostra [message], sostituendo l'eventuale messaggio ancora a schermo.
  ///
  /// [icon] sovrascrive l'icona del tono; passare `null` esplicitamente
  /// lascia il solo testo.
  static void show(
    BuildContext context,
    String message, {
    AppSnackBarTone tone = AppSnackBarTone.neutral,
    Object? icon = _defaultIcon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showOn(
      ScaffoldMessenger.of(context),
      Theme.of(context),
      message,
      tone: tone,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message, tone: AppSnackBarTone.success);

  static void showWarning(BuildContext context, String message) =>
      show(context, message, tone: AppSnackBarTone.warning);

  static void showError(BuildContext context, String message) =>
      show(context, message, tone: AppSnackBarTone.error);

  /// Come [show], per chi ha un `ScaffoldMessengerState` ma non un
  /// `BuildContext` sotto di esso: e' il caso del listener globale in
  /// `main.dart`, che usa la chiave del messenger.
  static void showOn(
    ScaffoldMessengerState messenger,
    ThemeData theme,
    String message, {
    AppSnackBarTone tone = AppSnackBarTone.neutral,
    Object? icon = _defaultIcon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        build(
          theme,
          message,
          tone: tone,
          icon: icon,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      );
  }

  /// La pillola vera e propria, esposta per i test e per i rari casi in cui
  /// serve passarla a un `showSnackBar` gia' scritto.
  static SnackBar build(
    ThemeData theme,
    String message, {
    AppSnackBarTone tone = AppSnackBarTone.neutral,
    Object? icon = _defaultIcon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final background = _background(theme, tone);
    final foreground = _foreground(theme, tone);
    final resolved = identical(icon, _defaultIcon)
        ? _toneIcon(tone)
        : icon as IconData?;

    return SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.lg,
          boxShadow: [
            BoxShadow(
              color: background.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            if (resolved != null) ...[
              Icon(resolved, color: foreground, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  fontSize: 13,
                ),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 8),
              // Anche l'azione cede: messaggio lungo e azione insieme non
              // stavano nella larghezza di un telefono stretto.
              Flexible(
                child: TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: foreground,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Sentinella: distingue "icona non specificata" da "nessuna icona".
  static const _defaultIcon = Object();

  static Color _background(ThemeData theme, AppSnackBarTone tone) {
    return switch (tone) {
      AppSnackBarTone.neutral => theme.colorScheme.surfaceContainerHigh,
      AppSnackBarTone.success => theme.colorScheme.tertiary,
      AppSnackBarTone.warning => AppTheme.warning,
      AppSnackBarTone.error => theme.colorScheme.error,
    };
  }

  static Color _foreground(ThemeData theme, AppSnackBarTone tone) {
    return switch (tone) {
      AppSnackBarTone.neutral => theme.colorScheme.onSurface,
      AppSnackBarTone.success => theme.colorScheme.onTertiary,
      AppSnackBarTone.warning => AppTheme.onWarning,
      AppSnackBarTone.error => theme.colorScheme.onError,
    };
  }

  static IconData? _toneIcon(AppSnackBarTone tone) {
    return switch (tone) {
      AppSnackBarTone.neutral => null,
      AppSnackBarTone.success => Icons.check_circle_outline_rounded,
      AppSnackBarTone.warning => Icons.warning_amber_rounded,
      AppSnackBarTone.error => Icons.error_outline_rounded,
    };
  }
}
