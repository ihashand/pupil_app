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
  nameController.text = "";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 70,
                width: 250,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    cursorColor:
                        Theme.of(context).primaryColorDark.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                child: TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  cursorColor:
                      Theme.of(context).primaryColorDark.withOpacity(0.5),
                ),
              ),
            ],
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
                    if (nameController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 24)),
                            content: Text('Note title cannot be empty.',
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
                        nameController,
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
              ],
            ),
          ),
        ],
      );
    },
  );

  return Future.value();
}
