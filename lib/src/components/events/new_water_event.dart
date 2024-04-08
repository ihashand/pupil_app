import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';

class NewWaterEvent extends ConsumerWidget {
  final double iconSize;
  final Color iconColor;
  final String petId;
  final DateTime eventDateTime;

  const NewWaterEvent({
    super.key,
    required this.iconSize,
    required this.iconColor,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const IconData iconData = Icons.water_drop;
    var nameController = TextEditingController();
    double initialWater = 0;

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
                    labelText: 'Water',
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
                      initialWater = double.tryParse(fixedValue) ?? 0.0;
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
                              initialWater <= 0.0) {
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
                                    child: Text('Water field cannot be empty.',
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

                          if (initialWater > 50.0) {
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
                                        'Water cannot exceed 50 liters.',
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
                          Pet? pet = ref
                              .read(petRepositoryProvider)
                              .value
                              ?.getPetById(petId);

                          Water newWater = Water();
                          newWater.id = generateUniqueId();

                          // water
                          if (newWater.id != '') {
                            newWater.eventId = eventId;
                            newWater.petId = petId;
                            newWater.water = initialWater;
                            newWater.dateTime = eventDateTime;

                            Event newEvent = Event(
                                id: eventId,
                                title: 'Water',
                                eventDate: eventDateTime,
                                dateWhenEventAdded: DateTime.now(),
                                userId: pet!.userId,
                                petId: petId,
                                weightId: '',
                                temperatureId: '',
                                walkId: '',
                                waterId: newWater.id,
                                noteId: '',
                                pillId: '',
                                description: 'Drinked: $initialWater ',
                                proffesionId: 'BRAK',
                                personId: 'BRAK',
                                avatarImage: 'assets/images/dog_avatar_014.png',
                                emoticon: '💧');

                            ref
                                .read(eventRepositoryProvider)
                                .value
                                ?.addEvent(newEvent);
                            ref
                                .read(waterRepositoryProvider)
                                .value
                                ?.addWater(newWater);

                            ref.invalidate(waterRepositoryProvider);
                            ref.invalidate(eventRepositoryProvider);
                          }
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
