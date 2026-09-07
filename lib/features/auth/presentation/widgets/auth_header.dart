import 'package:flutter/material.dart';

/// L'intestazione delle schermate di accesso: titolo, occhiello e logo.
///
/// Login e registrazione la disegnavano uguale, sessantacinque righe per
/// uno, cambiando solo le due scritte.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.title,
    required this.subtitle,
    this.titleSize = 32,
    this.logoSize = 56,
    super.key,
  });

  final String title;

  /// La riga piccola sopra il logo, tutta maiuscola.
  final String subtitle;

  /// La registrazione ha un titolo piu' lungo e lo scrive piu' piccolo.
  final double titleSize;

  /// Anche il logo la' e' un po' piu' piccolo, per far stare i due passi.
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                fontSize: titleSize,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Hero(
          tag: 'app_logo',
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
              ).createShader(bounds),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: logoSize,
                  height: logoSize,
                  color: Colors.white,
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Il piede delle schermate di accesso: la domanda e il rimando all'altra.
class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    required this.question,
    required this.action,
    required this.onTap,
    super.key,
  });

  /// "Non hai un account? " oppure "Hai gia' un account? ".
  final String question;

  /// La parola su cui si tocca: "Registrati", "Accedi".
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(text: question),
              TextSpan(
                text: action,
                style: TextStyle(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
