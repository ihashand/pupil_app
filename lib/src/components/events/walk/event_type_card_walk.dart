// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/walk/event_walk_build_time_selector.dart';
import 'package:pet_diary/src/components/events/walk/event_walk_many_hours_alert.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/loading_dialog.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

Widget eventTypeCardWalk(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'W A L K (Developer Only)',
    'assets/images/events_type_cards_no_background/bed.png',
    () {
      showWalkEventModal(context, ref, petId: petId, petIds: petIds);
    },
  );
}

void showWalkEventModal(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  TextEditingController walkDistanceController = TextEditingController();
  double walkDistance = 0;
  int selectedHours = 0;
  int selectedMinutes = 0;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            'Walk Event (Developer Only)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () async {
                              if (walkDistanceController.text.trim().isEmpty ||
                                  walkDistance <= 0.0 ||
                                  (selectedHours == 0 &&
                                      selectedMinutes == 0)) {
                                emptyFieldsAlert(context);
                                return;
                              }

                              int totalDurationInSeconds =
                                  selectedHours * 60 + selectedMinutes;

                              if (totalDurationInSeconds > 6 * 60) {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return EventWalkManyHoursAlert(
                                      selectedHours: selectedHours,
                                      selectedMinutes: selectedMinutes,
                                    );
                                  },
                                );
                                if (!confirm) return;
                              }

                              if (petIds != null && petIds.isNotEmpty) {
                                for (String id in petIds) {
                                  saveWalkEvent(context, ref, walkDistance,
                                      totalDurationInSeconds, id);
                                }
                              } else if (petId != null) {
                                saveWalkEvent(context, ref, walkDistance,
                                    totalDurationInSeconds, petId);
                              }

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 250,
                            height: 70,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Distance',
                                border: OutlineInputBorder(),
                              ),
                              child: TextFormField(
                                controller: walkDistanceController,
                                cursorColor: Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.5),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (value) {
                                  final fixedValue = value.replaceAll(',', '.');
                                  walkDistance =
                                      double.tryParse(fixedValue) ?? 0.0;
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(15.0),
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                ),
                                child: SizedBox(
                                  width: 70,
                                  child: eventWalkBuildTimeSelector(
                                      context, 'Hours', selectedHours, (value) {
                                    setState(() {
                                      selectedHours = value;
                                    });
                                  }, 24),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(15.0),
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                ),
                                child: SizedBox(
                                  width: 70,
                                  child: eventWalkBuildTimeSelector(
                                      context, 'Minutes', selectedMinutes,
                                      (value) {
                                    setState(() {
                                      selectedMinutes = value;
                                    });
                                  }, 60),
                                ),
                              ),
                            ],
                          ),
                          if ((selectedHours * 60 + selectedMinutes) > 6 * 60)
                            Text(
                                'Are you sure that your walk time was $selectedHours:$selectedMinutes?'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void saveWalkEvent(BuildContext context, WidgetRef ref, double walkDistance,
    int totalDurationInSeconds, String petId) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const LoadingDialog();
    },
  );

  EventWalkModel newWalk = EventWalkModel(
    id: generateUniqueId(),
    walkTime: totalDurationInSeconds.toDouble(),
    steps: walkDistance,
    petId: petId,
    dateTime: DateTime.now(),
    routePoints: [],
    globalWalkId: '',
    stoolsAndUrine: [],
  );

  String eventId = generateUniqueId();

  Event newEvent = Event(
    id: eventId,
    title: 'Walk',
    eventDate: DateTime.now(),
    dateWhenEventAdded: DateTime.now(),
    userId: FirebaseAuth.instance.currentUser!.uid,
    petId: petId,
    walkId: newWalk.id,
    description:
        '${walkDistance.toStringAsFixed(2)} steps in ${totalDurationInSeconds.toString()} min.',
    avatarImage: 'assets/images/dog_avatar_010.png',
    emoticon: '🚶‍➡️',
  );

  ref.read(eventServiceProvider).addEvent(newEvent, petId);
  ref.read(eventWalkServiceProvider).addWalk(petId, newWalk);
  Navigator.of(context).pop();
  Navigator.of(context).pop();
}

Future<dynamic> toBigDistance(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Invalid Input',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 24),
        ),
        content: SizedBox(
          width: 250,
          child: Text(
            'Walk distance cannot exceed 120 km.',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark, fontSize: 16),
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
                  color: Theme.of(context).primaryColorDark, fontSize: 20),
            ),
          ),
        ],
      );
    },
  );
}

Future<dynamic> emptyFieldsAlert(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Invalid Input',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 20),
        ),
        content: SizedBox(
          width: 270,
          child: Text(
            'Walk fields cannot be empty.',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      );
    },
  );
}
