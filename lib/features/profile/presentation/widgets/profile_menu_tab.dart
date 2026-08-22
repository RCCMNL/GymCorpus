import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_list_widgets.dart';

/// Tab "Profilo" della ProfileScreen: community, performance, allenamento
/// e sezioni della palestra.
class ProfileMenuTab extends StatelessWidget {
  const ProfileMenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('profile_menu'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSection(
          title: 'Community & Gamification',
          items: [
            const ProfileItem(
              icon: Icons.leaderboard,
              label: 'Classifica Utenti',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            const ProfileItem(
              icon: Icons.campaign,
              label: 'Sfide Community',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            ProfileItem(
              icon: Icons.military_tech,
              label: 'Bacheca Trofei & Livelli',
              onTap: () => context.push('/profile/trophies'),
            ),
          ],
        ),
        ProfileSection(
          title: 'Performance & Dati',
          items: [
            ProfileItem(
              icon: Icons.emoji_events,
              label: 'Record',
              onTap: () => context.push('/profile/records'),
            ),
            const ProfileItem(
              icon: Icons.track_changes,
              label: 'Obiettivi',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            ProfileItem(
              icon: Icons.trending_up,
              label: 'Progressi',
              onTap: () => context.push('/profile/progress'),
            ),
          ],
        ),
        ProfileSection(
          title: 'Allenamento',
          items: [
            ProfileItem(
              icon: Icons.favorite,
              label: 'Esercizi Preferiti',
              onTap: () => context.push('/profile/favorites'),
            ),
            const ProfileItem(
              icon: Icons.calendar_today,
              label: 'Programma attuale',
              trailingText: 'Prossimamente',
              isBadge: true,
            ),
            ProfileItem(
              icon: Icons.auto_awesome_rounded,
              label: 'Calendario ciclo',
              trailingText: 'BETA',
              isBadge: true,
              onTap: () => context.push('/profile/cycle-calendar'),
            ),
          ],
        ),
        const ProfileSection(
          title: 'Palestra',
          items: [
            ProfileItem(
              icon: Icons.workspace_premium,
              label: 'Abbonamento',
              trailingText: 'FREE',
              isBadge: true,
            ),
            ProfileItem(
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
}
