import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    context.read<AuthBloc>().add(
          AuthEvent.loginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.fitness_center, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'GYM CORPUS',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.mapOrNull(
            authenticated: (_) {
              context.go('/training');
            },
            error: (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading =
              state.maybeWhen(loading: () => true, orElse: () => false);
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Aesthetic Section (Floating text, no card)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back.',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ELITE PERFORMANCE STARTS HERE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.5,
                                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Login Container (Glassmorphism)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.surfaceContainerHigh
                                      .withValues(alpha: 0.4),
                                  theme.colorScheme.surface
                                      .withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(theme, 'Email Address'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  theme,
                                  _emailController,
                                  'name@example.com',
                                  false,
                                  autofill: [AutofillHints.email],
                                  action: TextInputAction.next,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildLabel(theme, 'Password'),
                                    Text(
                                      'Forgot password?',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  theme,
                                  _passwordController,
                                  '••••••••',
                                  true,
                                  autofill: [AutofillHints.password],
                                  action: TextInputAction.done,
                                  onSubmitted: (_) => _onLoginPressed(),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading ? null : _onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      foregroundColor:
                                          theme.colorScheme.onPrimaryContainer,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      elevation: 8,
                                      shadowColor: theme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'SIGN IN',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                              fontFamily: 'Lexend',
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildDivider(theme),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSocialButton(
                                        theme,
                                        Icons.g_mobiledata,
                                        'Google',
                                        onTap: () => context.read<AuthBloc>().add(
                                              const AuthEvent.googleSignInRequested(),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Opacity(
                                        opacity: 0.5,
                                        child: _buildSocialButton(
                                          theme,
                                          Icons.apple,
                                          'Apple',
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Apple Sign-In coming soon!'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/signup'),
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: theme.colorScheme.tertiary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    TextEditingController controller,
    String hint,
    bool obscure, {
    Iterable<String>? autofill,
    TextInputAction? action,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      autofillHints: autofill,
      textInputAction: action,
      onSubmitted: onSubmitted,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.outline),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
        Container(
          color: theme.colorScheme.surfaceContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    ThemeData theme,
    IconData icon,
    String text, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

extension BlurExtension on Widget {
  Widget blurBackground(double sigma) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: this,
      ),
    );
  }
}
