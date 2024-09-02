import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_stool_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_stool_provider.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';

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
        'name': 'Type 1',
        'description': 'Separate hard lumps, like nuts'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'name': 'Type 2',
        'description': 'Sausage-shaped but lumpy'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'name': 'Type 3',
        'description': 'Like a sausage but with cracks on the surface'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'name': 'Type 4',
        'description': 'Like a sausage or snake, smooth and soft'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'name': 'Type 5',
        'description': 'Soft blobs with clear-cut edges'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'name': 'Type 6',
        'description': 'Fluffy pieces with ragged edges, a mushy stool'
      },
      {
        'icon': '💩',
        'color': Colors.transparent,
        'name': 'Type 7',
        'description': 'Watery, no solid pieces'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stoolTypes.map((type) {
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
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  petId: petId,
                                  description: type['description'],
                                  avatarImage:
                                      'assets/images/dog_avatar_014.png',
                                  emoticon: type['icon'],
                                  stoolId: newStool.id,
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
                    backgroundColor: type['color'],
                    child: Text(
                      type['icon'],
                      style: TextStyle(fontSize: iconSize / 2),
                    ),
                  ),
                ),
                Text(
                  type['name'],
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
