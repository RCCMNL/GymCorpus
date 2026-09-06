import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/utils/athlete_progress_extensions.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/custom_segmented_control.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/physical_stats_row.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_menu_tab.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/settings_menu_tab.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<TrainingBloc>()
      ..add(LoadWeightLogsEvent())
      ..add(LoadWorkoutSessionsEvent())
      ..add(LoadCardioSessionsEvent());
  }

  ImageProvider? _resolveProfileImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return null;
    }
    // Solo https, coerentemente con _isPortablePhotoUrl nel repository: un
    // URL in chiaro esporrebbe l'immagine a sostituzione lungo il percorso.
    if (photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    if (photoUrl.startsWith('http://')) {
      debugPrint('ProfileScreen: URL foto non cifrato ignorato: $photoUrl');
      return null;
    }

    final file = File(photoUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }

    debugPrint('ProfileScreen missing local profile image: $photoUrl');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, trainingState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Profilo',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'APP PREFERENCES & ACCOUNT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2.5,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // User Profile Quick Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                          theme.colorScheme.tertiary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final user = state.maybeWhen(
                          authenticated: (user, _) => user,
                          loading: (previousUser) => previousUser,
                          error: (message, previousUser) => previousUser,
                          orElse: () => null,
                        );
                        final userName = user?.fullName ?? 'Atleta';
                        final photoUrl = user?.photoUrl;
                        final photoProvider = _resolveProfileImageProvider(
                          photoUrl,
                        );
                        final athleteProgress = trainingState.athleteProgress;

                        return Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      maxWidth: 512,
                                      maxHeight: 512,
                                      imageQuality: 75,
                                    );

                                    if (image != null && context.mounted) {
                                      context.read<AuthBloc>().add(
                                        AuthEvent.updateProfileImageRequested(
                                          filePath: image.path,
                                        ),
                                      );
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          border: Border.all(
                                            color: theme.colorScheme.tertiary,
                                            width: 2.5,
                                          ),
                                          image: photoProvider != null
                                              ? DecorationImage(
                                                  image: photoProvider,
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: photoProvider == null
                                            ? Icon(
                                                Icons.person,
                                                color:
                                                    theme.colorScheme.primary,
                                                size: 36,
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.orangeAccent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: theme.colorScheme.surface,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            photoProvider != null
                                                ? Icons.edit_rounded
                                                : Icons.add_a_photo_rounded,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Lexend',
                                              fontSize: 22,
                                              letterSpacing: -0.5,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (user?.username != null)
                                        Text(
                                          '@${user!.username}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                        ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.tertiary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.tertiary
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          'LIVELLO ${athleteProgress.level}',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.tertiary,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 10,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${athleteProgress.levelTitle} - ${athleteProgress.xp} XP',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: theme.colorScheme.outline,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Divider(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                                height: 1,
                              ),
                            ),
                            PhysicalStatsRow(
                              user: user,
                              trainingState: trainingState,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Segmented Control
                  CustomSegmentedControl(
                    selectedIndex: _selectedTab,
                    onChanged: (index) {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Ultra-fast Snappy Transition
                  AnimatedCrossFade(
                    firstChild: const ProfileMenuTab(),
                    secondChild: SettingsMenuTab(trainingState: trainingState),
                    crossFadeState: _selectedTab == 0
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 150),
                    sizeCurve: Curves.easeOutCubic,
                    firstCurve: Curves.easeInOut,
                    secondCurve: Curves.easeInOut,
                  ),

                  const SizedBox(height: 40), // Space for nav
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
