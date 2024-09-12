import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_psychic_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_psychic_provider.dart';

class EventPsychic extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const EventPsychic({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> psychicIssues = [
      {'icon': '😰', 'color': Colors.transparent, 'description': 'Anxiety'},
      {'icon': '😴', 'color': Colors.transparent, 'description': 'Insomnia'},
      {'icon': '😟', 'color': Colors.transparent, 'description': 'Stress'},
      {'icon': '😨', 'color': Colors.transparent, 'description': 'Fear'},
      {
        'icon': '😡',
        'color': Colors.transparent,
        'description': 'Irritability'
      },
      {'icon': '😩', 'color': Colors.transparent, 'description': 'Fatigue'},
      {
        'icon': '🤔',
        'color': Colors.transparent,
        'description': 'Lack of Concentration'
      },
      {'icon': '😕', 'color': Colors.transparent, 'description': 'Confusion'},
      {'icon': '😴', 'color': Colors.transparent, 'description': 'Laziness'},
      {
        'icon': '🤪',
        'color': Colors.transparent,
        'description': 'Hyperactivity'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: psychicIssues.map((issue) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Psychic Issue'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  'Are you sure you want to add this issue?'),
                              Text(
                                issue['icon'],
                                style: const TextStyle(fontSize: 50),
                              ),
                              Text(issue['description']),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              onPressed: () {
                                String eventId = generateUniqueId();

                                EventPsychicModel newPsychic =
                                    EventPsychicModel(
                                  id: generateUniqueId(),
                                  eventId: eventId,
                                  petId: petId,
                                  emoji: issue['icon'],
                                  description: issue['description'],
                                  dateTime: eventDateTime,
                                );

                                ref
                                    .read(eventPsychicServiceProvider)
                                    .addPsychicEvent(newPsychic);
                                Event newEvent = Event(
                                  id: eventId,
                                  title: 'Psychic',
                                  eventDate: eventDateTime,
                                  dateWhenEventAdded: DateTime.now(),
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  petId: petId,
                                  description: issue['description'],
                                  avatarImage:
                                      'assets/images/dog_avatar_014.png',
                                  emoticon: issue['icon'],
                                  psychicId: newPsychic.id,
                                );

                                ref
                                    .read(eventServiceProvider)
                                    .addEvent(newEvent);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: iconSize / 2,
                    backgroundColor: issue['color'],
                    child: Text(
                      issue['icon'],
                      style: TextStyle(fontSize: iconSize / 2),
                    ),
                  ),
                ),
                Text(
                  issue['description'],
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
