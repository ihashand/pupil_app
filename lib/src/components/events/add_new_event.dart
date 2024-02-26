// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_walk_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';

List<Event>? addNewEvent(
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  void Function(DateTime date, DateTime focusedDate) selectDate,
  int durationTime,
  double weight,
  String petId,
) {
  var allEvents = ref.watch(eventRepositoryProvider).value?.getEvents();
  var pet = ref.watch(petRepositoryProvider).value?.getPetById(petId);

  String eventName = nameController.text.trim();
  String eventDescription = descriptionController.text.trim();
  String weightId = generateUniqueId();
  String eventId = generateUniqueId();

  Weight newWeight = Weight();
  newWeight.id = weightId;
  newWeight.weight = weight;
  newWeight.eventId = eventId;
  newWeight.petId = petId;

  PetWalk newWalk = PetWalk();
  newWalk.id = generateUniqueId();

  if (eventName.isNotEmpty) {
    Event newEvent = Event(
      id: eventId,
      title: eventName,
      description: eventDescription,
      date: dateController,
      durationTime: durationTime,
      weight: weight,
      userId: pet!.userId,
      petId: petId,
      weightId: weightId,
    );

    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
    ref.watch(weightRepositoryProvider).value?.addWeight(newWeight);
    nameController.clear();
    descriptionController.clear();
    ref.refresh(eventRepositoryProvider);
    ref.refresh(petRepositoryProvider);
    ref.refresh(weightRepositoryProvider);
    selectDate(dateController, dateController);
  }

  return allEvents;
}
