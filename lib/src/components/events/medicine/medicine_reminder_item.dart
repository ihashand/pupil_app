import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/event_reminder_provider.dart';

Widget reminderItem(
    {required EventReminderModel reminder, required WidgetRef ref}) {
  return ListTile(
    title: Text(reminder.title),
    subtitle: Text(
        '${reminder.time.hour}:${reminder.time.minute} - ${reminder.description}'),
    trailing: IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await ref
            .read(eventReminderServiceProvider)
            .deleteReminder(reminder.id);
      },
    ),
  );
}
