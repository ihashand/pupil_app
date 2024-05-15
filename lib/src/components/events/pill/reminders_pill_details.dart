import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/new_reminders_screen.dart';
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
                        NewReminderScreen(petId: petId, newPillId: newPillId),
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
        ],
      ));
    },
  );
}
