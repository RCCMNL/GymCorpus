import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationPayloadData {
  const NotificationPayloadData({
    required this.type,
    required this.title,
    required this.body,
    this.source,
  });

  final String type;
  final String title;
  final String body;
  final String? source;

  String encode() => jsonEncode({
        'type': type,
        'title': title,
        'body': body,
        'source': source,
      });

  factory NotificationPayloadData.fromEncoded(String payload) {
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    return NotificationPayloadData(
      type: decoded['type'] as String? ?? 'general',
      title: decoded['title'] as String? ?? 'Notifica',
      body: decoded['body'] as String? ?? '',
      source: decoded['source'] as String?,
    );
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  static const MethodChannel _timezoneChannel =
      MethodChannel('gym_corpus/device_timezone');
  static const MethodChannel _settingsChannel =
      MethodChannel('gym_corpus/system_settings');

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationPayloadData> _tapController =
      StreamController<NotificationPayloadData>.broadcast();

  bool _tzInitialized = false;
  Stream<NotificationPayloadData> get notificationTapStream =>
      _tapController.stream;

  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
    'gym_corpus_channel',
    'Allenamenti e Notifiche',
    description: 'Notifiche relative agli allenamenti e nutrizione',
    importance: Importance.max,
  );

  static const AndroidNotificationChannel _scheduledChannel =
      AndroidNotificationChannel(
    'gym_corpus_scheduled',
    'Promemoria',
    description: 'Promemoria giornalieri per allenamento e stretching',
    importance: Importance.high,
  );

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        debugPrint('Notification tapped: $payload');
        if (payload == null || payload.isEmpty) return;
        try {
          _tapController.add(NotificationPayloadData.fromEncoded(payload));
        } catch (e) {
          debugPrint('Notification payload parse error: $e');
        }
      },
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_generalChannel);
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_scheduledChannel);

    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      await _configureLocalTimeZone();
      _tzInitialized = true;
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timezoneName = await _timezoneChannel.invokeMethod<String>(
        'getLocalTimezone',
      );
      if (timezoneName == null || timezoneName.isEmpty) return;
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
    } catch (e) {
      debugPrint('Timezone setup fallback: $e');
    }
  }

  Future<void> requestPermissions() async {
    final iosPermissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final androidPermissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    debugPrint(
      'Notification permissions requested - iOS: $iosPermissions, '
      'Android: $androidPermissions',
    );
  }

  Future<bool> areNotificationsEnabled() async {
    final androidEnabled = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    if (androidEnabled != null) {
      return androidEnabled;
    }

    final iosPermissions = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();

    if (iosPermissions == null) {
      return true;
    }

    return iosPermissions.isEnabled;
  }

  Future<void> openNotificationSettings() async {
    try {
      await _settingsChannel.invokeMethod<bool>('openNotificationSettings');
    } catch (e) {
      debugPrint('Open notification settings error: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    NotificationPayloadData? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'gym_corpus_channel',
      'Allenamenti e Notifiche',
      channelDescription: 'Notifiche relative agli allenamenti e nutrizione',
      icon: '@mipmap/launcher_icon',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload?.encode(),
    );
  }

  /// Schedule a daily notification at the given [hour]:[minute].
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    NotificationPayloadData? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gym_corpus_scheduled',
      'Promemoria',
      channelDescription: 'Promemoria giornalieri per allenamento e stretching',
      icon: '@mipmap/launcher_icon',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Se l'orario è già passato oggi, programma per domani
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      payload: payload?.encode(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint(
      'Scheduled notification $id at $hour:$minute (next: $scheduledDate)',
    );
  }

  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
    NotificationPayloadData? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gym_corpus_scheduled',
      'Promemoria',
      channelDescription: 'Promemoria giornalieri per allenamento e stretching',
      icon: '@mipmap/launcher_icon',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != dayOfWeek ||
        !scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      payload: payload?.encode(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    debugPrint(
      'Scheduled weekly notification $id for weekday $dayOfWeek at '
      '$hour:$minute (next: $scheduledDate)',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
