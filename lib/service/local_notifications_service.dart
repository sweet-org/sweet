import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  //final FlutterLocalNotificationsPlugin _notificationsPlugin =
  //    FlutterLocalNotificationsPlugin();

  LocalNotificationsService() {
    init();
  }

  Future<void> init() async {
    tz.initializeTimeZones();
    /*
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher_foreground');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: false);

    const initializationSettingsMacOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettingsWindows = WindowsInitializationSettings(
        appName: "sweet",
        appUserModelId: "dev.sillykat.eve.sweet",
        guid: "96415652-173f-4e49-ae4d-5f1ec9a2c2d0"  // Just a random guid
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: LinuxInitializationSettings(defaultActionName: ''),
      windows: initializationSettingsWindows,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          debugPrint('notification payload: $details.payload');
        }
      },
    );*/
  }

  Future<int> scheduleNotification({
    required String title,
    required String message,
    required Duration duration,
  }) async {
    throw UnimplementedError("Local notifications have been removed");/*
    // ToDo: Windows is supported since 19.0.0, but haven't looked into it yet
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
      );
    }
    */

    return 0;
  }
  /*
  Future<void> cancelNotification({required int id}) =>
      _notificationsPlugin.cancel(id);

  Future<void> cancelAllNotifications() => _notificationsPlugin.cancelAll();
*/
}
