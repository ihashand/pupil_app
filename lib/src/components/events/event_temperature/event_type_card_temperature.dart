import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_temperature_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_temperature_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';

void showTemperatureModal(
  BuildContext context,
  TextEditingController temperatureController,
  WidgetRef ref, {
  String? petId,
  List<String>? petIds,
}) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  temperatureController.text = '38.0';
  double initialTemperature = 38.0;
  bool showDetails = false;
  final double screenHeight = MediaQuery.of(context).size.height;
  double initialSize = screenHeight > 800 ? 0.25 : 0.3;
  double detailsSize = screenHeight > 800 ? 0.43 : 0.55;
  double maxSize = screenHeight > 800 ? 1 : 1;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: showDetails ? detailsSize : initialSize,
            minChildSize: initialSize,
            maxChildSize: maxSize,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            'T E M P E R A T U R E',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () {
                              double enteredTemperature = double.tryParse(
                                      temperatureController.text
                                          .replaceAll(',', '.')) ??
                                  0.0;
                              if (enteredTemperature <= 0.0 ||
                                  enteredTemperature > 50.0) {
                                _showErrorDialog(
                                  context,
                                  'Please enter a valid temperature between 0 and 50 degrees.',
                                );
                                return;
                              }
                              recordTemperatureEvent(
                                context,
                                ref,
                                petId: petId,
                                petIds: petIds,
                                initialTemperature: enteredTemperature,
                                selectedDate: selectedDate,
                                selectedTime: selectedTime,
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    iconSize: 30,
                                    color: Theme.of(context).primaryColorDark,
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        initialTemperature =
                                            (initialTemperature - 0.5)
                                                .clamp(0, 50.0);
                                        temperatureController.text =
                                            initialTemperature
                                                .toStringAsFixed(1);
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 100,
                                    height: 35,
                                    child: TextField(
                                      controller: temperatureController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        initialTemperature = double.tryParse(
                                                value.replaceAll(',', '.')) ??
                                            0.0;
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        labelText: '°C',
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 14,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 30,
                                    color: Theme.of(context).primaryColorDark,
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        initialTemperature =
                                            (initialTemperature + 0.5)
                                                .clamp(0, 50.0);
                                        temperatureController.text =
                                            initialTemperature
                                                .toStringAsFixed(1);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 150,
                                height: 30,
                                child: showDetails
                                    ? IconButton(
                                        icon: const Icon(Icons.more_horiz),
                                        onPressed: () {
                                          setState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(0.6),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: Text(
                                          "M O R E",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showStyledDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Date',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 13,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(selectedDate),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final TimeOfDay? pickedTime =
                                      await showStyledTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Time',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 13,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    selectedTime.format(context),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

void recordTemperatureEvent(
  BuildContext context,
  WidgetRef ref, {
  required double initialTemperature,
  required DateTime selectedDate,
  required TimeOfDay selectedTime,
  String? petId,
  List<String>? petIds,
}) {
  String eventId = generateUniqueId();
  if (petIds != null && petIds.isNotEmpty) {
    for (String id in petIds) {
      _saveTemperatureEvent(context, ref, id, initialTemperature, eventId,
          selectedDate, selectedTime);
    }
  } else if (petId != null) {
    _saveTemperatureEvent(context, ref, petId, initialTemperature, eventId,
        selectedDate, selectedTime);
  }
}

void _saveTemperatureEvent(
  BuildContext context,
  WidgetRef ref,
  String petId,
  double initialTemperature,
  String eventId,
  DateTime selectedDate,
  TimeOfDay selectedTime,
) {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  EventTemperatureModel newTemperature = EventTemperatureModel(
    id: generateUniqueId(),
    eventId: eventId,
    petId: petId,
    userId: userId,
    temperature: initialTemperature,
    dateTime: selectedDate,
    time: selectedTime,
  );

  Event newEvent = Event(
    id: eventId,
    title: 'Temperature',
    eventDate: selectedDate,
    dateWhenEventAdded: DateTime.now(),
    userId: userId,
    petId: petId,
    temperatureId: newTemperature.id,
    description: '$initialTemperature°C',
    avatarImage: 'assets/images/dog_avatar_014.png',
    emoticon: '🌡️',
  );

  ref.read(eventTemperatureServiceProvider).addTemperature(newTemperature);
  ref.read(eventServiceProvider).addEvent(newEvent);
}

// Funkcja wyświetlająca dialog błędu
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Invalid Input',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 24,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Główny widget eventTypeCardTemperature
Widget eventTypeCardTemperature(BuildContext context,
    TextEditingController temperatureController, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'T E M P E R A T U R E',
    'assets/images/events_type_cards_no_background/thermometr.png',
    () {
      showTemperatureModal(context, temperatureController, ref,
          petId: petId, petIds: petIds);
    },
  );
}
