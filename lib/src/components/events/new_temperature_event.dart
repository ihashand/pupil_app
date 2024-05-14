import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/temperature_provider.dart';

class NewTemperatureEvent extends ConsumerWidget {
  final double iconSize;
  final Color iconColor;
  final String petId;
  final DateTime eventDateTime;

  const NewTemperatureEvent({
    super.key,
    required this.iconSize,
    required this.iconColor,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const IconData iconData = Icons.thermostat;
    var nameController = TextEditingController();
    double initialTemperature = 0;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SizedBox(
                width: 250,
                height: 70,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Temperature',
                    border: OutlineInputBorder(),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    cursorColor:
                        Theme.of(context).primaryColorDark.withOpacity(0.5),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final fixedValue = value.replaceAll(',', '.');
                      initialTemperature = double.tryParse(fixedValue) ?? 0.0;
                    },
                  ),
                ),
              ),
              actions: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              initialTemperature <= 0.0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Invalid Input',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 20)),
                                  content: SizedBox(
                                    width: 250,
                                    child: Text(
                                        'Temperature field cannot be empty.',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        )),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          if (initialTemperature > 50.0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Invalid Input',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 24)),
                                  content: SizedBox(
                                    width: 250,
                                    child: Text(
                                        'Temperature cannot exceed 50 degrees.',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 16)),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          String eventId = generateUniqueId();

                          Temperature newTemperature = Temperature(
                              id: generateUniqueId(),
                              eventId: eventId,
                              petId: petId,
                              temperature: initialTemperature);

                          Event newEvent = Event(
                              id: eventId,
                              eventDate: eventDateTime,
                              dateWhenEventAdded: DateTime.now(),
                              title: 'Temperature',
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              petId: petId,
                              weightId: '',
                              temperatureId: newTemperature.id,
                              walkId: '',
                              waterId: '',
                              noteId: '',
                              pillId: '',
                              description: '$initialTemperature',
                              proffesionId: 'BRAK',
                              personId: 'BRAK',
                              avatarImage: 'assets/images/dog_avatar_014.png',
                              emoticon: '🌡️');

                          ref
                              .read(temperatureServiceProvider)
                              .addTemperature(newTemperature);

                          ref.read(eventServiceProvider).addEvent(newEvent);

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(
        iconData,
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}
