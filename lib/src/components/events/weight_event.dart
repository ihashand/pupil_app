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

Future<void> weightEvent(
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
  TextEditingController weightName = TextEditingController(text: "Weight");
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
              labelText: 'Weight',
              border: OutlineInputBorder(),
            ),
            child: TextFormField(
              controller: nameController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final fixedValue = value.replaceAll(',', '.');
                initialWeight = double.tryParse(fixedValue) ?? 0.0;
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
                        initialWeight <= 0.0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 24)),
                            content: Text('Weight field cannot be empty.',
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
                    String weightId = generateUniqueId();
                    Weight newWeight = Weight();
                    newWeight.id = weightId;

                    addNewEvent(
                        weightName,
                        descriptionController,
                        dateController,
                        ref,
                        allEvents,
                        selectDate,
                        0,
                        initialWeight,
                        petId,
                        Temperature(),
                        newWeight,
                        Walk(),
                        Water(),
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
