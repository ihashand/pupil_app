import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/medicine_new_reminder_screen.dart';
import 'package:pet_diary/src/models/event_medicine_model.dart';
import 'package:pet_diary/src/models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/event_reminder_provider.dart';

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
          child: Column(
        children: [
          SizedBox(
            height: 40,
            width: 330,
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
              label: Text(' New reminder',
                  style: TextStyle(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.7),
                      fontSize: 14)),
              icon: Icon(Icons.notification_add,
                  color: Theme.of(context).primaryColorDark.withOpacity(0.5)),
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
