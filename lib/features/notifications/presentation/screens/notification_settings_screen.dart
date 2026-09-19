import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/services/notification_service.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:gym_corpus/features/notifications/presentation/widgets/notification_tiles.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  // Stretching
  bool _stretchingEnabled = false;
  TimeOfDay _stretchingTime = const TimeOfDay(hour: 8, minute: 0);

  // Training
  bool _trainingEnabled = false;
  TimeOfDay _trainingTime = const TimeOfDay(hour: 17, minute: 30);
  List<int> _trainingDays = []; // 1=Lun, 7=Dom

  // Badge
  bool _badgeEnabled = true;
  bool _systemNotificationsEnabled = true;

  bool get _effectiveStretchingEnabled =>
      _systemNotificationsEnabled && _stretchingEnabled;
  bool get _effectiveTrainingEnabled =>
      _systemNotificationsEnabled && _trainingEnabled;
  bool get _effectiveBadgeEnabled =>
      _systemNotificationsEnabled && _badgeEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFromSettings();
    _refreshPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionStatus();
    }
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

  Future<void> _refreshPermissionStatus() async {
    final enabled = await NotificationService.instance
        .areNotificationsEnabled();
    if (!mounted) return;
    setState(() => _systemNotificationsEnabled = enabled);
  }

  Future<void> _openSystemSettings() async {
    await NotificationService.instance.openNotificationSettings();
  }

  Future<void> _showPermissionDeniedMessage() async {
    if (!mounted) return;
    AppSnackBar.show(
      context,
      'Le notifiche di sistema sono disattivate. '
      'Attivale nelle impostazioni del telefono.',
      tone: AppSnackBarTone.warning,
      actionLabel: 'Impostazioni',
      onAction: _openSystemSettings,
    );
  }

  Future<void> _toggleStretching(bool enabled) async {
    setState(() => _stretchingEnabled = enabled);

    if (enabled) {
      await NotificationService.instance.requestPermissions();
      final systemEnabled = await NotificationService.instance
          .areNotificationsEnabled();
      if (!mounted) return;
      setState(() => _systemNotificationsEnabled = systemEnabled);
      if (!systemEnabled) {
        setState(() => _stretchingEnabled = false);
        _savePref('notif_stretching_enabled', 'false');
        await _showPermissionDeniedMessage();
        return;
      }
      _savePref('notif_stretching_enabled', 'true');
      _savePref('notif_stretching_hour', _stretchingTime.hour.toString());
      _savePref('notif_stretching_minute', _stretchingTime.minute.toString());
      context.read<NotificationsBloc>().add(
        ScheduleStretchingReminderEvent(
          hour: _stretchingTime.hour,
          minute: _stretchingTime.minute,
        ),
      );
    } else {
      _savePref('notif_stretching_enabled', 'false');
      context.read<NotificationsBloc>().add(CancelStretchingReminderEvent());
    }
  }

  Future<void> _pickStretchingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _stretchingTime,
    );
    if (picked == null) return;
    // Il selettore e' modale: se l'utente lascia la schermata mentre e'
    // aperto, il widget risulta smontato e ogni accesso al context fallisce.
    if (!mounted) return;

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

  Future<void> _toggleTraining(bool enabled) async {
    setState(() => _trainingEnabled = enabled);

    if (enabled && _trainingDays.isEmpty) {
      final defaultDay = DateTime.now().weekday;
      setState(() => _trainingDays = [defaultDay]);
      _savePref('notif_training_days', _trainingDays.join(','));
    }

    if (enabled && _trainingDays.isNotEmpty) {
      await NotificationService.instance.requestPermissions();
      final systemEnabled = await NotificationService.instance
          .areNotificationsEnabled();
      if (!mounted) return;
      setState(() => _systemNotificationsEnabled = systemEnabled);
      if (!systemEnabled) {
        setState(() => _trainingEnabled = false);
        _savePref('notif_training_enabled', 'false');
        await _showPermissionDeniedMessage();
        return;
      }
      _savePref('notif_training_enabled', 'true');
      _savePref('notif_training_hour', _trainingTime.hour.toString());
      _savePref('notif_training_minute', _trainingTime.minute.toString());
      context.read<NotificationsBloc>().add(
        ScheduleTrainingReminderEvent(
          hour: _trainingTime.hour,
          minute: _trainingTime.minute,
          days: _trainingDays,
        ),
      );
    } else {
      _savePref('notif_training_enabled', 'false');
      context.read<NotificationsBloc>().add(CancelTrainingReminderEvent());
    }
  }

  Future<void> _pickTrainingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _trainingTime,
    );
    if (picked == null) return;
    if (!mounted) return;

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
    if (enabled && !_systemNotificationsEnabled) {
      _showPermissionDeniedMessage();
      return;
    }
    setState(() => _badgeEnabled = enabled);
    _savePref('notif_badge_enabled', enabled.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TrainingBloc, TrainingState>(
      listenWhen: (previous, current) =>
          previous is TrainingLoaded &&
              current is TrainingLoaded &&
              previous.settings != current.settings ||
          previous is! TrainingLoaded && current is TrainingLoaded,
      listener: (context, state) {
        if (state is TrainingLoaded) {
          _loadFromSettings();
        }
        _refreshPermissionStatus();
      },
      child: Scaffold(
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
          title: const GradientTitle(
            'Notifiche',
            scale: GradientTitleScale.compact,
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _systemNotificationsEnabled
                      ? const Color(0xFF8DE8C7).withValues(alpha: 0.10)
                      : theme.colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: _systemNotificationsEnabled
                        ? const Color(0xFF8DE8C7).withValues(alpha: 0.30)
                        : theme.colorScheme.error.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _systemNotificationsEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      color: _systemNotificationsEnabled
                          ? const Color(0xFF4EBE98)
                          : theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _systemNotificationsEnabled
                                ? 'Notifiche di sistema attive'
                                : 'Notifiche di sistema disattivate',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _systemNotificationsEnabled
                                ? 'I reminder possono essere inviati dal telefono.'
                                : 'Attivale nelle impostazioni del telefono per ricevere i reminder.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              height: 1.35,
                            ),
                          ),
                          if (!_systemNotificationsEnabled) ...[
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _openSystemSettings,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('APRI IMPOSTAZIONI'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Stretching section
              const NotificationSectionHeader(
                icon: Icons.self_improvement_rounded,
                color: Color(0xFF8DE8C7),
                title: 'STRETCHING GIORNALIERO',
              ),
              const SizedBox(height: 16),
              NotificationCard(
                children: [
                  NotificationSwitchTile(
                    label: 'Promemoria Stretching',
                    subtitle: 'Ricevi un promemoria giornaliero',
                    value: _effectiveStretchingEnabled,
                    onChanged: _toggleStretching,
                  ),
                  if (_effectiveStretchingEnabled) ...[
                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    NotificationTimeTile(
                      label: 'Orario',
                      time: _stretchingTime,
                      onTap: _pickStretchingTime,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Training section
              NotificationSectionHeader(
                icon: Icons.fitness_center_rounded,
                color: theme.colorScheme.primary,
                title: 'ALLENAMENTO',
              ),
              const SizedBox(height: 16),
              NotificationCard(
                children: [
                  NotificationSwitchTile(
                    label: 'Promemoria Allenamento',
                    subtitle: 'Ricevi un promemoria nei giorni previsti',
                    value: _effectiveTrainingEnabled,
                    onChanged: _toggleTraining,
                  ),
                  if (_effectiveTrainingEnabled) ...[
                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    NotificationTimeTile(
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
                          WeekDaySelector(
                            selectedDays: _trainingDays.toSet(),
                            onToggle: _toggleDay,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Badge section
              const NotificationSectionHeader(
                icon: Icons.emoji_events_rounded,
                color: AppPalette.gold,
                title: 'BADGE & TRAGUARDI',
              ),
              const SizedBox(height: 16),
              NotificationCard(
                children: [
                  NotificationSwitchTile(
                    label: 'Notifiche Badge',
                    subtitle:
                        'Ricevi una notifica quando sblocchi un nuovo badge',
                    value: _effectiveBadgeEnabled,
                    onChanged: _toggleBadge,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Other notifications info
              NotificationSectionHeader(
                icon: Icons.info_outline_rounded,
                color: theme.colorScheme.outline,
                title: 'ALTRE NOTIFICHE',
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
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
                        "I promemoria compaiono nell'hub del telefono all'orario previsto. "
                        "Il centro notifiche interno mostra gli eventi reali dell'app, non le sole conferme di impostazione.",
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
      ),
    );
  }
}
