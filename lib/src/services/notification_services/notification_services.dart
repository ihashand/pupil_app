import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Klasa odpowiedzialna za obsługę powiadomień w aplikacji.
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
        debugPrint('Powiadomienie otrzymane: ${response.payload}');
      },
    );

    if (initialized != null && initialized) {
      debugPrint('Powiadomienia zostały zainicjalizowane.');
    } else {
      debugPrint('Błąd podczas inicjalizacji powiadomień.');
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
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      debugPrint(
          'Utworzono powiadomienie: ID=$id, tytuł=$title, treść=$body, data=$scheduledDate');
    } catch (e) {
      debugPrint('Błąd podczas tworzenia powiadomienia: $e');
    }
  }

  /// Metoda do planowania codziennego powiadomienia
  Future<void> createDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    final scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _convertToTZDateTime(scheduledDate),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel_id',
            'Daily Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // Codzienna powtarzalność
      );

      debugPrint(
          'Utworzono codzienne powiadomienie: ID=$id, tytuł=$title, treść=$body, czas=$time');
    } catch (e) {
      debugPrint('Błąd podczas tworzenia codziennego powiadomienia: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Anulowano powiadomienie o ID=$id');
    } catch (e) {
      debugPrint('Błąd podczas anulowania powiadomienia o ID=$id: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('Anulowano wszystkie powiadomienia');
    } catch (e) {
      debugPrint('Błąd podczas anulowania wszystkich powiadomień: $e');
    }
  }
}
