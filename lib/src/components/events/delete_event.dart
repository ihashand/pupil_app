import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/loading_dialog.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/mood_provider.dart';
import 'package:pet_diary/src/providers/note_provider.dart';
import 'package:pet_diary/src/providers/medicine_provider.dart';
import 'package:pet_diary/src/providers/psychic_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import 'package:pet_diary/src/providers/stomach_provider.dart';
import 'package:pet_diary/src/providers/stool_event_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/urine_event_provider.dart';
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
  final String moodId = event.moodId;
  final String stomachId = event.stomachId;
  final String psychicId = event.psychicId;
  final String stoolId = event.stoolId;
  final String urineId = event.urineId;

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

  if (moodId.isNotEmpty) {
    await ref.read(moodServiceProvider).deleteMood(moodId);
  }

  if (stomachId.isNotEmpty) {
    await ref.read(stomachServiceProvider).deleteStomach(stomachId);
  }

  if (psychicId.isNotEmpty) {
    await ref.read(psychicEventServiceProvider).deletePsychicEvent(psychicId);
  }

  if (stoolId.isNotEmpty) {
    await ref.read(stoolEventServiceProvider).deleteStoolEvent(stoolId);
  }

  if (urineId.isNotEmpty) {
    await ref.read(urineEventServiceProvider).deleteUrineEvent(urineId);
  }

  // ignore: use_build_context_synchronously
  Navigator.of(context).pop();
}
