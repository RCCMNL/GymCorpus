import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthEvent.signUpRequested(
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
          final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Aesthetic Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Join Core.',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'YOUR TRANSFORMATION STARTS TODAY',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.5,
                                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // SignUp Container (Glassmorphism)
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
                                  theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
                                  theme.colorScheme.surface.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
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
                                _buildLabel(theme, 'Password'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  theme,
                                  _passwordController,
                                  '••••••••',
                                  true,
                                  autofill: [AutofillHints.newPassword],
                                  action: TextInputAction.next,
                                ),
                                const SizedBox(height: 24),
                                _buildLabel(theme, 'Confirm Password'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  theme,
                                  _confirmPasswordController,
                                  '••••••••',
                                  true,
                                  autofill: [AutofillHints.newPassword],
                                  action: TextInputAction.done,
                                  onSubmitted: (_) => _onSignUpPressed(),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _onSignUpPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                      elevation: 8,
                                      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text(
                                            'CREATE ACCOUNT',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                              fontFamily: 'Lexend',
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign In',
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
