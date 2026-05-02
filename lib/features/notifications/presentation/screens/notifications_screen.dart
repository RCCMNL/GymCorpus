import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/notifications/domain/entities/notification_log_entity.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  context
                      .read<NotificationsBloc>()
                      .add(MarkAllNotificationsReadEvent());
                },
                child: Text(
                  'SEGNA TUTTE LETTE',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.5,
                    fontFamily: 'Lexend',
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.notifications.isEmpty) {
            return _buildEmptyState(theme);
          }

          return _buildNotificationsList(context, theme, state.notifications);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nessuna notifica',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le tue notifiche appariranno qui.\n'
              'Badge sbloccati, promemoria e altro.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    ThemeData theme,
    List<NotificationLogEntity> notifications,
  ) {
    // Raggruppa per data
    final grouped = <String, List<NotificationLogEntity>>{};
    for (final n in notifications) {
      final key = _dateGroupLabel(n.timestamp);
      grouped.putIfAbsent(key, () => []).add(n);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, sectionIndex) {
        final label = grouped.keys.elementAt(sectionIndex);
        final items = grouped[label]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionIndex > 0) const SizedBox(height: 24),
            // Section header
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.outline.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ),
            ...items.map(
              (notification) => _NotificationTile(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    context.read<NotificationsBloc>().add(
                          MarkNotificationReadEvent(notification.id),
                        );
                  }
                },
                onDismissed: () {
                  context.read<NotificationsBloc>().add(
                        DeleteNotificationEvent(notification.id),
                      );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Oggi';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Ieri';
    if (now.difference(dateOnly).inDays < 7) {
      return DateFormat('EEEE', 'it_IT').format(date);
    }
    return DateFormat('d MMM yyyy', 'it_IT').format(date);
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  final NotificationLogEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  IconData _iconForType(String type) {
    switch (type) {
      case 'badge':
        return Icons.emoji_events_rounded;
      case 'stretching':
        return Icons.self_improvement_rounded;
      case 'training':
        return Icons.fitness_center_rounded;
      case 'recovery':
        return Icons.timer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type, ThemeData theme) {
    switch (type) {
      case 'badge':
        return Colors.orangeAccent;
      case 'stretching':
        return const Color(0xFF8DE8C7);
      case 'training':
        return theme.colorScheme.primary;
      case 'recovery':
        return const Color(0xFFFF8A3D);
      default:
        return theme.colorScheme.outline;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'badge':
        return 'Badge';
      case 'stretching':
        return 'Promemoria';
      case 'training':
        return 'Promemoria';
      case 'recovery':
        return 'Recupero';
      default:
        return 'Notifica';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(notification.type, theme);
    final timeStr = DateFormat('HH:mm').format(notification.timestamp);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.error,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? theme.colorScheme.surfaceContainerHigh
                : theme.colorScheme.surfaceContainerHigh
                    .withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? theme.colorScheme.outline.withValues(alpha: 0.05)
                  : color.withValues(alpha: 0.25),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: notification.isRead
                ? null
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              fontFamily: 'Lexend',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: color.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Text(
                            _labelForType(notification.type).toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              fontFamily: 'Lexend',
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeStr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
