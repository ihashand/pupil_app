import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/event_psychic_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/event_psychic_provider.dart';

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
                                    weightId: '',
                                    temperatureId: '',
                                    walkId: '',
                                    waterId: '',
                                    noteId: '',
                                    pillId: '',
                                    description: issue['description'],
                                    proffesionId: 'NONE',
                                    personId: 'NONE',
                                    avatarImage:
                                        'assets/images/dog_avatar_014.png',
                                    emoticon: issue['icon'],
                                    moodId: '',
                                    stomachId: '',
                                    psychicId: newPsychic.id,
                                    stoolId: '',
                                    urineId: '',
                                    serviceId: '',
                                    careId: '');

                                ref
                                    .read(eventServiceProvider)
                                    .addEvent(newEvent);
                                Navigator.of(context)
                                    .pop(); // Close the confirmation dialog
                                Navigator.of(context)
                                    .pop(); // Close the bottom sheet
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
                  style: const TextStyle(fontSize: 10), // Small font
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
