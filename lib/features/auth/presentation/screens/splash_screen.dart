import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Wait for basic animation before navigating
        Future.delayed(const Duration(milliseconds: 2000), () {
          state.maybeWhen(
            authenticated: (_) => context.go('/training'),
            unauthenticated: () => context.go('/login'),
            error: (_) => context.go('/login'),
            orElse: () {},
          );
        });
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'GYM CORPUS',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
