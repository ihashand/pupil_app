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
    double weight,
    {bool isHomeEvent = false}) async {
  nameController.text = "Weight";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('W E I G H T'),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            weight = double.tryParse(value)!;
          },
          decoration: const InputDecoration(labelText: 'In kg'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('S A V E',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface)),
            onPressed: () {
              addNewEvent(nameController, descriptionController, dateController,
                  ref, allEvents, selectDate, durationTime, weight);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  if (!isHomeEvent) {
    Navigator.of(context).pop();
  }
  return Future.value();
}
