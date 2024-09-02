import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_temperature_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/event_temperature_provider.dart';

class EventTemperature extends ConsumerStatefulWidget {
  final double iconSize;
  final Color iconColor;
  final String petId;
  final DateTime eventDateTime;

  const EventTemperature({
    super.key,
    required this.iconSize,
    required this.iconColor,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  createState() => _NewTemperatureEventState();
}

class _NewTemperatureEventState extends ConsumerState<EventTemperature> {
  final TextEditingController nameController = TextEditingController();
  double initialTemperature = 0;
  String selectedValue = '';

  @override
  Widget build(BuildContext context) {
    const IconData iconData = Icons.thermostat;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 70,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Temperature',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.5),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (value) {
                              final fixedValue = value.replaceAll(',', '.');
                              initialTemperature =
                                  double.tryParse(fixedValue) ?? 0.0;
                              setState(() {
                                selectedValue = '';
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTemperatureButton(context, '35.0', () {
                            setState(() {
                              initialTemperature = 35.0;
                              nameController.text = '35.0';
                              selectedValue = '35.0';
                            });
                          }, selectedValue),
                          _buildTemperatureButton(context, '36.0', () {
                            setState(() {
                              initialTemperature = 36.0;
                              nameController.text = '36.0';
                              selectedValue = '36.0';
                            });
                          }, selectedValue),
                          _buildTemperatureButton(context, '36.6', () {
                            setState(() {
                              initialTemperature = 36.6;
                              nameController.text = '36.6';
                              selectedValue = '36.6';
                            });
                          }, selectedValue),
                          _buildTemperatureButton(context, '37.5', () {
                            setState(() {
                              initialTemperature = 37.5;
                              nameController.text = '37.5';
                              selectedValue = '37.5';
                            });
                          }, selectedValue),
                        ],
                      ),
                    ],
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface),
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

                              EventTemperatureModel newTemperature =
                                  EventTemperatureModel(
                                      id: generateUniqueId(),
                                      eventId: eventId,
                                      petId: widget.petId,
                                      temperature: initialTemperature);

                              Event newEvent = Event(
                                  id: eventId,
                                  eventDate: widget.eventDateTime,
                                  dateWhenEventAdded: DateTime.now(),
                                  title: 'Temperature',
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  petId: widget.petId,
                                  weightId: '',
                                  temperatureId: newTemperature.id,
                                  walkId: '',
                                  waterId: '',
                                  noteId: '',
                                  pillId: '',
                                  moodId: '',
                                  stomachId: '',
                                  description: '$initialTemperature',
                                  proffesionId: 'BRAK',
                                  personId: 'BRAK',
                                  avatarImage:
                                      'assets/images/dog_avatar_014.png',
                                  emoticon: '🌡️',
                                  psychicId: '',
                                  stoolId: '',
                                  urineId: '',
                                  serviceId: '',
                                  careId: '');

                              ref
                                  .read(eventTemperatureServiceProvider)
                                  .addTemperature(newTemperature);
                              ref.read(eventServiceProvider).addEvent(newEvent);

                              Navigator.of(context).pop();
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
        );
      },
      child: Icon(
        iconData,
        size: widget.iconSize,
        color: widget.iconColor,
      ),
    );
  }

  Widget _buildTemperatureButton(BuildContext context, String label,
      Function onPressed, String selectedValue) {
    final isSelected = selectedValue == label;
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context)
            .colorScheme
            .secondary
            .withOpacity(isSelected ? 0.3 : 0.7),
        child: Text(
          label,
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 13),
        ),
      ),
    );
  }
}
