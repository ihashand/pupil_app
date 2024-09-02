import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';
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
      {'icon': '😄', 'description': 'Happy'},
      {'icon': '😃', 'description': 'Excited'},
      {'icon': '😊', 'description': 'Content'},
      {'icon': '😐', 'description': 'Neutral'},
      {'icon': '😴', 'description': 'Tired'},
      {'icon': '😢', 'description': 'Sad'},
      {'icon': '😠', 'description': 'Angry'},
      {'icon': '😡', 'description': 'Furious'},
      {'icon': '😭', 'description': 'Crying'},
      {'icon': '😞', 'description': 'Disappointed'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: moods.map((mood) {
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
                          title: const Text('Confirm Mood'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  'Are you sure you want to add this mood?'),
                              Text(
                                mood['icon'],
                                style: const TextStyle(fontSize: 70),
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
                                int moodRating =
                                    EventMoodModel.determineMoodRating(
                                        mood['icon']);
                                EventMoodModel newMood = EventMoodModel(
                                  id: generateUniqueId(),
                                  eventId: eventId,
                                  petId: petId,
                                  emoji: mood['icon'],
                                  description: mood['description'],
                                  dateTime: eventDateTime,
                                  moodRating: moodRating,
                                );

                                ref
                                    .read(eventMoodServiceProvider)
                                    .addMood(newMood);

                                Event newEvent = Event(
                                    id: eventId,
                                    title: 'Mood',
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
                                    description: mood['description'],
                                    proffesionId: 'NONE',
                                    personId: 'NONE',
                                    avatarImage:
                                        'assets/images/dog_avatar_014.png',
                                    emoticon: mood['icon'],
                                    moodId: newMood.id,
                                    stomachId: '',
                                    psychicId: '',
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
                    backgroundColor: Colors.transparent,
                    child: Text(
                      mood['icon'],
                      style: TextStyle(fontSize: iconSize / 2),
                    ),
                  ),
                ),
                Text(
                  mood['description'],
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
