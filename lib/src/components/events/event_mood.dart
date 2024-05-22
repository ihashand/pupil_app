import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/event_mood_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/event_mood_provider.dart';

class EventMood extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const EventMood({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> moods = [
      {
        'icon': '😄',
        'color': Colors.green.withOpacity(0.6),
        'description': 'Happy'
      },
      {
        'icon': '😃',
        'color': Colors.lightGreen.withOpacity(0.6),
        'description': 'Excited'
      },
      {
        'icon': '😊',
        'color': Colors.blue.withOpacity(0.6),
        'description': 'Content'
      },
      {
        'icon': '😐',
        'color': Colors.grey.withOpacity(0.6),
        'description': 'Neutral'
      },
      {
        'icon': '😴',
        'color': Colors.orange.withOpacity(0.6),
        'description': 'Tired'
      },
      {
        'icon': '😢',
        'color': Colors.blueAccent.withOpacity(0.6),
        'description': 'Sad'
      },
      {
        'icon': '😠',
        'color': Colors.red.withOpacity(0.6),
        'description': 'Angry'
      },
      {
        'icon': '😡',
        'color': Colors.redAccent.withOpacity(0.6),
        'description': 'Furious'
      },
      {
        'icon': '😭',
        'color': Colors.purple.withOpacity(0.6),
        'description': 'Crying'
      },
      {
        'icon': '😞',
        'color': Colors.deepOrange.withOpacity(0.6),
        'description': 'Disappointed'
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((mood) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Mood'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Are you sure you want to add this mood?'),
                        Text(
                          mood['icon'],
                          style: const TextStyle(fontSize: 50),
                        ),
                        Text(mood['description']),
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
                          EventMoodModel newMood = EventMoodModel(
                            id: generateUniqueId(),
                            eventId: eventId,
                            petId: petId,
                            emoji: mood['icon'],
                            description: mood['description'],
                            dateTime: eventDateTime,
                          );

                          ref.read(eventMoodServiceProvider).addMood(newMood);

                          Event newEvent = Event(
                              id: eventId,
                              title: 'Mood',
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
                              description: mood['description'],
                              proffesionId: 'BRAK',
                              personId: 'BRAK',
                              avatarImage: 'assets/images/dog_avatar_014.png',
                              emoticon: mood['icon'],
                              moodId: newMood.id,
                              stomachId: '',
                              psychicId: '',
                              stoolId: '',
                              urineId: '',
                              serviceId: '',
                              careId: '');

                          ref.read(eventServiceProvider).addEvent(newEvent);

                          Navigator.of(context)
                              .pop(); // Close the confirmation dialog
                          Navigator.of(context).pop(); // Close the bottom sheet
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: CircleAvatar(
              radius: iconSize / 2,
              backgroundColor: mood['color'],
              child: Text(
                mood['icon'],
                style: TextStyle(fontSize: iconSize / 2),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
