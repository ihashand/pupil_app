import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/note_provider.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';
import 'package:pet_diary/src/providers/reminder_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';

void deleteEvents(
  WidgetRef ref,
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

  ref.watch(eventServiceProvider).deleteEvent(eventId);

  if (weightId.isNotEmpty) {
    await ref.watch(weightServiceProvider).deleteWeight(weightId);
  }

  if (waterId.isNotEmpty) {
    await ref.watch(waterServiceProvider).deleteWater(waterId);
  }

  if (temperatureId.isNotEmpty) {
    await ref
        .watch(temperatureServiceProvider)
        .deleteTemperature(temperatureId);
  }

  if (walkId.isNotEmpty) {
    await ref.watch(walkServiceProvider).deleteWalk(walkId);
  }

  if (noteId.isNotEmpty) {
    await ref.watch(noteServiceProvider).deleteNote(noteId);
  }

  if (pillId.isNotEmpty) {
    List<Reminder> reminders =
        await ref.read(reminderServiceProvider).getReminders();

    if (reminders.isNotEmpty) {
      for (var reminder in reminders) {
        if (reminder.objectId == pillId) {
          await ref.watch(reminderServiceProvider).deleteReminder(reminder.id);
        }
      }
    }

    await ref.watch(pillServiceProvider).deletePill(pillId);
  }
}
