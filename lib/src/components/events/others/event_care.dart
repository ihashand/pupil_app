import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_care_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_care_provider.dart';

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
      {'icon': '🛁', 'color': Colors.transparent, 'description': 'Bathing'},
      {
        'icon': '✂️',
        'color': Colors.transparent,
        'description': 'Nail Trimming'
      },
      {'icon': '🧼', 'color': Colors.transparent, 'description': 'Brushing'},
      {
        'icon': '👀',
        'color': Colors.transparent,
        'description': 'Eye Cleaning'
      },
      {
        'icon': '👂',
        'color': Colors.transparent,
        'description': 'Ear Cleaning'
      },
      {'icon': '🧴', 'color': Colors.transparent, 'description': 'Cream'},
      {'icon': '🪲', 'color': Colors.transparent, 'description': 'Tick'},
      {'icon': '🐜', 'color': Colors.transparent, 'description': 'Fleas'},
      {
        'icon': '🪥',
        'color': Colors.transparent,
        'description': 'Teeth Brushing'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: careOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: [
                GestureDetector(
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

                                ref
                                    .read(eventCareServiceProvider)
                                    .addCare(newCare);

                                Event newEvent = Event(
                                    id: eventId,
                                    title: 'Care',
                                    eventDate: eventDateTime,
                                    dateWhenEventAdded: DateTime.now(),
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    petId: petId,
                                    description: option['description'],
                                    avatarImage:
                                        'assets/images/dog_avatar_014.png',
                                    emoticon: option['icon'],
                                    careId: newCare.id);

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
                    backgroundColor: option['color'],
                    child: Text(
                      option['icon'],
                      style: TextStyle(fontSize: iconSize / 2),
                    ),
                  ),
                ),
                Text(
                  option['description'],
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
