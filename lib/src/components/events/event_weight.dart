import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_weight_provider.dart';

class EventWeight extends ConsumerStatefulWidget {
  final double iconSize;
  final Color iconColor;
  final String petId;
  final DateTime eventDateTime;

  const EventWeight({
    super.key,
    required this.iconSize,
    required this.iconColor,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  createState() => _EventWeightState();
}

class _EventWeightState extends ConsumerState<EventWeight> {
  final TextEditingController nameController = TextEditingController();
  double initialWeight = 0;
  String selectedValue = '';

  @override
  Widget build(BuildContext context) {
    const IconData iconData = Icons.monitor_weight;

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
                            labelText: 'Weight',
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
                              initialWeight =
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
                          _buildWeightButton(context, '2.5', () {
                            setState(() {
                              initialWeight = 2.5;
                              nameController.text = '2.5';
                              selectedValue = '2.5';
                            });
                          }, selectedValue),
                          _buildWeightButton(context, '5', () {
                            setState(() {
                              initialWeight = 5.0;
                              nameController.text = '5';
                              selectedValue = '5';
                            });
                          }, selectedValue),
                          _buildWeightButton(context, '10', () {
                            setState(() {
                              initialWeight = 10.0;
                              nameController.text = '10';
                              selectedValue = '10';
                            });
                          }, selectedValue),
                          _buildWeightButton(context, '25', () {
                            setState(() {
                              initialWeight = 25.0;
                              nameController.text = '25';
                              selectedValue = '25';
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
                                        child: Text(
                                            'Weight field cannot be empty.',
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
                                        child: Text(
                                            'Weight cannot exceed 200 kg.',
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
                              EventWeightModel newWeight = EventWeightModel(
                                  id: weightId,
                                  eventId: eventId,
                                  petId: widget.petId,
                                  weight: initialWeight,
                                  dateTime: DateTime.now());

                              Event newEvent = Event(
                                  id: eventId,
                                  eventDate: widget.eventDateTime,
                                  dateWhenEventAdded: DateTime.now(),
                                  title: 'Weight',
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  petId: widget.petId,
                                  weightId: newWeight.id,
                                  temperatureId: '',
                                  walkId: '',
                                  waterId: '',
                                  noteId: '',
                                  pillId: '',
                                  moodId: '',
                                  stomachId: '',
                                  description: '$initialWeight',
                                  proffesionId: 'BRAK',
                                  personId: 'BRAK',
                                  avatarImage:
                                      'assets/images/dog_avatar_012.png',
                                  emoticon: '⚖️',
                                  psychicId: '',
                                  stoolId: '',
                                  urineId: '',
                                  serviceId: '',
                                  careId: '');

                              ref.read(eventServiceProvider).addEvent(newEvent);
                              ref
                                  .read(eventWeightServiceProvider)
                                  .addWeight(newWeight);

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

  Widget _buildWeightButton(BuildContext context, String label,
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
            .primary
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
