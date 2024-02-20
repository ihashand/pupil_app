import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';

List<Event>? addNewEvent(
    TextEditingController nameController,
    TextEditingController descriptionController,
    DateTime dateController,
    WidgetRef ref,
    List<Event>? allEvents,
    void Function(DateTime date, DateTime focusedDate) selectDate,
    int durationTime,
    double weight,
    String userId,
    String petId) {
  String eventName = nameController.text.trim();
  String eventDescription = descriptionController.text.trim();

  if (eventName.isNotEmpty) {
    Event newEvent = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: eventName,
        description: eventDescription,
        date: dateController,
        durationTime: durationTime,
        weight: weight,
        userId: userId,
        petId: petId);
    ref.watch(eventRepositoryProvider).value?.addEvent(newEvent);
    nameController.clear();
    descriptionController.clear();
    allEvents = ref.refresh(eventRepositoryProvider).value?.getEvents();
    selectDate(dateController, dateController);
  }

  return allEvents;
}
