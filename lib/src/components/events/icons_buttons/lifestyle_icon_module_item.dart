import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/temperature/temperature_event.dart';
import 'package:pet_diary/src/components/events/walk/walk_event.dart';
import 'package:pet_diary/src/components/events/water/water_event.dart';
import 'package:pet_diary/src/components/events/weight/weight_event.dart';
import 'package:pet_diary/src/components/events/icons_buttons/clickable_icons_row.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/icon_layout.dart';
import 'package:pet_diary/src/models/module_item.dart';

ModuleItem lifestyleIconModuleItem(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  String petId,
) {
  return ModuleItem(
    content: ClickableIconsRow(
      icon1: Icons.nordic_walking,
      icon2: Icons.monitor_weight,
      icon3: Icons.water_drop,
      icon4: Icons.thermostat,
      iconSize: 40.0,
      icon1Color: Colors.green,
      icon2Color: Colors.purple,
      icon3Color: Colors.blue,
      icon4Color: Colors.red,
      spacing: 30.0,
      onTap1: () => walkEvent(
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
      ),
      onTap2: () => weightEvent(
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
      ),
      onTap3: () => waterEvent(
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
      ),
      onTap4: () => temperatureEvent(
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
      ),
      text1: 'Walk',
      text2: 'Weight',
      text3: 'Water',
      text4: 'Temperature',
      textSize: 12.0,
      layout: IconLayout.horizontal,
    ),
  );
}
