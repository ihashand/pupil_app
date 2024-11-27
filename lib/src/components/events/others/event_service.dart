import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_service_event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_service_provider.dart';

class EventService extends ConsumerWidget {
  final double iconSize;
  final String petId;
  final DateTime eventDateTime;
  final String serviceType;

  const EventService({
    super.key,
    required this.iconSize,
    required this.petId,
    required this.eventDateTime,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> serviceEmojis = {
      'Groomer': '✂️',
      'Vet': '🩺',
      'Training': '🏋️',
      'Daycare': '🏫',
      'Hotel': '🏨',
    };

    final Map<String, Color> serviceColors = {
      'Groomer': Colors.transparent,
      'Vet': Colors.transparent,
      'Training': Colors.transparent,
      'Daycare': Colors.transparent,
      'Hotel': Colors.transparent,
    };

    final String? emoji = serviceEmojis[serviceType];
    final Color backgroundColor =
        serviceColors[serviceType] ?? Colors.grey.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add $serviceType Event'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                            'Are you sure you want to add this service event?'),
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 50),
                        ),
                        Text(serviceType),
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
                          String description = 'Service Event: $serviceType';

                          EventServiceModel newService = EventServiceModel(
                            id: generateUniqueId(),
                            eventId: eventId,
                            petId: petId,
                            serviceType: serviceType,
                            emoji: emoji,
                            description: description,
                            dateTime: eventDateTime,
                          );

                          ref
                              .read(eventServiceServiceProvider)
                              .addServiceEvent(newService);

                          Event newEvent = Event(
                            id: eventId,
                            title: serviceType,
                            eventDate: eventDateTime,
                            dateWhenEventAdded: DateTime.now(),
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            petId: petId,
                            description: description,
                            avatarImage: 'assets/images/dog_avatar_014.png',
                            emoticon: emoji,
                            serviceId: newService.id,
                          );

                          ref.read(eventServiceProvider).addEvent(newEvent);

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
              backgroundColor: backgroundColor,
              child: Text(
                emoji!,
                style: TextStyle(fontSize: iconSize / 2),
              ),
            ),
          ),
          Text(
            serviceType,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
