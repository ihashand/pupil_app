// ignore_for_file: unused_result, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/pill_details/reminder_item.dart';
import 'package:pet_diary/src/components/pill_details/show_add_reminder_dialog.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';

Widget remindersPillDetails(WidgetRef ref, BuildContext context, String petId,
    String newPillId, final Pill? pill, List<String> tempReminderIds) {
  final reminderRepoAsyncValue = ref.watch(reminderRepositoryProvider);

  return reminderRepoAsyncValue.when(
    data: (reminderRepo) {
      var perpetumMobile = newPillId;

      if (pill != null) {
        perpetumMobile = pill.id;
      }

      List<Reminder> reminders = reminderRepo
          .getReminders()
          .where((element) => element.objectId == perpetumMobile)
          .toList();

      return Column(
        children: [
          SizedBox(
            height: 50,
            width: 230,
            child: FloatingActionButton.extended(
              onPressed: () {
                showAddReminderDialog(
                    context, ref, petId, newPillId, pill, tempReminderIds);
              },
              label: Text(
                ' N e w  r e m i n d',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              icon: Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColorDark,
              ),
              backgroundColor: Colors.blue, // Customize color
              extendedPadding: const EdgeInsets.symmetric(
                horizontal: 10.0, // Adjust padding
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    15.0), // Adjust border radius as needed
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return reminderItem(reminder: reminder, ref: ref);
              },
            ),
          ),
        ],
      );
    },
    loading: () => const CircularProgressIndicator(),
    error: (e, st) => Text('Error: $e'),
  );
}
