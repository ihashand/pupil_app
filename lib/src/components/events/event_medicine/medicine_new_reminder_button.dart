import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/medicine_new_reminder_screen.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_reminder_provider.dart';

Widget medicineNewReminderButton(
  WidgetRef ref,
  BuildContext context,
  String petId,
  String newPillId,
  final EventMedicineModel? pill,
) {
  return StreamBuilder<List<EventReminderModel>>(
    stream: ref.watch(eventReminderServiceProvider).getRemindersStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      return Flexible(
          child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(children: [
          SizedBox(
            width: 400,
            height: 40,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineNewReminderScreen(
                        petId: petId, newPillId: newPillId),
                  ),
                );
              },
              label: Text('New reminder',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14)),
              icon: Icon(Icons.notification_add,
                  color: Theme.of(context).primaryColorDark),
              backgroundColor: const Color(0xffdfd785),
              extendedPadding: const EdgeInsets.symmetric(horizontal: 5.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ]),
      ));
    },
  );
}
