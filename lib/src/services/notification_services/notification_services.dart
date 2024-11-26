import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// A service class responsible for handling notifications within the application.
///
/// This class provides methods to schedule, display, and manage notifications.
/// It interacts with the underlying platform's notification system to deliver
/// notifications to the user.
///
/// Example usage:
///
/// ```dart
/// final notificationService = NotificationService();
/// notificationService.scheduleNotification(...);
/// ```
///
/// Note: Ensure that the necessary permissions are granted before using this service.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification received: ${response.payload}');
      },
    );

    if (initialized != null && initialized) {
      debugPrint('Notifications have been initialized.');
    } else {
      debugPrint('Error during notification initialization.');
    }
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final tzLocation = tz.local;
    return tz.TZDateTime.from(dateTime, tzLocation);
  }

  Future<void> createNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails();

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _convertToTZDateTime(scheduledDate),
        platformDetails,
        // ignore: deprecated_member_use
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      debugPrint(
          'Notification created: ID=$id, title=$title, body=$body, date=$scheduledDate');
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  Future<void> createDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = DateTime.now();
    final scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel_id',
          'Daily Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload, // Payload for additional data
    );
  }

  /// Creates a single notification for a specific date and time.
  ///
  /// This method schedules a one-time notification at the given `dateTime`.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the notification.
  /// - [title]: Title of the notification.
  /// - [body]: Body content of the notification.
  /// - [dateTime]: The specific date and time when the notification should be triggered.
  /// - [payload]: Optional payload data for the notification.
  ///
  /// Example:
  /// ```dart
  /// NotificationService().createSingleNotification(
  ///   id: 101,
  ///   title: 'Vet Appointment',
  ///   body: 'Your vet appointment is scheduled.',
  ///   dateTime: DateTime.now().add(Duration(hours: 1)),
  /// );
  /// ```
  /// Creates a one-time notification.
  /// Creates a single notification for a specific date and time.
  /// Ensures that the provided `dateTime` is valid and in the future.
  Future<void> createSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    // Sprawdź, czy `dateTime` jest w przyszłości
    if (dateTime.isBefore(DateTime.now())) {
      debugPrint('Notification time is in the past. Skipping creation.');
      return;
    }

    try {
      // Szczegóły dla Androida
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'single_notification_channel',
        'Single Notifications',
        channelDescription: 'Notifications for one-time events',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      // Szczegóły dla iOS
      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails();

      // Szczegóły platformowe
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // Konwersja daty na strefę czasową
      final tzDateTime = _convertToTZDateTime(dateTime);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        platformDetails,
        // ignore: deprecated_member_use
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint(
          'Single notification scheduled: ID=$id, Title=$title, DateTime=$dateTime');
    } catch (e) {
      debugPrint('Error scheduling single notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
