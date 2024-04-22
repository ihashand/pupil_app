// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> schedulePillReminder(
  FlutterLocalNotificationsPlugin notificationsPlugin,
  String pillName,
  int reminderId,
  TimeOfDay time,
  DateTime endDate,
  String pillDescription,
  String repeatOption,
  int? repeatInterval,
  List<int> selectedDays,
) async {
  tz.initializeTimeZones();
  DateTime now = DateTime.now();
  DateTime startDate =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);

  if (startDate.isBefore(now)) {
    startDate = startDate.add(const Duration(days: 1));
  }

  tz.TZDateTime plannedNotificationDateTime =
      tz.TZDateTime.from(startDate, tz.local);
  final tz.TZDateTime endDateTime = tz.TZDateTime.from(endDate, tz.local);

  int interval = repeatInterval ?? 1;

  switch (repeatOption) {
    case 'Once':
      interval = 0;
      break;
    case 'Daily':
      interval = 1;
      break;
    case 'Weekly':
      interval = 7;
      break;
    case 'Monthly':
      //todo: Obsługa powtarzania miesięcznego
      break;
    case 'Yearly':
      //todo: Obsługa powtarzania rocznego
      break;
  }

  if (interval > 0) {
    while (plannedNotificationDateTime.isBefore(endDateTime)) {
      if (selectedDays.contains(plannedNotificationDateTime.weekday % 7)) {
        await notificationsPlugin.zonedSchedule(
            reminderId,
            "Time to get: $pillName",
            "Description: $pillDescription",
            plannedNotificationDateTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'your channel id',
                'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            matchDateTimeComponents: DateTimeComponents.time,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
      }

      plannedNotificationDateTime = interval == 1 || interval == 7
          ? plannedNotificationDateTime.add(Duration(days: interval))
          : plannedNotificationDateTime;
    }
  } else if (interval == 0) {
    await notificationsPlugin.zonedSchedule(
        reminderId,
        "Time to use: $pillName",
        "Description: $pillDescription",
        plannedNotificationDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }
}
