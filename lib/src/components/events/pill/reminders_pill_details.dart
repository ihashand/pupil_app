import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/add_reminders_screen.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';

Widget remindersPillDetails(
  WidgetRef ref,
  BuildContext context,
  String petId,
  String newPillId,
  final Pill? pill,
) {
  return StreamBuilder<List<Reminder>>(
    stream: ref.watch(reminderServiceProvider).getRemindersStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      var perpetumMobile = newPillId;
      if (pill != null) {
        perpetumMobile = pill.id;
      }

      List<Reminder> reminders = snapshot.data!
          .where((element) => element.objectId == perpetumMobile)
          .toList();

      return Flexible(
          child: Column(
        children: [
          SizedBox(
            height: 40,
            width: 350,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddReminderScreen(petId: petId, newPillId: newPillId),
                  ),
                );
              },
              label: Text(' New reminder',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14)),
              icon: Icon(Icons.access_time,
                  color: Theme.of(context).primaryColorDark),
              backgroundColor: const Color(0xffdfd785),
              extendedPadding: const EdgeInsets.symmetric(horizontal: 5.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ListTile(
                  title: Text(
                    reminder.title.isEmpty
                        ? 'Medicine reminder'
                        : '${reminder.title} reminder',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time: ${reminder.time.hour}:${reminder.time.minute} ',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        reminder.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await ref
                          .read(reminderServiceProvider)
                          .deleteReminder(reminder.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ));
    },
  );
}
