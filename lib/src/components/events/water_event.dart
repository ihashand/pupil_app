import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/add_new_event.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/note_model.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';

Future<void> waterEvent(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  void Function(DateTime date, DateTime focusedDate) selectDate,
  int durationTime,
  double initialWeight,
  String petId, {
  bool isHomeEvent = false,
}) async {
  TextEditingController temperatureName =
      TextEditingController(text: "W A T E R");
  nameController.text = "";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'A D D  W A T E R',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Pet Water',
            hintText: 'Enter water',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            initialWeight = double.tryParse(value) ?? 0.0;
          },
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: Text(
                'S A V E',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: 20),
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    initialWeight <= 0.0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 24)),
                        content: Text('Water field cannot be empty.',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 16)),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 20),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                Water newWater = Water();
                newWater.id = generateUniqueId();

                addNewEvent(
                    temperatureName,
                    descriptionController,
                    dateController,
                    ref,
                    allEvents,
                    selectDate,
                    0,
                    initialWeight,
                    petId,
                    Temperature(),
                    Weight(),
                    Walk(),
                    newWater,
                    Note(),
                    Pill());

                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );

  return Future.value();
}
