import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/add_new_event.dart';
import 'package:pet_diary/src/components/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

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
  String petId, {
  bool isHomeEvent = false,
}) async {
  var pet = ref.watch(petRepositoryProvider).value?.getPetById(petId);
  nameController.text = "Walk";
  int selectedHours = 0;
  int selectedMinutes = 0;

  double maxHeight = MediaQuery.of(context).size.height *
      0.21; // Set max height for the dialog

  TextEditingController walkDistanceController = TextEditingController();

  double walkDistance = 0;

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
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildTimeSelector(
                            context,
                            'H O U R S  ',
                            selectedHours,
                            (value) {
                              selectedHours = value;
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildTimeSelector(
                            context,
                            'M I N U T E S',
                            selectedMinutes,
                            (value) {
                              selectedMinutes = value;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 117,
                        child: TextFormField(
                          controller: walkDistanceController,
                          decoration: const InputDecoration(
                            labelText: 'Walk distance',
                            hintText: 'Enter distance',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            walkDistance = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),
                    ],
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
            child: TextButton(
              child: Text(
                'S A V E',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
              onPressed: () async {
                if (selectedHours == 0 && selectedMinutes == 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Row(
                        children: [
                          AlertDialog(
                            title: Text('Error',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 24)),
                            content: Text(
                                'Please select a valid walk duration.',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 20)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                int totalDurationInSeconds =
                    selectedHours * 60 + selectedMinutes;

                if (totalDurationInSeconds < 1) {
                  // Wyświetl komunikat o błędzie, jeśli czas spaceru jest mniejszy niż 1 minuta
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 24)),
                        content: Text(
                            'Walk duration must be at least 1 minute.',
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

                if (totalDurationInSeconds > 6 * 60) {
                  // Jeśli czas spaceru przekracza 6 godzin, poproś o potwierdzenie
                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ManyHoursAlert(
                        selectedHours: selectedHours,
                        selectedMinutes: selectedMinutes,
                      );
                    },
                  );

                  if (!confirm) return;
                }

                String newWalkId = generateUniqueId();
                Walk newWalk = Walk();
                newWalk.id = newWalkId;
                newWalk.walkDistance = walkDistance;

                addNewEvent(
                    nameController,
                    descriptionController,
                    dateController,
                    ref,
                    allEvents,
                    selectDate,
                    totalDurationInSeconds,
                    weight,
                    pet!.id,
                    Temperature(),
                    Weight(),
                    newWalk);

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
      title: Text('Confirmation',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 24)),
      content: Text(
          'Are you sure the walk lasted $selectedHours hours and $selectedMinutes minutes?',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 16)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'No',
            style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontSize: 20),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Yes',
            style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontSize: 20),
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
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      SizedBox(
        height: 40,
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
