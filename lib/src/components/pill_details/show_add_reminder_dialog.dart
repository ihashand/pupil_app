// ignore_for_file: unused_result, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import 'package:pet_diary/src/screens/pill_detail_screen.dart';

Future<void> showAddReminderDialog(
    BuildContext context,
    WidgetRef ref,
    final String petId,
    final String newPillId,
    Pill? pill,
    List<String> tempReminderIds) async {
  String selectedRepeatType = ref.watch(reminderSelectedRepeatType);
  final TextEditingController nameController =
      ref.watch(reminderNameControllerProvider);
  final TextEditingController descriptionController =
      ref.watch(reminderDescriptionControllerProvider);
  TimeOfDay selectedTime = ref.watch(reminderTimeOfDayControllerProvider);

  final reminders = ref
      .read(reminderRepositoryProvider)
      .value
      ?.getReminders()
      .where((element) => element.objectId == newPillId)
      .toList();
  var labelStyle = TextStyle(color: Theme.of(context).primaryColorDark);

  if (reminders!.length >= 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Maximum number of reminders reached (10)'),
      ),
    );
    return;
  }
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            'R e m i n d e r',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Repeatability",
                    labelStyle: labelStyle,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: selectedRepeatType.isEmpty ? null : selectedRepeatType,
                  hint: Text("R", style: labelStyle),
                  items: <String>[
                    'Once',
                    'Daily',
                    'Weekly',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRepeatType = newValue!;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time selector',
                    labelStyle: labelStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ), // Odpowiednie paddingi dla Twojego designu
                  ),
                  child: SizedBox(
                    height: 30,
                    width: double
                        .infinity, // Aby przycisk rozciągał się na całą szerokość
                    child: ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors
                                        .black, // Kolor tekstu przycisku 'OK'
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        selectedTime.format(
                            context), // Formatowanie czasu do czytelnej formy
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
              onPressed: () {
                // Logika dodawania przypomnienia do repo
                final Reminder newReminder = Reminder(
                  id: generateUniqueId(),
                  title: nameController.text,
                  description: descriptionController.text,
                  time: selectedTime,
                  userId: ref
                      .read(petRepositoryProvider)
                      .value!
                      .getPetById(petId)!
                      .userId,
                  objectId: newPillId,
                );

                if (pill != null) {
                  newReminder.objectId = pill.id;
                }

                ref.watch(reminderSelectedRepeatType.notifier).state =
                    selectedRepeatType;

                ref
                    .read(reminderRepositoryProvider)
                    .value
                    ?.addReminder(newReminder);

                ref.refresh(reminderRepositoryProvider);

                DateTime today = DateTime.now();
                TimeOfDay? timeOfDay =
                    TimeOfDay(hour: today.hour, minute: today.minute);

                // nie usuwac, nie dotykac, odpowiedzialne za czyszczenie i uzupelnianie pola, inaczej jest problem ze stanem
                cleanerOfFields = false;

                ref.read(reminderNameControllerProvider).text = '';
                ref.read(reminderDescriptionControllerProvider).text = '';
                ref.read(reminderTimeOfDayControllerProvider.notifier).state =
                    timeOfDay;

                tempReminderIds.add(newReminder.id);

                Navigator.pop(context);
              },
            ),
          ],
        );
      });
    },
  );
}
