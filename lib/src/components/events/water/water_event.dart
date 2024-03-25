import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/add_delete_event/add_new_event.dart';
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
  double initialWater,
  String petId, {
  bool isHomeEvent = false,
}) async {
  TextEditingController temperatureName = TextEditingController(text: "Water");
  nameController.text = "";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          width: 250,
          height: 70,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Water',
              border: OutlineInputBorder(),
            ),
            child: TextFormField(
              controller: nameController,
              cursorColor: Theme.of(context).primaryColorDark.withOpacity(0.5),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final fixedValue = value.replaceAll(',', '.');
                initialWater = double.tryParse(fixedValue) ?? 0.0;
              },
            ),
          ),
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        initialWater <= 0.0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Invalid Input',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 20)),
                            content: SizedBox(
                              width: 250,
                              child: Text('Water field cannot be empty.',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  )),
                            ),
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

                    if (initialWater > 50.0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Invalid Input',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 24)),
                            content: SizedBox(
                              width: 250,
                              child: Text('Water cannot exceed 50 liters.',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 16)),
                            ),
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
                        initialWater,
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
              ],
            ),
          ),
        ],
      );
    },
  );

  return Future.value();
}
