import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/add_new_event.dart';
import 'package:pet_diary/src/models/event_model.dart';

Future<void> walkEvent(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController descriptionController,
    DateTime dateController,
    WidgetRef ref,
    List<Event>? allEvents,
    void Function(DateTime date, DateTime focusedDate) selectDate,
    int durationTime,
    double
        weight, // if it is not set, default value is description no duration time. Check it in my_calendar_screen
    String userId,
    String petId,
    {bool isHomeEvent = false}) async {
  nameController.text = "Walk";

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      durationTime = 0;
      return AlertDialog(
        title: const Text('W A L K  T I M E'),
        content: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                durationTime = int.tryParse(value) ?? 0;
              },
              decoration: const InputDecoration(labelText: 'In minutes'),
            ),
            if (durationTime > 6 * 60) // 6 hours in minutes
              Text(
                'Are you sure the walk lasted ${durationTime ~/ 60} hours and ${durationTime % 60} minutes?',
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('S A V E',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface)),
            onPressed: () async {
              if (durationTime > 6 * 60) {
                bool confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmation'),
                      content: Text(
                        'Are you sure the walk lasted ${durationTime ~/ 60} hours and ${durationTime % 60} minutes?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('No',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Yes',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface)),
                        ),
                      ],
                    );
                  },
                );
                if (!confirm) return;
              }
              addNewEvent(
                  nameController,
                  descriptionController,
                  dateController,
                  ref,
                  allEvents,
                  selectDate,
                  durationTime,
                  weight,
                  userId,
                  petId);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  return Future.value();
}
