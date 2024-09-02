import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_vacine_provider.dart';

class EventVaccine extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const EventVaccine({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> stomachIssues = [
      {'icon': '🦠', 'color': Colors.transparent, 'description': 'Rabies'},
      {'icon': '💊', 'color': Colors.transparent, 'description': 'Distemper'},
      {'icon': '🧬', 'color': Colors.transparent, 'description': 'Hepatitis'},
      {'icon': '🧪', 'color': Colors.transparent, 'description': 'Bordatella'},
      {'icon': '💉', 'color': Colors.transparent, 'description': 'Parvovirus'},
      {
        'icon': '🐛',
        'color': Colors.transparent,
        'description': 'Leptospirosis'
      },
      {
        'icon': '🐕',
        'color': Colors.transparent,
        'description': 'Lyme Disease',
      },
      {
        'icon': '🦊',
        'color': Colors.transparent,
        'description': 'Coronavirus',
      },
      {
        'icon': '🌡️',
        'color': Colors.transparent,
        'description': 'Giardina',
      },
      {
        'icon': '🐍',
        'color': Colors.transparent,
        'description': 'Canine Influenza H3N8',
      },
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
                          title: const Text('Confirm Vaccine'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  'Are you sure you want to add this vaccine?'),
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

                                EventVaccineModel newVaccine =
                                    EventVaccineModel(
                                  id: generateUniqueId(),
                                  eventId: eventId,
                                  petId: petId,
                                  emoticon: issue['icon'],
                                  description: issue['description'],
                                  dateTime: eventDateTime,
                                );

                                ref
                                    .read(eventVaccineServiceProvider)
                                    .addVaccine(newVaccine);

                                Event newEvent = Event(
                                    id: eventId,
                                    title: 'Vaccine',
                                    eventDate: eventDateTime,
                                    dateWhenEventAdded: DateTime.now(),
                                    userId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    petId: petId,
                                    description: issue['description'],
                                    avatarImage:
                                        'assets/images/dog_avatar_014.png',
                                    emoticon: issue['icon'],
                                    vaccineId: newVaccine.id);

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
