import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_stool_model.dart';
import 'package:pet_diary/src/providers/event_stool_provider.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';

class EventStool extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const EventStool({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> stoolTypes = [
      {
        'icon': '💩',
        'color': Colors.transparent,
        'description': 'Type 1: Separate hard lumps, like nuts'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'description': 'Type 2: Sausage-shaped but lumpy'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'description': 'Type 3: Like a sausage but with cracks on the surface'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'description': 'Type 4: Like a sausage or snake, smooth and soft'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'description': 'Type 5: Soft blobs with clear-cut edges'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'description': 'Type 6: Fluffy pieces with ragged edges, a mushy stool'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'description': 'Type 7: Watery, no solid pieces'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stoolTypes.map((type) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Stool Type'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              'Are you sure you want to add this stool type?'),
                          Text(
                            type['icon'],
                            style: const TextStyle(fontSize: 50),
                          ),
                          Text(type['description']),
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

                            EventStoolModel newStool = EventStoolModel(
                              id: generateUniqueId(),
                              eventId: eventId,
                              petId: petId,
                              emoji: type['icon'],
                              description: type['description'],
                              dateTime: eventDateTime,
                            );

                            ref
                                .read(eventStoolServiceProvider)
                                .addStoolEvent(newStool);
                            Event newEvent = Event(
                                id: eventId,
                                title: 'Stool',
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
                                description: type['description'],
                                proffesionId: 'BRAK',
                                personId: 'BRAK',
                                avatarImage: 'assets/images/dog_avatar_014.png',
                                emoticon: type['icon'],
                                moodId: '',
                                stomachId: '',
                                psychicId: '',
                                stoolId: newStool.id,
                                urineId: '',
                                serviceId: '',
                                careId: '');

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
                backgroundColor: type['color'],
                child: Text(
                  type['icon'],
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
