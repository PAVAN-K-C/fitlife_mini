import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'reminders_channel',
          channelName: 'Reminders',
          channelDescription: 'Fitness reminders channel',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    // Request permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'reminders_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'reminders_channel',
        title: title,
        body: body,
        wakeUpScreen: true,
      ),
    );
  }

  Future<void> cancelReminder(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  Future<void> requestPermissions() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}
