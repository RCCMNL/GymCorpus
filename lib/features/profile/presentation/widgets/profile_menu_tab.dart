import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_list_widgets.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Tab "Profilo" della ProfileScreen: community, performance, allenamento
/// e sezioni della palestra.
class ProfileMenuTab extends StatelessWidget {
  const ProfileMenuTab({super.key});

  /// Chiave della preferenza che accende o spegne il calendario ciclo.
  static const cycleCalendarSetting = 'cycle_calendar_enabled';

  /// Il calendario ciclo e' acceso di default per i profili femminili, ma
  /// chiunque puo' accenderlo o spegnerlo dalle impostazioni.
  ///
  /// Il sesso da solo non basta: chi indica "Altro" resterebbe tagliato
  /// fuori per sempre da una funzione che potrebbe volere.
  static bool _showsCycleCalendar(BuildContext context) {
    final state = context.watch<TrainingBloc>().state;
    final preference = state is TrainingLoaded
        ? state.settings[cycleCalendarSetting]
        : null;

    if (preference != null) return preference == 'true';

    return context.watch<AuthBloc>().state.maybeWhen(
      authenticated: (user, _) => user.gender == 'Donna',
      orElse: () => false,
    );
  }

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
            if (_showsCycleCalendar(context))
              ProfileItem(
                icon: Icons.auto_awesome_rounded,
                label: 'Calendario ciclo',
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
