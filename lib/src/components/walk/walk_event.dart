import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/add_new_event.dart';
import 'package:pet_diary/src/components/walk/_build_time_selector.dart';
import 'package:pet_diary/src/components/walk/cancel_walk.dart';
import 'package:pet_diary/src/components/walk/many_hours_alert.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/note_model.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
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
      0.30; // Set max height for the dialog

  TextEditingController walkDistanceController = TextEditingController();

  double walkDistance = 0;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          width: 400,
          height: maxHeight,
          child: Column(
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 250,
                        height: 70,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Walk distance',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            controller: walkDistanceController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (value) {
                              final fixedValue = value.replaceAll(',', '.');
                              walkDistance = double.tryParse(fixedValue) ?? 0.0;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: SizedBox(
                              width: 70,
                              child: buildTimeSelector(
                                  context, 'Hours', selectedHours, (value) {
                                selectedHours = value;
                              }, 24),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: SizedBox(
                              width: 70,
                              child: buildTimeSelector(
                                  context, 'Minutes', selectedMinutes, (value) {
                                selectedMinutes = value;
                              }, 60),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if ((selectedHours * 60 + selectedMinutes) > 6 * 60)
                Text(
                  'Are you sure that your walk time was $selectedHours:$selectedMinutes ?',
                ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CancelWalk(),
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  onPressed: () async {
                    // Dodaj logikę zapisu tutaj
                    if (selectedHours == 0 && selectedMinutes == 0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Error',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 24,
                              ),
                            ),
                            content: Text(
                              'Walk fields cannot be empty.',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 16,
                              ),
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
                                    fontSize: 20,
                                  ),
                                ),
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
                            title: Text(
                              'Error',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 24,
                              ),
                            ),
                            content: Text(
                              'Walk duration must be at least 1 minute.',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 16,
                              ),
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
                                    fontSize: 20,
                                  ),
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

                    Walk newWalk = Walk();
                    newWalk.id = generateUniqueId();
                    newWalk.walkDistance = walkDistance;
                    newWalk.walkTime = totalDurationInSeconds.toDouble();

                    addNewEvent(
                        nameController,
                        descriptionController,
                        dateController,
                        ref,
                        allEvents,
                        selectDate,
                        0,
                        weight,
                        pet!.id,
                        Temperature(),
                        Weight(),
                        newWalk,
                        Water(),
                        Note(),
                        Pill());

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(); // Zamknij dialog po zapisie
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
