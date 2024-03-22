// ignore_for_file: unused_result, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';

Widget reminderItem({required Reminder reminder, required WidgetRef ref}) {
  return ListTile(
    title: Text(reminder.title),
    subtitle: Text(
        '${reminder.time.hour}:${reminder.time.minute} - ${reminder.description}'),
    trailing: IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await ref
            .read(reminderRepositoryProvider.future)
            .then((reminderRepo) => reminderRepo.deleteReminder(reminder.id));
        ref.refresh(reminderRepositoryProvider);
      },
    ),
  );
}
