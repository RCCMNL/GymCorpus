import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Stretching
  bool _stretchingEnabled = false;
  TimeOfDay _stretchingTime = const TimeOfDay(hour: 8, minute: 0);

  // Training
  bool _trainingEnabled = false;
  TimeOfDay _trainingTime = const TimeOfDay(hour: 17, minute: 30);
  List<int> _trainingDays = []; // 1=Lun, 7=Dom

  // Badge
  bool _badgeEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadFromSettings();
  }

  void _loadFromSettings() {
    final trainingState = context.read<TrainingBloc>().state;
    if (trainingState is! TrainingLoaded) return;

    final settings = trainingState.settings;

    setState(() {
      _stretchingEnabled = settings['notif_stretching_enabled'] == 'true';
      final stretchH = int.tryParse(settings['notif_stretching_hour'] ?? '');
      final stretchM = int.tryParse(settings['notif_stretching_minute'] ?? '');
      if (stretchH != null && stretchM != null) {
        _stretchingTime = TimeOfDay(hour: stretchH, minute: stretchM);
      }

      _trainingEnabled = settings['notif_training_enabled'] == 'true';
      final trainH = int.tryParse(settings['notif_training_hour'] ?? '');
      final trainM = int.tryParse(settings['notif_training_minute'] ?? '');
      if (trainH != null && trainM != null) {
        _trainingTime = TimeOfDay(hour: trainH, minute: trainM);
      }

      final daysStr = settings['notif_training_days'] ?? '';
      if (daysStr.isNotEmpty) {
        _trainingDays = daysStr
            .split(',')
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>()
            .toList();
      }

      _badgeEnabled = settings['notif_badge_enabled'] != 'false';
    });
  }

  void _savePref(String key, String value) {
    context.read<TrainingBloc>().add(UpdatePreferenceEvent(key, value));
  }

  void _toggleStretching(bool enabled) {
    setState(() => _stretchingEnabled = enabled);
    _savePref('notif_stretching_enabled', enabled.toString());

    if (enabled) {
      context.read<NotificationsBloc>().add(
            ScheduleStretchingReminderEvent(
              hour: _stretchingTime.hour,
              minute: _stretchingTime.minute,
            ),
          );
    } else {
      context.read<NotificationsBloc>().add(CancelStretchingReminderEvent());
    }
  }

  Future<void> _pickStretchingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _stretchingTime,
    );
    if (picked == null) return;

    setState(() => _stretchingTime = picked);
    _savePref('notif_stretching_hour', picked.hour.toString());
    _savePref('notif_stretching_minute', picked.minute.toString());

    if (_stretchingEnabled) {
      context.read<NotificationsBloc>().add(
            ScheduleStretchingReminderEvent(
              hour: picked.hour,
              minute: picked.minute,
            ),
          );
    }
  }

  void _toggleTraining(bool enabled) {
    setState(() => _trainingEnabled = enabled);
    _savePref('notif_training_enabled', enabled.toString());

    if (enabled && _trainingDays.isNotEmpty) {
      context.read<NotificationsBloc>().add(
            ScheduleTrainingReminderEvent(
              hour: _trainingTime.hour,
              minute: _trainingTime.minute,
              days: _trainingDays,
            ),
          );
    } else {
      context.read<NotificationsBloc>().add(CancelTrainingReminderEvent());
    }
  }

  Future<void> _pickTrainingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _trainingTime,
    );
    if (picked == null) return;

    setState(() => _trainingTime = picked);
    _savePref('notif_training_hour', picked.hour.toString());
    _savePref('notif_training_minute', picked.minute.toString());

    if (_trainingEnabled && _trainingDays.isNotEmpty) {
      context.read<NotificationsBloc>().add(
            ScheduleTrainingReminderEvent(
              hour: picked.hour,
              minute: picked.minute,
              days: _trainingDays,
            ),
          );
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_trainingDays.contains(day)) {
        _trainingDays.remove(day);
      } else {
        _trainingDays.add(day);
      }
      _trainingDays.sort();
    });
    _savePref('notif_training_days', _trainingDays.join(','));

    if (_trainingEnabled && _trainingDays.isNotEmpty) {
      context.read<NotificationsBloc>().add(
            ScheduleTrainingReminderEvent(
              hour: _trainingTime.hour,
              minute: _trainingTime.minute,
              days: _trainingDays,
            ),
          );
    } else if (_trainingDays.isEmpty) {
      context.read<NotificationsBloc>().add(CancelTrainingReminderEvent());
    }
  }

  void _toggleBadge(bool enabled) {
    setState(() => _badgeEnabled = enabled);
    _savePref('notif_badge_enabled', enabled.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          ).createShader(bounds),
          child: Text(
            'Notifiche',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stretching section
            _buildSectionHeader(
              theme,
              icon: Icons.self_improvement_rounded,
              color: const Color(0xFF8DE8C7),
              title: 'STRETCHING GIORNALIERO',
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              theme,
              children: [
                _buildSwitchTile(
                  theme,
                  label: 'Promemoria Stretching',
                  subtitle: 'Ricevi un promemoria giornaliero',
                  value: _stretchingEnabled,
                  onChanged: _toggleStretching,
                ),
                if (_stretchingEnabled) ...[
                  Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  _buildTimeTile(
                    theme,
                    label: 'Orario',
                    time: _stretchingTime,
                    onTap: _pickStretchingTime,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),

            // Training section
            _buildSectionHeader(
              theme,
              icon: Icons.fitness_center_rounded,
              color: theme.colorScheme.primary,
              title: 'ALLENAMENTO',
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              theme,
              children: [
                _buildSwitchTile(
                  theme,
                  label: 'Promemoria Allenamento',
                  subtitle: 'Ricevi un promemoria nei giorni previsti',
                  value: _trainingEnabled,
                  onChanged: _toggleTraining,
                ),
                if (_trainingEnabled) ...[
                  Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  _buildTimeTile(
                    theme,
                    label: 'Orario',
                    time: _trainingTime,
                    onTap: _pickTrainingTime,
                  ),
                  Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giorni di allenamento',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDaySelector(theme),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),

            // Badge section
            _buildSectionHeader(
              theme,
              icon: Icons.emoji_events_rounded,
              color: Colors.orangeAccent,
              title: 'BADGE & TRAGUARDI',
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              theme,
              children: [
                _buildSwitchTile(
                  theme,
                  label: 'Notifiche Badge',
                  subtitle:
                      'Ricevi una notifica quando sblocchi un nuovo badge',
                  value: _badgeEnabled,
                  onChanged: _toggleBadge,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Other notifications info
            _buildSectionHeader(
              theme,
              icon: Icons.info_outline_rounded,
              color: theme.colorScheme.outline,
              title: 'ALTRE NOTIFICHE',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Le notifiche di sistema e aggiornamenti saranno '
                      'disponibili nelle prossime versioni.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme, {
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.outline.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(ThemeData theme,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(
    ThemeData theme, {
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'Lexend',
                fontSize: 14,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '$h:$m',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(ThemeData theme) {
    const dayLabels = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = index + 1; // 1=Mon .. 7=Sun
        final isSelected = _trainingDays.contains(day);

        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                dayLabels[index],
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.outline,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
