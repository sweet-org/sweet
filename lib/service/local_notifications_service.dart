import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationsService() {
    init();
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher_foreground');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload,
        ) async {
          print(id);
        });

    const initializationSettingsMacOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: LinuxInitializationSettings(defaultActionName: ''),
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          debugPrint('notification payload: $details.payload');
        }
      },
    );
  }

  Future<int> scheduleNotification({
    required String title,
    required String message,
    required Duration duration,
  }) async {
    if (!Platform.isWindows) {
      await _notificationsPlugin.zonedSchedule(
        0,
        title,
        message,
        tz.TZDateTime.now(tz.local).add(duration),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sweet_notifications',
            'Notifications', // TODO: Translate?
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    return 0;
  }

  Future<void> cancelNotification({required int id}) =>
      _notificationsPlugin.cancel(id);

  Future<void> cancelAllNotifications() => _notificationsPlugin.cancelAll();
}
