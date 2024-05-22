import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/event_care_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/event_care_provider.dart';

class EventCare extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const EventCare({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> careOptions = [
      {
        'icon': '🛁',
        'color': Colors.blue.withOpacity(0.6),
        'description': 'Mycie'
      },
      {
        'icon': '✂️',
        'color': Colors.red.withOpacity(0.6),
        'description': 'Obcinanie paznokci'
      },
      {
        'icon': '🧼',
        'color': Colors.green.withOpacity(0.6),
        'description': 'Czesanie'
      },
      {
        'icon': '👀',
        'color': Colors.yellow.withOpacity(0.6),
        'description': 'Mycie oczu'
      },
      {
        'icon': '👂',
        'color': Colors.orange.withOpacity(0.6),
        'description': 'Mycie uszu'
      },
      {
        'icon': '🧴',
        'color': Colors.pink.withOpacity(0.6),
        'description': 'Krem'
      },
      {
        'icon': '🪲',
        'color': Colors.brown.withOpacity(0.6),
        'description': 'Kleszcz'
      },
      {
        'icon': '🐜',
        'color': Colors.purple.withOpacity(0.6),
        'description': 'Pchły'
      },
      {
        'icon': '🪥',
        'color': Colors.teal.withOpacity(0.6),
        'description': 'Mycie zębów'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: careOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Care Option'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              'Are you sure you want to add this care option?'),
                          Text(
                            option['icon'],
                            style: const TextStyle(fontSize: 50),
                          ),
                          Text(option['description']),
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

                            EventCareModel newCare = EventCareModel(
                              id: generateUniqueId(),
                              eventId: eventId,
                              petId: petId,
                              careType: option['description'],
                              emoji: option['icon'],
                              description: option['description'],
                              dateTime: eventDateTime,
                            );

                            ref.read(eventCareServiceProvider).addCare(newCare);

                            Event newEvent = Event(
                                id: eventId,
                                title: 'Care',
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
                                description: option['description'],
                                proffesionId: 'BRAK',
                                personId: 'BRAK',
                                avatarImage: 'assets/images/dog_avatar_014.png',
                                emoticon: option['icon'],
                                moodId: '',
                                stomachId: '',
                                psychicId: '',
                                stoolId: '',
                                urineId: '',
                                serviceId: '',
                                careId: newCare.id);

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
                backgroundColor: option['color'],
                child: Text(
                  option['icon'],
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
