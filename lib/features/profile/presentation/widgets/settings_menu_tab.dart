import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/feedback_dialog.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_list_widgets.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_menu_tab.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/timer_picker_sheet.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/unit_picker_sheet.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Tab "Impostazioni" della ProfileScreen: account, preferenze allenamento,
/// preferenze app, community/feedback e logout.
class SettingsMenuTab extends StatelessWidget {
  const SettingsMenuTab({required this.trainingState, super.key});

  final TrainingState trainingState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = trainingState;
    final settings = state is TrainingLoaded
        ? state.settings
        : <String, String>{};
    final isAudioEnabled = settings['audio_effects'] == 'true';
    final isVibrationEnabled = settings['vibration'] == 'true';

    // Acceso di default per i profili femminili, come la voce nel menu: da
    // qui si accende o si spegne a prescindere dal sesso indicato.
    final cyclePreference = settings[ProfileMenuTab.cycleCalendarSetting];
    final isCycleCalendarEnabled = cyclePreference != null
        ? cyclePreference == 'true'
        : context.watch<AuthBloc>().state.maybeWhen(
            authenticated: (user, _) => user.gender == 'Donna',
            orElse: () => false,
          );

    return Column(
      key: const ValueKey('settings_menu'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Section
        ProfileSection(
          title: 'Account',
          items: [
            ProfileItem(
              icon: Icons.person,
              label: 'Modifica Profilo',
              onTap: () => context.push('/profile/edit'),
            ),
            ProfileItem(
              icon: Icons.lock,
              label: 'Sicurezza',
              tone: ProfileItemTone.secondary,
              onTap: () => context.push('/profile/security'),
            ),
            const ProfileItem(
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
        ProfileSection(
          title: 'Preferenze App',
          items: [
            const ProfileItem(
              icon: Icons.dark_mode,
              label: 'Dark Mode',
              trailingText: 'Prossimamente',
              isComingSoon: true,
              isBadge: true,
            ),
            const ProfileItem(
              icon: Icons.language,
              label: 'Lingua',
              trailingText: 'Prossimamente',
              isComingSoon: true,
              isBadge: true,
            ),
            ProfileItem(
              icon: Icons.notifications,
              label: 'Notifiche',
              onTap: () => context.push('/profile/notifications'),
            ),
            ProfileItem(
              icon: Icons.volume_up_rounded,
              label: 'Effetti Audio',
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isAudioEnabled,
                  onChanged: (val) {
                    context.read<TrainingBloc>().add(
                      UpdatePreferenceEvent('audio_effects', val.toString()),
                    );
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ),
            ),
            ProfileItem(
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
            ProfileItem(
              icon: Icons.auto_awesome_rounded,
              label: 'Calendario ciclo',
              tone: ProfileItemTone.cycle,
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isCycleCalendarEnabled,
                  onChanged: (val) {
                    context.read<TrainingBloc>().add(
                      UpdatePreferenceEvent(
                        ProfileMenuTab.cycleCalendarSetting,
                        val.toString(),
                      ),
                    );
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        // Community & Feedback
        ProfileSection(
          title: 'Community & Feedback',
          items: [
            const ProfileItem(
              icon: Icons.star_rounded,
              label: 'Valuta GymCorpus',
              trailingText: 'Prossimamente',
              isComingSoon: true,
              isBadge: true,
            ),
            ProfileItem(
              icon: Icons.bug_report_rounded,
              label: 'Segnala un Problema',
              onTap: () => showFeedbackSheet(context),
            ),
            ProfileItem(
              icon: Icons.gavel_rounded,
              label: 'Termini di Servizio',
              onTap: () => context.push('/profile/terms'),
            ),
            ProfileItem(
              icon: Icons.privacy_tip_rounded,
              label: 'Privacy Policy',
              onTap: () => context.push('/profile/privacy'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.xl,
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
                backgroundColor: theme.colorScheme.errorContainer.withValues(
                  alpha: 0.1,
                ),
                foregroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.xl,
                  side: BorderSide(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.3,
                    ),
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

  Widget _buildTrainingSettings(BuildContext context, TrainingState state) {
    final settings = state is TrainingLoaded
        ? state.settings
        : <String, String>{};
    final restTimer = settings['rest_timer'] ?? '90';
    final unit = settings['units'] ?? 'KG';

    return ProfileSection(
      title: 'Impostazioni Allenamento',
      items: [
        ProfileItem(
          icon: Icons.timer,
          label: 'Timer di Recupero',
          trailingText: '${restTimer}s',
          onTap: () => _showTimerPickerSheet(context, restTimer),
        ),
        ProfileItem(
          icon: Icons.straighten,
          label: 'Unità di Misura',
          trailingText: unit == 'LB' ? 'Lb / inch' : 'Kg / cm',
          onTap: () => _showUnitPickerSheet(context, unit),
        ),
        ProfileItem(
          icon: Icons.sync,
          label: 'Integrazioni Salute',
          onTap: () => context.push('/profile/integrations'),
        ),
      ],
    );
  }

  void _showTimerPickerSheet(BuildContext context, String currentTimer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TimerPickerSheet(initialValue: currentTimer),
    );
  }

  void _showUnitPickerSheet(BuildContext context, String currentUnit) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => UnitPickerSheet(initialUnit: currentUnit),
    );
  }
}
