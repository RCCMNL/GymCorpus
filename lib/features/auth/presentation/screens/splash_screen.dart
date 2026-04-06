import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0, 0.7, curve: Curves.elasticOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
    );

    _blurAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        Future.delayed(const Duration(milliseconds: 3000), () {
          if (!mounted) return;
          state.maybeWhen(
            authenticated: (_) => context.go('/training'),
            unauthenticated: () => context.go('/login'),
            error: (_) => context.go('/login'),
            orElse: () {},
          );
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF08082F), // Deep Stitch Navy
        body: Stack(
          children: [
            // Ambient Background Elements
            _buildAmbientGlow(theme, size),
            
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_mainController, _pulseController]),
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section with Advanced VFX
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer Dynamic Aura
                              _buildLogoAura(theme),
                              
                              // Main Logo Container
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: _blurAnimation.value,
                                  sigmaY: _blurAnimation.value,
                                ),
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  padding: const EdgeInsets.all(20),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),

                      // Text & Progress with Premium Typography
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              'GYMCORPUS',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 12,
                                fontSize: 24,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
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
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 60),
                            
                            // Minimalist Loading Sync
                            _buildProgressIndicator(theme),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientGlow(ThemeData theme, Size size) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoAura(ThemeData theme) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.2),
            theme.colorScheme.primary.withValues(alpha: 0.1),
          ],
          transform: GradientRotation(_pulseController.value * 6.28),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return SizedBox(
      width: 140,
      height: 2,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Container(
                    width: 140 * _mainController.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
