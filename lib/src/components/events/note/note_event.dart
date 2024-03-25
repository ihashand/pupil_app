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

Future<void> noteEvent(
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
  TextEditingController noteName = TextEditingController(text: "N O T E");
  nameController.text = "";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'A D D  N O T E',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter your things',
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            descriptionController.text = value;
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
                if (nameController.text == '') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 24)),
                        content: Text('Note field cannot be empty.',
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
                String noteId = generateUniqueId();
                Note newNote = Note();
                newNote.id = noteId;

                addNewEvent(
                    noteName,
                    descriptionController,
                    dateController,
                    ref,
                    allEvents,
                    selectDate,
                    0,
                    0,
                    petId,
                    Temperature(),
                    Weight(),
                    Walk(),
                    Water(),
                    newNote,
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
