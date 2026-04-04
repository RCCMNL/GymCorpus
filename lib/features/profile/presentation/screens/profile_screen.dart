import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
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
                      letterSpacing: 2.0,
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
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surfaceContainerHighest,
                            border: Border.all(color: theme.colorScheme.primary, width: 2),
                          ),
                          child: Icon(Icons.person, color: theme.colorScheme.primary, size: 40),
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
                            child: Icon(Icons.verified, size: 12, color: theme.colorScheme.onTertiaryContainer),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atleta Gym',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          Text(
                            'LIVELLO 1 • IN SVILUPPO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Account Section
              const _ProfileSection(
                title: 'Account (In Sviluppo)',
                items: [
                  _ProfileItem(icon: Icons.person, label: 'Modifica Profilo'),
                  _ProfileItem(icon: Icons.lock, label: 'Sicurezza'),
                  _ProfileItem(
                    icon: Icons.workspace_premium,
                    label: 'Abbonamento',
                    trailingText: 'FREE',
                    isBadge: true,
                  ),
                ],
              ),

              // Training Settings
              _ProfileSection(
                title: 'Impostazioni Allenamento',
                items: [
                  _ProfileItem(
                    icon: Icons.timer,
                    label: 'Timer di Recupero',
                    trailingText: '90s (Legacy)',
                    onEdit: () {},
                  ),
                  const _ProfileItem(
                    icon: Icons.straighten,
                    label: 'Units',
                    trailingText: 'Metric / KG',
                  ),
                  const _ProfileItem(
                    icon: Icons.sync,
                    label: 'Sync with Health Apps',
                    hasSwitch: true,
                    switchValue: true,
                  ),
                ],
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
                    trailingText: 'English',
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
                  onPressed: () {},
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
                      letterSpacing: 2.0,
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
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;

  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
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
              separatorBuilder: (context, index) => const SizedBox(height: 0), // No-Line rule: No visible dividers.
              itemBuilder: (context, index) => items[index],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final bool isBadge;
  final bool isExternal;
  final bool hasSwitch;
  final bool switchValue;
  final VoidCallback? onEdit;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.trailingText,
    this.isBadge = false,
    this.isExternal = false,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasSwitch ? null : () {},
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
              if (hasSwitch)
                Switch(
                  value: switchValue,
                  onChanged: (v) {},
                  activeThumbColor: theme.colorScheme.primary,
                ),
              if (!hasSwitch && !isBadge && onEdit == null)
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
