import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_stomach_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_stomach_provider.dart';

class EventStomach extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const EventStomach({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> stomachIssues = [
      {'icon': '🤢', 'color': Colors.transparent, 'description': 'Bloating'},
      {'icon': '🤮', 'color': Colors.transparent, 'description': 'Vomiting'},
      {'icon': '💩', 'color': Colors.transparent, 'description': 'Diarrhea'},
      {'icon': '🤧', 'color': Colors.transparent, 'description': 'Indigestion'},
      {'icon': '😷', 'color': Colors.transparent, 'description': 'Gas'},
      {
        'icon': '😩',
        'color': Colors.transparent,
        'description': 'Constipation'
      },
      {'icon': '🍔', 'color': Colors.transparent, 'description': 'Hunger'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stomachIssues.map((issue) {
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
                          title: const Text('Confirm Stomach Issue'),
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

                                EventStomachModel newStomach =
                                    EventStomachModel(
                                  id: generateUniqueId(),
                                  eventId: eventId,
                                  petId: petId,
                                  emoji: issue['icon'],
                                  description: issue['description'],
                                  dateTime: eventDateTime,
                                );

                                ref
                                    .read(eventStomachServiceProvider)
                                    .addStomach(newStomach);

                                Event newEvent = Event(
                                  id: eventId,
                                  title: 'Stomach',
                                  eventDate: eventDateTime,
                                  dateWhenEventAdded: DateTime.now(),
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  petId: petId,
                                  description: issue['description'],
                                  avatarImage:
                                      'assets/images/dog_avatar_014.png',
                                  emoticon: issue['icon'],
                                  stomachId: newStomach.id,
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
