import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/auth_shared_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 1).animate(
      _mainController,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );

    _mainController.forward();

    // The native splash uses the same static composition, so remove it only
    // after the Flutter frame is ready to avoid a visible handoff.
    Future.delayed(
      const Duration(milliseconds: 100),
      FlutterNativeSplash.remove,
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Wait at least for the main animation to finish before navigating
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          state.maybeWhen(
            authenticated: (_) => context.go('/training'),
            unauthenticated: () => context.go('/login'),
            error: (_, __) => context.go('/login'),
            orElse: () {},
          );
        });
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            AmbientBackground(theme: theme),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildPremiumLogo(theme),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'GYMCORPUS',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                        fontSize: 26,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ELITE PERFORMANCE TRACKING',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 3,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 64),
                    _buildLoader(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLogo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
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
            width: 100,
            height: 100,
            color: Colors.white,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
      ),
    );
  }

  Widget _buildLoader(ThemeData theme) {
    return SizedBox(
      width: 160,
      height: 3,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Container(
                width: 160 * _mainController.value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
