import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/walk_event.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/events_icons_module.dart';
import 'package:pet_diary/src/models/pet_model.dart';

List<EventsIconsModule> createEventModule(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController descriptionController,
    DateTime dateController,
    WidgetRef ref,
    List<Event>? allEvents,
    Pet pet) {
  final module_1 = EventsIconsModule(
    name: 'L I F E  S T Y L E',
    icons: [
      walkIconMethod(context, nameController, descriptionController,
          dateController, ref, allEvents, pet),
    ],
    moduleColor: const Color.fromARGB(85, 85, 88, 190),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 16.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(10.0),
  );

  return [module_1, module_1];
}

MyButtonWidget walkIconMethod(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController descriptionController,
    DateTime dateController,
    WidgetRef ref,
    List<Event>? allEvents,
    Pet pet) {
  return MyButtonWidget(
    iconData: Icons.hiking,
    label: 'W A L K',
    onTap: () {
      walkEvent(context, nameController, descriptionController, dateController,
          ref, allEvents, (date, focusedDate) {}, 0, 0, pet.userId, pet.id);
    },
    color: const Color.fromARGB(85, 85, 88, 190),
    opacity: 0.0,
    borderRadius: 20.0,
    iconSize: 50.0,
    fontSize: 13.0,
    fontFamily: 'San Francisco',
    iconColor: const Color.fromARGB(255, 223, 254, 70),
    iconFill: 0.1,
    iconGrade: 1,
    iconOpticalSize: 25,
    iconWeight: 20,
  );
}
