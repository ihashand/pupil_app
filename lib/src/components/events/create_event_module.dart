import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/temperature_event.dart';
import 'package:pet_diary/src/components/events/walk_event.dart';
import 'package:pet_diary/src/components/events/water_event.dart';
import 'package:pet_diary/src/components/events/weight_event.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
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
    name: 'L I F E  S T Y L E',
    icons: [
      walkIconMethod(context, nameController, descriptionController,
          dateController, ref, allEvents, petId),
      weightIconMethod(context, nameController, descriptionController,
          dateController, ref, allEvents, petId),
      temperatureIconMethod(context, nameController, descriptionController,
          dateController, ref, allEvents, petId),
      waterIconMethod(context, nameController, descriptionController,
          dateController, ref, allEvents, petId),
    ],
    moduleColor: const Color.fromARGB(85, 85, 88, 190),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 16.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(10.0),
  );

  final module_2 = EventsIconsModule(
    name: 'N O T E S',
    icons: [],
    moduleColor: const Color.fromARGB(85, 85, 88, 190),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 16.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(10.0),
  );

  final module_3 = EventsIconsModule(
    name: 'R E M I N D E R S',
    icons: [],
    moduleColor: const Color.fromARGB(85, 85, 88, 190),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 16.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(10.0),
  );

  final module_4 = EventsIconsModule(
    name: 'M E D S',
    icons: [],
    moduleColor: const Color.fromARGB(85, 85, 88, 190),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 16.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(10.0),
  );

  final module_5 = EventsIconsModule(
    name: 'S Y M P T O M S',
    icons: [],
    moduleColor: const Color.fromARGB(85, 85, 88, 190),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 16.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(10.0),
  );

  return [module_1, module_2, module_3, module_4, module_5];
}

MyButtonWidget walkIconMethod(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  String petId,
) {
  return MyButtonWidget(
    iconData: Icons.hiking,
    label: 'W A L K',
    onTap: () {
      walkEvent(context, nameController, descriptionController, dateController,
          ref, allEvents, (date, focusedDate) {}, 0, 0, petId);
    },
    color: const Color.fromARGB(85, 85, 88, 190),
    opacity: 0.0,
    borderRadius: 20.0,
    iconSize: 50.0,
    fontSize: 13.0,
    fontFamily: 'San Francisco',
    iconColor: const Color.fromARGB(255, 40, 169, 40),
    iconFill: 0.1,
    iconGrade: 1,
    iconOpticalSize: 25,
    iconWeight: 20,
  );
}

MyButtonWidget weightIconMethod(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  String petId,
) {
  return MyButtonWidget(
    iconData: Icons.monitor_weight_rounded,
    label: 'W E I G H T',
    onTap: () {
      weightEvent(
        context,
        nameController,
        descriptionController,
        dateController,
        ref,
        allEvents,
        (date, focusedDate) {},
        0,
        0,
        petId,
      );
    },
    color: const Color.fromARGB(85, 85, 88, 190),
    opacity: 0.0,
    borderRadius: 20.0,
    iconSize: 50.0,
    fontSize: 13.0,
    fontFamily: 'San Francisco',
    iconColor: Color.fromARGB(248, 209, 213, 0),
    iconFill: 0.1,
    iconGrade: 1,
    iconOpticalSize: 25,
    iconWeight: 20,
  );
}

MyButtonWidget temperatureIconMethod(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  String petId,
) {
  return MyButtonWidget(
    iconData: Icons.thermostat,
    label: 'T E M P',
    onTap: () {
      temperatureEvent(
        context,
        nameController,
        descriptionController,
        dateController,
        ref,
        allEvents,
        (date, focusedDate) {},
        0,
        0,
        petId,
      );
    },
    color: const Color.fromARGB(85, 85, 88, 190),
    opacity: 0.0,
    borderRadius: 20.0,
    iconSize: 50.0,
    fontSize: 13.0,
    fontFamily: 'San Francisco',
    iconColor: const Color.fromARGB(255, 235, 70, 89),
    iconFill: 0.1,
    iconGrade: 1,
    iconOpticalSize: 25,
    iconWeight: 20,
  );
}

MyButtonWidget waterIconMethod(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  String petId,
) {
  return MyButtonWidget(
    iconData: Icons.water_drop,
    label: 'W A T  E R',
    onTap: () {
      waterEvent(
        context,
        nameController,
        descriptionController,
        dateController,
        ref,
        allEvents,
        (date, focusedDate) {},
        0,
        0,
        petId,
      );
    },
    color: const Color.fromARGB(85, 85, 88, 190),
    opacity: 0.0,
    borderRadius: 20.0,
    iconSize: 50.0,
    fontSize: 13.0,
    fontFamily: 'San Francisco',
    iconColor: const Color.fromARGB(255, 40, 111, 241),
    iconFill: 0.1,
    iconGrade: 1,
    iconOpticalSize: 25,
    iconWeight: 20,
  );
}
