// ignore_for_file: unused_result

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
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

  final int indexToDeleteEvent =
      allEvents?.indexWhere((e) => e.id == eventId) ?? -1;

  final int indexToDeleteWeight =
      allWeights?.indexWhere((w) => w.id == event!.weightId) ?? -1;

  final int indexToDeleteWalk =
      allWalks?.indexWhere((w) => w.id == event!.walkId) ?? -1;

  final int indexToDeleteTemperature =
      allTemperatures?.indexWhere((w) => w.id == event!.temperatureId) ?? -1;

  final int indexToDeleteWater =
      allWater?.indexWhere((w) => w.id == event!.waterId) ?? -1;

  if (indexToDeleteEvent != -1) {
    await ref
        .watch(eventRepositoryProvider)
        .value
        ?.deleteEvent(indexToDeleteEvent);
    ref.refresh(eventRepositoryProvider);
  }

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

  selectDate(dateController, dateController);
}
