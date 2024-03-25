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

Future<void> temperatureEvent(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event>? allEvents,
  void Function(DateTime date, DateTime focusedDate) selectDate,
  int durationTime,
  double initialValue,
  String petId, {
  bool isHomeEvent = false,
}) async {
  TextEditingController temperatureName =
      TextEditingController(text: "T E M P E R A T U R E");
  nameController.text = "";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'A D D  T E M P E R A T U R E',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Pet temperature',
            hintText: 'Enter temperature',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            initialValue = double.tryParse(value) ?? 0.0;
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
                if (nameController.text.trim().isEmpty || initialValue <= 0.0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 24)),
                        content: Text('Temperature field cannot be empty.',
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

                Temperature newTemperature = Temperature();
                newTemperature.id = generateUniqueId();
                addNewEvent(
                    temperatureName,
                    descriptionController,
                    dateController,
                    ref,
                    allEvents,
                    selectDate,
                    0,
                    initialValue,
                    petId,
                    newTemperature,
                    Weight(),
                    Walk(),
                    Water(),
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
