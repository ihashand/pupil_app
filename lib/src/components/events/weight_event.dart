import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/add_new_event.dart';
import 'package:pet_diary/src/models/event_model.dart';

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
  TextEditingController weightName = TextEditingController(text: "W E I G H T");
  nameController.text = "";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'A D D  W E I G H T',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Pet Weight',
            hintText: 'Enter weight',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            // Możesz tutaj dodać dodatkową walidację, jeśli to konieczne
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
                  // Wyświetl komunikat o błędzie, jeśli pole wagi jest puste lub wartość jest nieprawidłowa
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
                addNewEvent(weightName, descriptionController, dateController,
                    ref, allEvents, selectDate, 0, initialWeight, petId);
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
