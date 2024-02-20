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
  double weight,
  String userId,
  String petId, {
  bool isHomeEvent = false,
}) async {
  nameController.text = "Walk";

  int selectedHours = 0;
  int selectedMinutes = 0;

  double maxHeight = MediaQuery.of(context).size.height *
      0.119; // Set max height for the dialog

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          // Center the title
          child: Text(
            'W A L K  T I M E',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: SizedBox(
          width: double.infinity,
          height: maxHeight, // Set height for the content container
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeSelector(
                    context,
                    'HOURS',
                    selectedHours,
                    (value) {
                      selectedHours = value;
                    },
                  ),
                  _buildTimeSelector(
                    context,
                    'MINUTES',
                    selectedMinutes,
                    (value) {
                      selectedMinutes = value;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if ((selectedHours * 60 + selectedMinutes) > 6 * 60)
                Text(
                  'Are you sure the walk lasted $selectedHours hours and $selectedMinutes minutes?',
                ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            // Center the button
            child: TextButton(
              child: Text(
                'S A V E',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
              onPressed: () async {
                if ((selectedHours * 60 + selectedMinutes) > 6 * 60) {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ManyHoursAlert(
                          selectedHours: selectedHours,
                          selectedMinutes: selectedMinutes);
                    },
                  );
                  if (!confirm) return;
                }
                int totalDurationInSeconds =
                    selectedHours * 60 + selectedMinutes;

                addNewEvent(
                  nameController,
                  descriptionController,
                  dateController,
                  ref,
                  allEvents,
                  selectDate,
                  totalDurationInSeconds,
                  weight,
                  userId,
                  petId,
                );
                // ignore: use_build_context_synchronously
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

class ManyHoursAlert extends StatelessWidget {
  const ManyHoursAlert({
    super.key,
    required this.selectedHours,
    required this.selectedMinutes,
  });

  final int selectedHours;
  final int selectedMinutes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmation'),
      content: Text(
        'Are you sure the walk lasted $selectedHours hours and $selectedMinutes minutes?',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'No',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Yes',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildTimeSelector(
  BuildContext context,
  String label,
  int selectedValue,
  void Function(int value) onChanged,
) {
  return Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      SizedBox(
        height: 50,
        width: 40, // Set a fixed width here
        child: ListWheelScrollView(
          itemExtent: 40,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            onChanged(index);
          },
          controller: FixedExtentScrollController(initialItem: selectedValue),
          children: List.generate(
            60,
            (index) => Center(
              child: Text(
                '$index',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
