import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/note_model.dart';
import 'package:pet_diary/src/models/reminder_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
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
  void Function(DateTime date, DateTime focusedDate) selectDate,
  String eventId,
  String petId,
) async {
  Event? event = allEvents?.where((element) => element.id == eventId).first;
  List<Weight>? allWeights =
      ref.watch(weightRepositoryProvider).value?.getWeights();
  List<Walk>? allWalks = ref.watch(walkRepositoryProvider).value?.getWalks();
  List<Temperature>? allTemperatures =
      ref.watch(temperatureRepositoryProvider).value?.getTemperature();
  List<Water>? allWater = ref.watch(waterRepositoryProvider).value?.getWater();
  List<Note>? allNotes = ref.watch(noteRepositoryProvider).value?.getNotes();

  final int indexToDeleteWeight =
      allWeights?.indexWhere((w) => w.id == event!.weightId) ?? -1;

  final int indexToDeleteWalk =
      allWalks?.indexWhere((w) => w.id == event!.walkId) ?? -1;

  final int indexToDeleteTemperature =
      allTemperatures?.indexWhere((w) => w.id == event!.temperatureId) ?? -1;

  final int indexToDeleteWater =
      allWater?.indexWhere((w) => w.id == event!.waterId) ?? -1;

  final int indexToDeleteNote =
      allNotes?.indexWhere((w) => w.id == event!.noteId) ?? -1;

  final String pillId = event!.pillId;

  ref.watch(eventRepositoryProvider).value?.deleteEvent(eventId);
  ref.invalidate(eventRepositoryProvider);

  if (indexToDeleteWeight != -1) {
    await ref
        .watch(weightRepositoryProvider)
        .value
        ?.deleteWeight(indexToDeleteWeight);
    ref.invalidate(weightRepositoryProvider);
  }

  if (indexToDeleteWalk != -1) {
    await ref
        .watch(walkRepositoryProvider)
        .value
        ?.deleteWalk(indexToDeleteWalk);
    ref.invalidate(walkRepositoryProvider);
  }

  if (indexToDeleteTemperature != -1) {
    await ref
        .watch(temperatureRepositoryProvider)
        .value
        ?.deleteTemperature(indexToDeleteTemperature);
    ref.invalidate(temperatureRepositoryProvider);
  }

  if (indexToDeleteWater != -1) {
    await ref
        .watch(waterRepositoryProvider)
        .value
        ?.deleteWater(indexToDeleteWater);
    ref.invalidate(waterRepositoryProvider);
  }

  if (indexToDeleteNote != -1) {
    await ref
        .watch(noteRepositoryProvider)
        .value
        ?.deleteNote(indexToDeleteNote);
    ref.invalidate(noteRepositoryProvider);
  }

  if (pillId.isNotEmpty) {
    List<Reminder>? reminders =
        ref.watch(reminderRepositoryProvider).value?.getReminders();

    if (reminders != null && reminders.isNotEmpty) {
      for (var reminder in reminders) {
        if (reminder.objectId == pillId) {
          await ref
              .watch(reminderRepositoryProvider)
              .value
              ?.deleteReminder(reminder.id);
        }
      }
    }

    await ref.watch(pillRepositoryProvider).value?.deletePill(pillId);
    ref.invalidate(noteRepositoryProvider);
  }
}
