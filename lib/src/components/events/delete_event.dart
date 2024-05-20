import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/loading_dialog.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/note_provider.dart';
import 'package:pet_diary/src/providers/medicine_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';

void deleteEvents(
  WidgetRef ref,
  BuildContext context,
  List<Event>? allEvents,
  String eventId,
) async {
  Event? event = allEvents?.where((element) => element.id == eventId).first;

  final String noteId = event!.noteId;
  final String pillId = event.pillId;
  final String temperatureId = event.temperatureId;
  final String walkId = event.walkId;
  final String waterId = event.waterId;
  final String weightId = event.weightId;

  ref.read(eventServiceProvider).deleteEvent(eventId);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const LoadingDialog();
    },
  );

  if (weightId.isNotEmpty) {
    await ref.read(weightServiceProvider).deleteWeight(weightId);
  }

  if (waterId.isNotEmpty) {
    await ref.read(waterServiceProvider).deleteWater(waterId);
  }

  if (temperatureId.isNotEmpty) {
    await ref.read(temperatureServiceProvider).deleteTemperature(temperatureId);
  }

  if (walkId.isNotEmpty) {
    await ref.read(walkServiceProvider).deleteWalk(walkId);
  }

  if (noteId.isNotEmpty) {
    await ref.read(noteServiceProvider).deleteNote(noteId);
  }

  if (pillId.isNotEmpty) {
    List<Reminder> reminders =
        await ref.read(reminderServiceProvider).getReminders();

    if (reminders.isNotEmpty) {
      for (var reminder in reminders) {
        if (reminder.objectId == pillId) {
          await ref.read(reminderServiceProvider).deleteReminder(reminder.id);
        }
      }
    }

    await ref.read(medicineServiceProvider).deleteMedicine(pillId);
  }

  await Future.delayed(const Duration(seconds: 2));

  // ignore: use_build_context_synchronously
  Navigator.of(context).pop();
}
