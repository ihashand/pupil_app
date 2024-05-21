import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/water_provider.dart';

class NewWaterEvent extends ConsumerStatefulWidget {
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
  createState() => _NewWaterEventState();
}

class _NewWaterEventState extends ConsumerState<NewWaterEvent> {
  final TextEditingController nameController = TextEditingController();
  double initialWater = 0;
  String selectedValue = '';

  @override
  Widget build(BuildContext context) {
    const IconData iconData = Icons.water_drop;

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
                            labelText: 'Water',
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
                              initialWater = double.tryParse(fixedValue) ?? 0.0;
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
                          _buildWaterButton(context, '0.1', () {
                            setState(() {
                              initialWater = 0.1;
                              nameController.text = '0.1';
                              selectedValue = '0.1';
                            });
                          }, selectedValue),
                          _buildWaterButton(context, '0.2', () {
                            setState(() {
                              initialWater = 0.2;
                              nameController.text = '0.2';
                              selectedValue = '0.2';
                            });
                          }, selectedValue),
                          _buildWaterButton(context, '0.5', () {
                            setState(() {
                              initialWater = 0.5;
                              nameController.text = '0.5';
                              selectedValue = '0.5';
                            });
                          }, selectedValue),
                          _buildWaterButton(context, '1', () {
                            setState(() {
                              initialWater = 1.0;
                              nameController.text = '1';
                              selectedValue = '1';
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
                                        child:
                                            Text('Water field cannot be empty.',
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

                              Water newWater = Water(
                                  id: generateUniqueId(),
                                  eventId: eventId,
                                  petId: widget.petId,
                                  water: initialWater,
                                  dateTime: widget.eventDateTime);

                              Event newEvent = Event(
                                  id: eventId,
                                  title: 'Water',
                                  eventDate: widget.eventDateTime,
                                  dateWhenEventAdded: DateTime.now(),
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  petId: widget.petId,
                                  weightId: '',
                                  temperatureId: '',
                                  walkId: '',
                                  waterId: newWater.id,
                                  noteId: '',
                                  pillId: '',
                                  moodId: '',
                                  stomachId: '',
                                  description: '$initialWater ',
                                  proffesionId: 'BRAK',
                                  personId: 'BRAK',
                                  avatarImage:
                                      'assets/images/dog_avatar_014.png',
                                  emoticon: '💧',
                                  psychicId: '',
                                  stoolId: '',
                                  urineId: '');

                              ref.read(eventServiceProvider).addEvent(newEvent);
                              ref.read(waterServiceProvider).addWater(newWater);

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

  Widget _buildWaterButton(BuildContext context, String label,
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
