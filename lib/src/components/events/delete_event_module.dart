// ignore_for_file: unused_result

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/note_provider.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';

void deleteEventModule(
  WidgetRef ref,
  List<Event>? allEvents,
  void Function(DateTime date, DateTime focusedDate) selectDate,
  DateTime dateController,
  String eventId,
  String petId,
) async {
  var event = allEvents?.where((element) => element.id == eventId).first;
  var allWeights = ref.watch(weightRepositoryProvider).value?.getWeights();
  var allWalks = ref.watch(walkRepositoryProvider).value?.getWalks();
  var allTemperatures =
      ref.watch(temperatureRepositoryProvider).value?.getTemperature();
  var allWater = ref.watch(waterRepositoryProvider).value?.getWater();
  var allNotes = ref.watch(noteRepositoryProvider).value?.getNotes();
  var allPills = ref.watch(pillRepositoryProvider).value?.getPills();

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

  final int indexToDeletePill =
      allPills?.indexWhere((w) => w.id == event!.pillId) ?? -1;

  final String pillId = event!.pillId;

  ref.watch(eventRepositoryProvider).value?.deleteEvent(eventId);
  ref.refresh(eventRepositoryProvider);

  if (indexToDeleteWeight != -1) {
    await ref
        .watch(weightRepositoryProvider)
        .value
        ?.deleteWeight(indexToDeleteWeight);
    ref.refresh(weightRepositoryProvider);
  }

  if (indexToDeleteWalk != -1) {
    await ref
        .watch(walkRepositoryProvider)
        .value
        ?.deleteWalk(indexToDeleteWalk);
    ref.refresh(walkRepositoryProvider);
  }

  if (indexToDeleteTemperature != -1) {
    await ref
        .watch(temperatureRepositoryProvider)
        .value
        ?.deleteTemperature(indexToDeleteTemperature);
    ref.refresh(temperatureRepositoryProvider);
  }

  if (indexToDeleteWater != -1) {
    await ref
        .watch(waterRepositoryProvider)
        .value
        ?.deleteWater(indexToDeleteWater);
    ref.refresh(waterRepositoryProvider);
  }

  if (indexToDeleteNote != -1) {
    await ref
        .watch(noteRepositoryProvider)
        .value
        ?.deleteNote(indexToDeleteNote);
    ref.refresh(noteRepositoryProvider);
  }

  if (indexToDeletePill != -1) {
    await ref.watch(pillRepositoryProvider).value?.deletePill(pillId);
    ref.refresh(noteRepositoryProvider);
  }

  selectDate(dateController, dateController);
}
