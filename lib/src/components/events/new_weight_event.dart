import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';

class NewWeightEvent extends ConsumerWidget {
  final double iconSize;
  final Color iconColor;
  final String petId;
  final DateTime eventDateTime;

  const NewWeightEvent({
    super.key,
    required this.iconSize,
    required this.iconColor,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const IconData iconData = Icons.monitor_weight;
    var nameController = TextEditingController();
    double initialWeight = 0;

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
                    labelText: 'Weight',
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
                      initialWeight = double.tryParse(fixedValue) ?? 0.0;
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
                              color:
                                  Theme.of(context).colorScheme.inverseSurface),
                        ),
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              initialWeight <= 0.0) {
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
                                    child: Text('Weight field cannot be empty.',
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

                          if (initialWeight > 200.0) {
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
                                    child: Text('Weight cannot exceed 200 kg.',
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
                          String weightId = generateUniqueId();
                          Weight newWeight = Weight(
                              id: weightId,
                              eventId: eventId,
                              petId: petId,
                              weight: initialWeight,
                              dateTime: DateTime.now());

                          Event newEvent = Event(
                              id: eventId,
                              eventDate: eventDateTime,
                              dateWhenEventAdded: DateTime.now(),
                              title: 'Weight',
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              petId: petId,
                              weightId: newWeight.id,
                              temperatureId: '',
                              walkId: '',
                              waterId: '',
                              noteId: '',
                              pillId: '',
                              description: '$initialWeight',
                              proffesionId: 'BRAK',
                              personId: 'BRAK',
                              avatarImage: 'assets/images/dog_avatar_012.png',
                              emoticon: '⚖️');

                          ref.read(eventServiceProvider).addEvent(newEvent);
                          ref.read(weightServiceProvider).addWeight(newWeight);

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
