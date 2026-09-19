import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/social_icons.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';

/// La card vetrata del login: email, password, accedi, accessi social e
/// impronta.
///
/// Prende dallo stato della schermata solo quello che le serve: i due
/// controller, se sta caricando, e cosa fare quando si tocca qualcosa.
class LoginCard extends StatelessWidget {
  const LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.showsAppleSignIn,
    required this.showsBiometricButton,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onGoogle,
    required this.onApple,
    required this.onBiometric,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;

  /// Su iOS l'accesso con Apple e' obbligatorio se se ne offre un altro di
  /// terze parti: e' la linea guida 4.8 dell'App Store.
  final bool showsAppleSignIn;
  final bool showsBiometricButton;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onBiometric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          authLabel(theme, 'Email'),
          const SizedBox(height: 8),
          AuthTextField(
            controller: emailController,
            hint: 'nome@esempio.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            autofill: const [AutofillHints.email],
            action: TextInputAction.next,
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              authLabel(theme, 'Password'),
              // "Password dimenticata?" accanto all'etichetta non ci
              // stava su uno schermo stretto: cede il link, non il campo.
              Flexible(
                child: GestureDetector(
                  onTap: onForgotPassword,
                  child: Text(
                    'Password dimenticata?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: passwordController,
            hint: 'password',
            icon: Icons.lock_outline_rounded,
            obscure: obscurePassword,
            autofill: const [AutofillHints.password],
            action: TextInputAction.done,
            onSubmitted: (_) => onLogin(),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
                color: theme.colorScheme.outline,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          const SizedBox(height: 28),
          AuthPrimaryButton(
            label: 'ACCEDI',
            isLoading: isLoading,
            onPressed: onLogin,
          ),
          const SizedBox(height: 28),
          authDivider(theme, 'OPPURE CONTINUA CON'),
          const SizedBox(height: 20),
          AuthSocialButton(
            label: 'Accedi con Google',
            logo: const GoogleLogo(size: 20),
            onTap: onGoogle,
          ),
          if (showsAppleSignIn) ...[
            const SizedBox(height: 12),
            AuthSocialButton(
              label: 'Accedi con Apple',
              logo: const AppleLogo(size: 20),
              onTap: onApple,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Primo accesso? Se non hai ancora un account, usa "Registrati" qui sotto.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (showsBiometricButton) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  IconButton.filledTonal(
                    onPressed: isLoading ? null : onBiometric,
                    icon: const Icon(Icons.fingerprint, size: 30),
                    padding: const EdgeInsets.all(14),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Accedi con Biometria',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
