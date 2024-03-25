// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/note_model.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/note_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';

List<Event>? addNewEvent(
    TextEditingController nameController,
    TextEditingController descriptionController,
    DateTime dateController,
    WidgetRef ref,
    List<Event>? allEvents,
    void Function(DateTime date, DateTime focusedDate) selectDate,
    int durationTime,
    double initialValue,
    String petId,
    Temperature newTemperature,
    Weight newWeight,
    Walk newWalk,
    Water newWater,
    Note newNote,
    Pill newPill) {
  var allEvents = ref.watch(eventRepositoryProvider).value?.getEvents();
  var pet = ref.watch(petRepositoryProvider).value?.getPetById(petId);

  String eventId = generateUniqueId();
  String eventName = nameController.text.trim();
  String eventDescription = descriptionController.text.trim();

  // temperature
  if (newTemperature.id != '') {
    newTemperature.eventId = eventId;
    newTemperature.petId = petId;
    newTemperature.temperature = initialValue;

    Event newEvent = Event(
        id: eventId,
        title: eventName,
        description: eventDescription,
        date: dateController,
        durationTime: durationTime,
        value: initialValue,
        userId: pet!.userId,
        petId: petId,
        weightId: '',
        temperatureId: newTemperature.id,
        walkId: '',
        waterId: '',
        noteId: '',
        pillId: '');

    ref
        .watch(temperatureRepositoryProvider)
        .value
        ?.addTemperature(newTemperature);
    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);

    nameController.clear();
    descriptionController.clear();

    ref.refresh(temperatureRepositoryProvider);
    ref.refresh(eventRepositoryProvider);
  }

  // weight
  if (newWeight.id != '') {
    newWeight.eventId = eventId;
    newWeight.petId = petId;
    newWeight.weight = initialValue;

    Event newEvent = Event(
        id: eventId,
        title: eventName,
        description: eventDescription,
        date: dateController,
        durationTime: durationTime,
        value: initialValue,
        userId: pet!.userId,
        petId: petId,
        weightId: newWeight.id,
        temperatureId: '',
        walkId: '',
        waterId: '',
        noteId: '',
        pillId: '');

    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
    ref.watch(weightRepositoryProvider).value?.addWeight(newWeight);

    nameController.clear();
    descriptionController.clear();

    ref.refresh(weightRepositoryProvider);
    ref.refresh(eventRepositoryProvider);
  }

//todo
  // walk
  if (newWalk.id.isNotEmpty) {
    newWalk.eventId = eventId;
    newWalk.petId = petId;

    Event newEvent = Event(
        id: eventId,
        title: eventName,
        description: eventDescription,
        date: dateController,
        durationTime: durationTime,
        value: newWalk.walkTime,
        userId: pet!.userId,
        petId: petId,
        weightId: '',
        temperatureId: '',
        walkId: newWalk.id,
        waterId: '',
        noteId: '',
        pillId: '');

    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
    ref.watch(walkRepositoryProvider).value?.addWalk(newWalk);

    nameController.clear();
    descriptionController.clear();

    ref.refresh(eventRepositoryProvider);
    ref.refresh(walkRepositoryProvider);
    selectDate(dateController, dateController);
  }

  // water
  if (newWater.id != '') {
    newWater.eventId = eventId;
    newWater.petId = petId;
    newWater.water = initialValue;

    Event newEvent = Event(
        id: eventId,
        title: eventName,
        description: eventDescription,
        date: dateController,
        durationTime: durationTime,
        value: initialValue,
        userId: pet!.userId,
        petId: petId,
        weightId: newWeight.id,
        temperatureId: '',
        walkId: '',
        waterId: newWater.id,
        noteId: '',
        pillId: '');

    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
    ref.watch(waterRepositoryProvider).value?.addWater(newWater);

    nameController.clear();
    descriptionController.clear();

    ref.refresh(waterRepositoryProvider);
    ref.refresh(eventRepositoryProvider);
  }

  // note
  if (newNote.id != '') {
    newNote.eventId = eventId;
    newNote.petId = petId;
    newNote.note = descriptionController.text;

    Event newEvent = Event(
        id: eventId,
        title: eventName,
        description: eventDescription,
        date: dateController,
        durationTime: durationTime,
        value: initialValue,
        userId: pet!.userId,
        petId: petId,
        weightId: '',
        temperatureId: '',
        walkId: '',
        waterId: '',
        noteId: newNote.id,
        pillId: '');

    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
    ref.watch(noteRepositoryProvider).value?.addNote(newNote);

    nameController.clear();
    descriptionController.clear();

    ref.refresh(eventRepositoryProvider);
    ref.refresh(noteRepositoryProvider);
    selectDate(dateController, dateController);
  }

  // note
  if (newPill.id != '') {
    newNote.eventId = eventId;
    newNote.petId = petId;
    newNote.note = descriptionController.text;

    Event newEvent = Event(
        id: eventId,
        title: eventName,
        description: eventDescription,
        date: dateController,
        durationTime: durationTime,
        value: initialValue,
        userId: pet!.userId,
        petId: petId,
        weightId: '',
        temperatureId: '',
        walkId: '',
        waterId: '',
        noteId: newNote.id,
        pillId: '');

    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
    ref.watch(noteRepositoryProvider).value?.addNote(newNote);

    nameController.clear();
    descriptionController.clear();

    ref.refresh(eventRepositoryProvider);
    ref.refresh(noteRepositoryProvider);
    selectDate(dateController, dateController);
  }

  return allEvents;
}
