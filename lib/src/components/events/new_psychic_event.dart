import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/psychic_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/psychic_provider.dart';

class NewPsychicEvent extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const NewPsychicEvent({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> psychicIssues = [
      {
        'icon': '😰',
        'color': Colors.green.withOpacity(0.6),
        'description': 'Niepokój'
      },
      {
        'icon': '😴',
        'color': Colors.lightGreen.withOpacity(0.6),
        'description': 'Bezsenność'
      },
      {
        'icon': '😟',
        'color': Colors.brown.withOpacity(0.6),
        'description': 'Stres'
      },
      {
        'icon': '😨',
        'color': Colors.orange.withOpacity(0.6),
        'description': 'Strach'
      },
      {
        'icon': '😡',
        'color': Colors.red.withOpacity(0.6),
        'description': 'Drażliwość'
      },
      {
        'icon': '😩',
        'color': Colors.blueAccent.withOpacity(0.6),
        'description': 'Zmęczenie'
      },
      {
        'icon': '🤔',
        'color': Colors.purple.withOpacity(0.6),
        'description': 'Brak koncentracji'
      },
      {
        'icon': '😕',
        'color': Colors.grey.withOpacity(0.6),
        'description': 'Dezorientacja'
      },
      {
        'icon': '😴',
        'color': Colors.blue.withOpacity(0.6),
        'description': 'Lenistwo'
      },
      {
        'icon': '🤪',
        'color': Colors.yellow.withOpacity(0.6),
        'description': 'Nadpobudliwość'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: psychicIssues.map((issue) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
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

                            PsychicEvent newPsychic = PsychicEvent(
                              id: generateUniqueId(),
                              eventId: eventId,
                              petId: petId,
                              emoji: issue['icon'],
                              description: issue['description'],
                              dateTime: eventDateTime,
                            );

                            ref
                                .read(psychicEventServiceProvider)
                                .addPsychicEvent(newPsychic);
                            Event newEvent = Event(
                                id: eventId,
                                title: 'Psychic',
                                eventDate: eventDateTime,
                                dateWhenEventAdded: DateTime.now(),
                                userId: FirebaseAuth.instance.currentUser!.uid,
                                petId: petId,
                                weightId: '',
                                temperatureId: '',
                                walkId: '',
                                waterId: '',
                                noteId: '',
                                pillId: '',
                                description: issue['description'],
                                proffesionId: 'BRAK',
                                personId: 'BRAK',
                                avatarImage: 'assets/images/dog_avatar_014.png',
                                emoticon: issue['icon'],
                                moodId: '',
                                stomachId: '',
                                psychicId: newPsychic.id,
                                stoolId: '',
                                urineId: '');

                            ref.read(eventServiceProvider).addEvent(newEvent);
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
          );
        }).toList(),
      ),
    );
  }
}
