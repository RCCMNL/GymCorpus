import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/radial_timer_picker.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/custom_segmented_control.dart';
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

  ImageProvider? _resolveProfileImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return null;
    }
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
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
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.5),
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
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final user = state.maybeWhen(
                          authenticated: (user) => user,
                          loading: (previousUser) => previousUser,
                          error: (message, previousUser) => previousUser,
                          orElse: () => null,
                        );
                        final userName = user?.fullName ?? 'Atleta';
                        final photoUrl = user?.photoUrl;
                        final photoProvider =
                            _resolveProfileImageProvider(photoUrl);

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
                                            AuthEvent
                                                .updateProfileImageRequested(
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
                                          color: theme.colorScheme
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
                                            color: theme.colorScheme.outline,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: theme.colorScheme.tertiary
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          'LIVELLO 1',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.tertiary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                            letterSpacing: 1.1,
                                          ),
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
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.1),
                                height: 1,
                              ),
                            ),
                            _buildPhysicalStats(
                              context,
                              theme,
                              user,
                              trainingState,
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
                    firstChild: _buildProfileMenu(context, theme),
                    secondChild:
                        _buildSettingsMenu(context, theme, trainingState),
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

  Widget _buildProfileMenu(BuildContext context, ThemeData theme) {
    return Column(
      key: const ValueKey('profile_menu'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProfileSection(
          title: 'Community & Gamification',
          items: [
            _ProfileItem(
              icon: Icons.leaderboard,
              label: 'Classifica Utenti',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.campaign,
              label: 'Sfide Community',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.military_tech,
              label: 'Bacheca Trofei & Livelli',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
          ],
        ),
        _ProfileSection(
          title: 'Performance & Dati',
          items: [
            const _ProfileItem(
              icon: Icons.emoji_events,
              label: 'Record',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            const _ProfileItem(
              icon: Icons.track_changes,
              label: 'Obiettivi',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.trending_up,
              label: 'Progressi',
              onTap: () => context.push('/profile/progress'),
            ),
          ],
        ),
        const _ProfileSection(
          title: 'Allenamento',
          items: [
            _ProfileItem(
              icon: Icons.favorite,
              label: 'Esercizi Preferiti',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.calendar_today,
              label: 'Programma attuale',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.event_repeat,
              label: 'Calendario ciclo',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
          ],
        ),
        const _ProfileSection(
          title: 'Palestra',
          items: [
            _ProfileItem(
              icon: Icons.workspace_premium,
              label: 'Abbonamento',
              trailingText: 'FREE',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.qr_code,
              label: 'QR Check-in',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsMenu(
    BuildContext context,
    ThemeData theme,
    TrainingState trainingState,
  ) {
    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};
    final isAudioEnabled = settings['audio_effects'] == 'true';
    final isVibrationEnabled = settings['vibration'] == 'true';

    return Column(
      key: const ValueKey('settings_menu'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Section
        _ProfileSection(
          title: 'Account',
          items: [
            _ProfileItem(
              icon: Icons.person,
              label: 'Modifica Profilo',
              onTap: () => context.push('/profile/edit'),
            ),
            _ProfileItem(
              icon: Icons.lock,
              label: 'Sicurezza',
              onTap: () => context.push('/profile/security'),
            ),
            const _ProfileItem(
              icon: Icons.payments_outlined,
              label: 'Gestione pagamenti',
              trailingText: 'FREE',
              isBadge: true,
            ),
          ],
        ),

        // Training Settings
        _buildTrainingSettings(context, trainingState),
        // App Preferences
        _ProfileSection(
          title: 'Preferenze App',
          items: [
            const _ProfileItem(
              icon: Icons.dark_mode,
              label: 'Dark Mode',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            const _ProfileItem(
              icon: Icons.language,
              label: 'Lingua',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            const _ProfileItem(
              icon: Icons.notifications,
              label: 'Notifiche',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.volume_up_rounded,
              label: 'Effetti Audio',
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isAudioEnabled,
                  onChanged: (val) {
                    context.read<TrainingBloc>().add(
                          UpdatePreferenceEvent(
                            'audio_effects',
                            val.toString(),
                          ),
                        );
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ),
            ),
            _ProfileItem(
              icon: Icons.vibration_rounded,
              label: 'Vibrazione',
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isVibrationEnabled,
                  onChanged: (val) {
                    context.read<TrainingBloc>().add(
                          UpdatePreferenceEvent('vibration', val.toString()),
                        );
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        // Community & Feedback
        const _ProfileSection(
          title: 'Community & Feedback',
          items: [
            _ProfileItem(
              icon: Icons.star_rounded,
              label: 'Valuta GymCorpus',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.bug_report_rounded,
              label: 'Segnala un Problema',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.gavel_rounded,
              label: 'Termini di Servizio',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            _ProfileItem(
              icon: Icons.privacy_tip_rounded,
              label: 'Privacy Policy',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
              },
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('DISCONNETTI ACCOUNT'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 22),
                backgroundColor:
                    theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                foregroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color:
                        theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  ),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 13,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTimerPickerSheet(BuildContext context, String currentTimer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TimerPickerSheet(initialValue: currentTimer),
    );
  }

  void _showUnitPickerSheet(BuildContext context, String currentUnit) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _UnitPickerSheet(initialUnit: currentUnit),
    );
  }

  Widget _buildPhysicalStats(
    BuildContext context,
    ThemeData theme,
    UserEntity? user,
    TrainingState trainingState,
  ) {
    if (user == null) return const SizedBox.shrink();

    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';
    final latestWeight = trainingState is TrainingLoaded &&
            trainingState.bodyWeightLogs.isNotEmpty
        ? trainingState.bodyWeightLogs.first.weight
        : user.weight;

    var weightLabel = '? kg';
    if (latestWeight != null) {
      final value =
          isImperial ? UnitConverter.kgToLb(latestWeight) : latestWeight;
      weightLabel = '${value.toStringAsFixed(1)}${isImperial ? 'lb' : 'kg'}';
    }

    var heightLabel = '? cm';
    final heightValue = user.height;
    if (heightValue != null) {
      final value =
          isImperial ? UnitConverter.cmToInch(heightValue) : heightValue;
      heightLabel = '${value.toInt()}${isImperial ? 'in' : 'cm'}';
    }

    var age = '? anni';
    if (user.birthDate != null) {
      final now = DateTime.now();
      final birthDate = user.birthDate!;
      var calculatedAge = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        calculatedAge--;
      }
      age = '$calculatedAge anni';
    }

    final hasMissingData =
        latestWeight == null || user.height == null || user.birthDate == null;

    return GestureDetector(
      onTap: hasMissingData ? () => context.push('/profile/edit') : null,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatItem(Icons.monitor_weight_outlined, weightLabel, theme),
          _buildStatItem(Icons.height, heightLabel, theme),
          _buildStatItem(Icons.cake_outlined, age, theme),
        ],
      ),
    );
  }

  Widget _buildTrainingSettings(BuildContext context, TrainingState state) {
    final settings =
        state is TrainingLoaded ? state.settings : <String, String>{};
    final restTimer = settings['rest_timer'] ?? '90';
    final unit = settings['units'] ?? 'KG';

    return _ProfileSection(
      title: 'Impostazioni Allenamento',
      items: [
        _ProfileItem(
          icon: Icons.timer,
          label: 'Timer di Recupero',
          trailingText: '${restTimer}s',
          onTap: () => _showTimerPickerSheet(context, restTimer),
        ),
        _ProfileItem(
          icon: Icons.straighten,
          label: 'UnitÃ  di Misura',
          trailingText: unit == 'LB' ? 'Lb / inch' : 'Kg / cm',
          onTap: () => _showUnitPickerSheet(context, unit),
        ),
        _ProfileItem(
          icon: Icons.sync,
          label: 'Integrazioni Salute',
          onTap: () => context.push('/profile/integrations'),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: icon == Icons.monitor_weight_outlined
                ? theme.colorScheme.primary
                : (icon == Icons.height
                    ? theme.colorScheme.tertiary
                    : Colors.orangeAccent),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'Lexend',
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.items});

  final String title;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.05),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemBuilder: (context, index) => items[index],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.label,
    this.trailingText,
    this.trailing,
    this.isBadge = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final Widget? trailing;
  final bool isBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComingSoon = isBadge && trailingText == 'Prossimamente';
    final iconColor = isComingSoon
        ? theme.colorScheme.outline
        : label == 'Sicurezza' || label == 'Esercizi Preferiti'
            ? theme.colorScheme.tertiary
            : (label == 'Valuta GymCorpus'
                ? Colors.orangeAccent
                : theme.colorScheme.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isComingSoon ? theme.colorScheme.outline : null,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                if (isBadge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isComingSoon
                          ? theme.colorScheme.outline.withValues(alpha: 0.12)
                          : theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trailingText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isComingSoon
                            ? theme.colorScheme.outline
                            : theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else
                  Text(
                    trailingText!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
              if (trailing != null) trailing!,
              if (trailingText == null && trailing == null && !isBadge)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPickerSheet extends StatefulWidget {
  const _TimerPickerSheet({required this.initialValue});
  final String initialValue;

  @override
  State<_TimerPickerSheet> createState() => _TimerPickerSheetState();
}

class _TimerPickerSheetState extends State<_TimerPickerSheet> {
  late int _value;
  @override
  void initState() {
    super.initState();
    // Clamp initial value to handle potential 0 or out of range values
    _value = (int.tryParse(widget.initialValue) ?? 90).clamp(1, 300);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timer di Recupero',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          RadialTimerPicker(
            initialSeconds: _value,
            size: 260,
            onChanged: (val) {
              setState(() => _value = val);
            },
          ),
          const SizedBox(height: 32),
          // Save Button
          Padding(
            padding: EdgeInsets.fromLTRB(48, 0, 48, 24 + bottomPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TrainingBloc>().add(
                        UpdatePreferenceEvent('rest_timer', _value.toString()),
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'APPLICA MODIFICHE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitPickerSheet extends StatefulWidget {
  const _UnitPickerSheet({required this.initialUnit});
  final String initialUnit;

  @override
  State<_UnitPickerSheet> createState() => _UnitPickerSheetState();
}

class _UnitPickerSheetState extends State<_UnitPickerSheet> {
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialUnit.toUpperCase();
    if (_selectedUnit != 'KG' && _selectedUnit != 'LB') {
      _selectedUnit = 'KG';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UnitÃ  di Misura',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _UnitCard(
                    title: 'Metrico',
                    subtitle: 'Kg / cm',
                    isSelected: _selectedUnit == 'KG',
                    onTap: () => setState(() => _selectedUnit = 'KG'),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _UnitCard(
                    title: 'Imperiale',
                    subtitle: 'Lb / inch',
                    isSelected: _selectedUnit == 'LB',
                    onTap: () => setState(() => _selectedUnit = 'LB'),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          // Save Button
          Padding(
            padding: EdgeInsets.fromLTRB(48, 0, 48, 24 + bottomPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<TrainingBloc>()
                      .add(UpdatePreferenceEvent('units', _selectedUnit));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'APPLICA MODIFICHE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.7)
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
