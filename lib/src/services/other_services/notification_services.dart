import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String repeatOption,
    DateTime? endDate,
    String? interval, // Dodaj ten parametr
  }) async {
    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(scheduledDate, tz.local);

    if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    switch (repeatOption) {
      case 'Once':
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDateTime,
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        break;
      case 'Daily':
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDateTime,
          notificationDetails,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        break;
      case 'Weekly':
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDateTime,
          notificationDetails,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        break;
      case 'Every x days':
        if (endDate != null) {
          while (scheduledDateTime
              .isBefore(tz.TZDateTime.from(endDate, tz.local))) {
            await flutterLocalNotificationsPlugin.zonedSchedule(
              id,
              title,
              body,
              scheduledDateTime,
              notificationDetails,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
            scheduledDateTime =
                scheduledDateTime.add(Duration(days: int.parse(interval!)));
            id++;
          }
        }
        break;
      case 'Every x month':
        if (endDate != null) {
          while (scheduledDateTime
              .isBefore(tz.TZDateTime.from(endDate, tz.local))) {
            await flutterLocalNotificationsPlugin.zonedSchedule(
              id,
              title,
              body,
              scheduledDateTime,
              notificationDetails,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
            scheduledDateTime = tz.TZDateTime(
              tz.local,
              scheduledDateTime.year,
              scheduledDateTime.month + int.parse(interval!),
              scheduledDateTime.day,
              scheduledDateTime.hour,
              scheduledDateTime.minute,
            );
            id++;
          }
        }
        break;
      case 'Every x year':
        if (endDate != null) {
          while (scheduledDateTime
              .isBefore(tz.TZDateTime.from(endDate, tz.local))) {
            await flutterLocalNotificationsPlugin.zonedSchedule(
              id,
              title,
              body,
              scheduledDateTime,
              notificationDetails,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
            scheduledDateTime = tz.TZDateTime(
              tz.local,
              scheduledDateTime.year + int.parse(interval!),
              scheduledDateTime.month,
              scheduledDateTime.day,
              scheduledDateTime.hour,
              scheduledDateTime.minute,
            );
            id++;
          }
        }
        break;
      default:
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDateTime,
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
