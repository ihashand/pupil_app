import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/note_event.dart';
import 'package:pet_diary/src/components/events/icons_buttons/lifestyle_icon_module_item.dart';
import 'package:pet_diary/src/components/events/icons_buttons/note_button_module_item.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/events_icons_module.dart';

List<EventsIconsModule> createEventModule(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  String petId,
) {
  final module_1 = EventsIconsModule(
    name: 'L  I  F  E   S  T  Y  L  E ',
    items: [
      lifestyleIconModuleItem(context, nameController, descriptionController,
          dateController, ref, allEvents, petId),
    ],
    moduleColor: const Color.fromARGB(255, 255, 255, 255),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 10.0,
    fontSize: 16.0,
    fontFamily: 'Arial',
    margin: const EdgeInsets.all(10.0),
  );

  final module_2 = EventsIconsModule(
    name: 'N  O  T  E  P  A  D',
    items: [
      noteButtonModuleItem(
        buttonText: "Tap to add your note",
        onPressed: () {
          noteEvent(
            context,
            nameController,
            descriptionController,
            dateController,
            ref,
            allEvents,
            (DateTime date, DateTime focusedDate) {},
            0,
            0.0,
            petId,
          );
        },
        buttonColor: const Color.fromARGB(255, 99, 98, 91),
        buttonWidth: 400.0,
        buttonHeight: 60.0,
        textStyle: const TextStyle(fontSize: 12),
      ),
    ],
    moduleColor: const Color.fromARGB(255, 255, 255, 255),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 10.0,
    fontSize: 16.0,
    fontFamily: 'Arial',
    margin: const EdgeInsets.all(10.0),
  );

  return [module_1, module_2];
}
