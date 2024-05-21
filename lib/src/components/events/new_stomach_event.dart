import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/stomach_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/stomach_provider.dart';

class NewStomachEvent extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const NewStomachEvent({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> stomachIssues = [
      {
        'icon': '🤢',
        'color': Colors.green.withOpacity(0.6),
        'description': 'Wzdęcia'
      },
      {
        'icon': '🤮',
        'color': Colors.lightGreen.withOpacity(0.6),
        'description': 'Wymioty'
      },
      {
        'icon': '💩',
        'color': Colors.brown.withOpacity(0.6),
        'description': 'Biegunka'
      },
      {
        'icon': '🤧',
        'color': Colors.orange.withOpacity(0.6),
        'description': 'Niestrawność'
      },
      {
        'icon': '😷',
        'color': Colors.grey.withOpacity(0.6),
        'description': 'Gazy'
      },
      {
        'icon': '😩',
        'color': Colors.blueAccent.withOpacity(0.6),
        'description': 'Zaparcia'
      },
      {
        'icon': '🍔',
        'color': Colors.redAccent.withOpacity(0.6),
        'description': 'Głód'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stomachIssues.map((issue) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
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

                            Stomach newStomach = Stomach(
                              id: generateUniqueId(),
                              eventId: eventId,
                              petId: petId,
                              emoji: issue['icon'],
                              description: issue['description'],
                              dateTime: eventDateTime,
                            );

                            ref
                                .read(stomachServiceProvider)
                                .addStomach(newStomach);

                            Event newEvent = Event(
                                id: eventId,
                                title: 'Stomach',
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
                                stomachId: newStomach.id);

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
