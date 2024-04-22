import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/walk/_build_time_selector.dart';
import 'package:pet_diary/src/components/events/walk/cancel_walk.dart';
import 'package:pet_diary/src/components/events/walk/many_hours_alert.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';

class NewWalkEventWidget extends ConsumerStatefulWidget {
  final double iconSize;
  final Color iconColor;
  final String petId;
  final DateTime eventDateTime;

  const NewWalkEventWidget({
    super.key,
    required this.iconSize,
    required this.iconColor,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  ConsumerState<NewWalkEventWidget> createState() => _NewWalkEventWidgetState();
}

class _NewWalkEventWidgetState extends ConsumerState<NewWalkEventWidget> {
  @override
  Widget build(BuildContext context) {
    const IconData iconData = Icons.nordic_walking;
    var walkDistanceController = TextEditingController();
    double walkDistance = 0;
    var selectedHours = 0;
    var selectedMinutes = 0;

    return GestureDetector(
      onTap: () {
        inputFileds(context, walkDistanceController, walkDistance,
            selectedHours, selectedMinutes);
      },
      child: Icon(
        iconData,
        size: widget.iconSize,
        color: widget.iconColor,
      ),
    );
  }

  Future<dynamic> inputFileds(
      BuildContext context,
      TextEditingController walkDistanceController,
      double walkDistance,
      int selectedHours,
      int selectedMinutes) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 400,
            height: 300,
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
                                    context, 'Minutes', selectedMinutes,
                                    (value) {
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
                      Navigator.of(context).pop();

                      int totalDurationInSeconds =
                          selectedHours * 60 + selectedMinutes;
                      if (walkDistance > 120.0) {
                        toBigDistance(context);
                        return;
                      }

                      if (selectedHours == 0 && selectedMinutes == 0) {
                        emptyFiledsAlert(context);
                        return;
                      }

                      if (totalDurationInSeconds > 6 * 60) {
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

                      saveWalkEvent(walkDistance, totalDurationInSeconds);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> toBigDistance(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Input',
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 24)),
          content: SizedBox(
            width: 250,
            child: Text('Walk distance cannot exceed 120 km.',
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 16)),
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

  Future<dynamic> emptyFiledsAlert(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Invalid Input',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 20,
            ),
          ),
          content: SizedBox(
            width: 270,
            child: Text(
              'Walk fields cannot be empty.',
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
              ),
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void saveWalkEvent(double walkDistance, int totalDurationInSeconds) {
    Walk newWalk = Walk(
        id: generateUniqueId(),
        walkTime: totalDurationInSeconds.toDouble(),
        walkDistance: walkDistance,
        eventId: generateUniqueId(),
        petId: widget.petId,
        dateTime: widget.eventDateTime);

    newWalk.id = generateUniqueId();
    newWalk.walkDistance = walkDistance;
    newWalk.walkTime = totalDurationInSeconds.toDouble();

    String eventId = generateUniqueId();

    newWalk.eventId = eventId;
    newWalk.petId = widget.petId;
    newWalk.dateTime = widget.eventDateTime;

    Event newEvent = Event(
        id: eventId,
        title: 'Walk',
        eventDate: widget.eventDateTime,
        dateWhenEventAdded: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        petId: widget.petId,
        weightId: '',
        temperatureId: '',
        walkId: newWalk.id,
        waterId: '',
        noteId: '',
        pillId: '',
        description:
            'Distance: ${walkDistance.toStringAsFixed(2)} km. \nTime: ${totalDurationInSeconds.toString()} min.',
        proffesionId: 'BRAK',
        personId: 'BRAK',
        avatarImage: 'assets/images/dog_avatar_010.png',
        emoticon: '🚶‍➡️');
    ref.read(eventServiceProvider).addEvent(newEvent);

    ref.read(walkServiceProvider).addWalk(newWalk);
  }
}
