import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_diary/src/components/events/walk_event.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/events_icons_module.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/screens/weight_screen.dart';

List<EventsIconsModule> createEventModule(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController descriptionController,
    DateTime dateController,
    WidgetRef ref,
    List<Event> allEvents,
    Pet pet) {
  final module_1 = EventsIconsModule(
    name: 'L I F E  S T Y L E',
    icons: [
      MyButtonWidget(
        iconData: FontAwesomeIcons.walking,
        label: 'W A L K',
        onTap: () {
          walkEvent(
              context,
              nameController,
              descriptionController,
              dateController,
              ref,
              allEvents,
              (date, focusedDate) {},
              0,
              0,
              pet.userId,
              pet.id);
        },
        color: const Color.fromARGB(255, 103, 146, 167),
        opacity: 0.6,
        borderRadius: 20.0,
        iconSize: 14.0,
        fontSize: 12.0,
        fontFamily: 'San Francisco',
      ),
      MyButtonWidget(
        iconData: FontAwesomeIcons.weightScale,
        label: 'W E I G H T',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const WeightScreen(),
            ),
          );
        },
        color: const Color.fromARGB(255, 103, 146, 167),
        opacity: 0.6,
        borderRadius: 20.0,
        iconSize: 14.0,
        fontSize: 12.0,
        fontFamily: 'San Francisco',
      ),
    ],
    moduleColor: const Color.fromARGB(255, 182, 182, 182),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 13.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(8.0),
  );

  return [module_1];
}
