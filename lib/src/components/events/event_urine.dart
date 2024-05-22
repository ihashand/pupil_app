import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_urine_model.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/event_urine_provider.dart';

class EventUrine extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;

  const EventUrine({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> urineColors = [
      {
        'color': Colors.white,
        'description': 'Transparent: Your dog is over-hydrated'
      },
      {
        'color': const Color.fromARGB(255, 236, 226, 139),
        'description': 'Pale yellow: Perfect!'
      },
      {
        'color': const Color.fromARGB(255, 158, 142, 2),
        'description':
            'Dark yellow: Your dog is dehydrated – encourage drinking more'
      },
      {
        'color': Colors.red,
        'description':
            'Red or pink: Possible UTI, kidney infection or other illness – see a vet'
      },
      {
        'color': Colors.green,
        'description': 'Green: Possible kidney problems – see a vet'
      },
      {
        'color': Colors.brown,
        'description':
            'Brown: Possible internal bleeding or toxic reaction – seek immediate medical attention'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: urineColors.map((urine) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Urine Color'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              'Are you sure you want to add this urine color?'),
                          Container(
                            width: 50,
                            height: 50,
                            color: urine['color'],
                          ),
                          Text(urine['description']),
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

                            EventUrineModel newUrine = EventUrineModel(
                              id: generateUniqueId(),
                              eventId: eventId,
                              petId: petId,
                              color: urine['color'].toString(),
                              description: urine['description'],
                              dateTime: eventDateTime,
                            );

                            ref
                                .read(eventUrineServiceProvider)
                                .addUrineEvent(newUrine);
                            Event newEvent = Event(
                                id: eventId,
                                title: 'Urine',
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
                                description: urine['description'],
                                proffesionId: 'BRAK',
                                personId: 'BRAK',
                                avatarImage: 'assets/images/dog_avatar_014.png',
                                emoticon: '💦',
                                moodId: '',
                                stomachId: '',
                                psychicId: '',
                                stoolId: '',
                                urineId: newUrine.id,
                                serviceId: '');

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
              child: Container(
                width: iconSize,
                height: iconSize,
                color: urine['color'],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
