import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/radial_timer_picker.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profilo',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'APP PREFERENCES & ACCOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // User Profile Quick Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final user = state.maybeWhen(
                      authenticated: (user) => user,
                      loading: (previousUser) => previousUser,
                      error: (message, previousUser) => previousUser,
                      orElse: () => null,
                    );
                    final userName = user?.name ?? 'Guest';
                    final photoUrl = user?.photoUrl;

                    return Row(
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
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                                  image: photoUrl != null
                                      ? DecorationImage(
                                          image: photoUrl.startsWith('http')
                                              ? NetworkImage(photoUrl)
                                              : FileImage(File(photoUrl)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: photoUrl == null
                                    ? Icon(Icons.person, color: theme.colorScheme.primary, size: 40)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.colorScheme.surface, width: 4),
                                  ),
                                  child: Icon(
                                    photoUrl != null ? Icons.edit : Icons.add_a_photo,
                                    size: 12,
                                    color: theme.colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lexend',
                                  fontSize: 22, // Increased for better readability
                                ),
                                maxLines: 2,
                                softWrap: true,
                              ),
                              const SizedBox(height: 8),
                              _buildPhysicalStats(context, theme, user),
                              const SizedBox(height: 12),
                              if (user?.username != null) ...[
                                Text(
                                  '@${user!.username}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    fontFamily: 'Lexend',
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                'LIVELLO 1',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  fontFamily: 'Lexend',
                                  color: theme.colorScheme.outline,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ), const SizedBox(height: 32),

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
                    icon: Icons.workspace_premium,
                    label: 'Abbonamento',
                    trailingText: 'FREE',
                    isBadge: true,
                  ),
                ],
              ),

              // Training Settings
              BlocBuilder<TrainingBloc, TrainingState>(
                builder: (context, state) {
                  final settings = state is TrainingLoaded ? state.settings : <String, String>{};
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
                        label: 'Unità di Misura',
                        trailingText: 'Metric / $unit',
                        onTap: () {
                           final nextUnit = unit == 'KG' ? 'LB' : 'KG';
                           context.read<TrainingBloc>().add(UpdatePreferenceEvent('units', nextUnit));
                        },
                      ),
                      _ProfileItem(
                        icon: Icons.sync,
                        label: 'Integrazioni Salute',
                        onTap: () => context.push('/profile/integrations'),
                      ),
                    ],
                  );
                },
              ),

              // App Preferences
              const _ProfileSection(
                title: 'App Preferences',
                items: [
                  _ProfileItem(
                    icon: Icons.dark_mode,
                    label: 'Dark Mode',
                    trailingText: 'ALWAYS ON',
                  ),
                  _ProfileItem(icon: Icons.notifications, label: 'Notifications'),
                  _ProfileItem(
                    icon: Icons.language,
                    label: 'Language',
                    trailingText: 'Italiano',
                  ),
                ],
              ),

              // Support & Legal
              const _ProfileSection(
                title: 'Support & Legal',
                items: [
                  _ProfileItem(icon: Icons.help, label: 'Help Center', isExternal: true),
                  _ProfileItem(icon: Icons.gavel, label: 'Terms of Service'),
                ],
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('LOGOUT'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                    foregroundColor: theme.colorScheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.colorScheme.errorContainer.withValues(alpha: 0.2)),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for nav
            ],
          ),
        ),
      ),
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

  Widget _buildPhysicalStats(BuildContext context, ThemeData theme, UserEntity? user) {
    if (user == null) return const SizedBox.shrink();

    final weight = user.weight != null ? '${user.weight}kg' : '? kg';
    final heightValue = user.height;
    final height = heightValue != null ? '${heightValue.toInt()}cm' : '? cm';
    
    String age = '? anni';
    if (user.birthDate != null) {
      final now = DateTime.now();
      final birthDate = user.birthDate!;
      int calculatedAge = now.year - birthDate.year;
      if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
        calculatedAge--;
      }
      age = '$calculatedAge anni';
    }

    final hasMissingData = user.weight == null || user.height == null || user.birthDate == null;

    return GestureDetector(
      onTap: hasMissingData ? () => context.push('/profile/edit') : null,
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          _buildStatItem(Icons.monitor_weight_outlined, weight, theme),
          _buildStatItem(Icons.height, height, theme),
          _buildStatItem(Icons.cake_outlined, age, theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            fontFamily: 'Lexend',
          ),
        ),
      ],
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
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
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
    this.isBadge = false,
    this.isExternal = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final bool isBadge;
  final bool isExternal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                if (isBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trailingText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.tertiary,
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
              if (!isBadge)
                Icon(
                  isExternal ? Icons.open_in_new : Icons.chevron_right,
                  color: theme.colorScheme.outline,
                  size: 20,
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
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                  context.read<TrainingBloc>().add(UpdatePreferenceEvent('rest_timer', _value.toString()));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'APPLICA MODIFICHE',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
