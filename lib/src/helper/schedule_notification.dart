import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

Future<void> schedulePillReminder(
  FlutterLocalNotificationsPlugin notificationsPlugin,
  String pillName,
  int reminderId,
  TimeOfDay time,
  DateTime endDate,
  String pillDescription,
  String repeatType, // Nowy parametr określający typ powtarzalności
) async {
  tz.initializeTimeZones(); // Upewnij się, że strefy czasowe są zainicjowane
  DateTime now = DateTime.now();
  DateTime startDate =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
  if (startDate.isBefore(now)) {
    startDate = startDate.add(
        const Duration(days: 1)); // Jeśli czas już minął, planujemy na jutro.
  }

  tz.TZDateTime plannedNotificationDateTime =
      tz.TZDateTime.from(startDate, tz.local);
  final tz.TZDateTime endDateTime =
      tz.TZDateTime.from(endDate, tz.local); // Koniec zakresu dat

  int interval = 1;

  switch (repeatType) {
    case 'Once':
      interval = 0; // Nie powtarzaj
      break;
    case 'Daily':
      interval = 1; // Codziennie
      break;
    case 'Weekly':
      interval = 7; // Co tydzień
      break;
    case 'Monthly':
      //todo Tutaj będzie bardziej złożona logika, zależna od miesiąca
      break;
    case 'Yearly':
      //todo Tutaj będzie jeszcze bardziej złożona logika dla rocznego przypomnienia
      break;
  }

  if (interval > 0) {
    while (plannedNotificationDateTime.isBefore(endDateTime)) {
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
        matchDateTimeComponents: interval == 1
            ? DateTimeComponents.time
            : DateTimeComponents
                .dayOfWeekAndTime, // Powtarza codziennie o tej samej godzinie lub co tydzień w ten sam dzień
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );

      // Przejście do następnego okresu
      plannedNotificationDateTime = interval == 1 || interval == 7
          ? plannedNotificationDateTime.add(Duration(days: interval))
          : plannedNotificationDateTime;
      // Dla miesięcznego i rocznego wymagana dodatkowa logika
    }
  } else if (interval == 0) {
    // Planuj jednorazowe powiadomienie
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
      androidAllowWhileIdle: true,
    );
  }
}
