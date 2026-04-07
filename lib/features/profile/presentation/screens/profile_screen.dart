import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
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
              const SizedBox(height: 32),

              // User Profile Quick Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final user = state.maybeWhen(
                      authenticated: (user) => user,
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
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lexend',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                user?.username != null ? '@${user!.username}' : 'LIVELLO 1',
                                style: theme.textTheme.labelSmall?.copyWith(
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
              ),

              const SizedBox(height: 32),

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
                        onEdit: () => _showTimerDialog(context, restTimer),
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

  void _showTimerDialog(BuildContext context, String currentTimer) {
    final controller = TextEditingController(text: currentTimer);
    final theme = Theme.of(context);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Timer di Recupero', style: TextStyle(fontFamily: 'Lexend')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'secondi'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
          ElevatedButton(
            onPressed: () {
              context.read<TrainingBloc>().add(UpdatePreferenceEvent('rest_timer', controller.text));
              Navigator.pop(context);
            },
            child: const Text('SALVA'),
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
    this.onEdit,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final bool isBadge;
  final bool isExternal;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onEdit,
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
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  color: theme.colorScheme.outline,
                  onPressed: onEdit,
                ),
              if (onEdit == null && !isBadge)
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
