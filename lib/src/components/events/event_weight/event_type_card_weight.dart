import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_weight_provider.dart';

void showWeightModal(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  DateTime selectedDateTime = DateTime.now();
  TimeOfDay? selectedTime;
  TextEditingController weightController = TextEditingController(text: '0.0');
  double initialWeight = 0.0;
  bool showDetails = false;

  final double screenHeight = MediaQuery.of(context).size.height;
  double initialSize = screenHeight > 800 ? 0.25 : 0.3;
  double detailsSize = screenHeight > 800 ? 0.43 : 0.55;
  double maxSize = screenHeight > 800 ? 1 : 1;

  void recordWeightEvent() {
    String eventId = generateUniqueId();
    if (petIds != null && petIds.isNotEmpty) {
      for (String id in petIds) {
        _saveWeightEvent(context, ref, id, initialWeight, eventId,
            selectedDateTime, selectedTime);
      }
    } else if (petId != null) {
      _saveWeightEvent(context, ref, petId, initialWeight, eventId,
          selectedDateTime, selectedTime);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
                            'W E I G H T',
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
                              if (initialWeight <= 0.0) {
                                _showErrorDialog(
                                    context, 'Weight field cannot be empty.');
                                return;
                              }
                              if (initialWeight > 200.0) {
                                _showErrorDialog(
                                    context, 'Weight cannot exceed 200 kg.');
                                return;
                              }
                              recordWeightEvent();
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
                                      if (initialWeight > 0.0) {
                                        setState(() {
                                          initialWeight = (initialWeight - 0.5)
                                              .clamp(0, 200.0);
                                          weightController.text =
                                              initialWeight.toStringAsFixed(1);
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    width: 100,
                                    height: 35,
                                    child: TextField(
                                      controller: weightController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final fixedValue =
                                            value.replaceAll(',', '.');
                                        initialWeight =
                                            double.tryParse(fixedValue) ?? 0.0;
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'kg',
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
                                      if (initialWeight < 200.0) {
                                        setState(() {
                                          initialWeight = (initialWeight + 0.5)
                                              .clamp(0, 200.0);
                                          weightController.text =
                                              initialWeight.toStringAsFixed(1);
                                        });
                                      }
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
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: SizedBox(
                                  width: 350,
                                  height: 45,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final DateTime? pickedDate =
                                          await showStyledDatePicker(
                                        context: context,
                                        initialDate: selectedDateTime,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          selectedDateTime = pickedDate;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Select Date',
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 13,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        DateFormat('dd-MM-yyyy')
                                            .format(selectedDateTime),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: SizedBox(
                                  width: 350,
                                  height: 45,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final TimeOfDay? pickedTime =
                                          await showStyledTimePicker(
                                        context: context,
                                        initialTime:
                                            selectedTime ?? TimeOfDay.now(),
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
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 13,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        selectedTime != null
                                            ? selectedTime!.format(context)
                                            : 'Select Time',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 11,
                                        ),
                                      ),
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

// Funkcja pomocnicza do zapisywania eventu Weight
void _saveWeightEvent(
    BuildContext context,
    WidgetRef ref,
    String petId,
    double initialWeight,
    String eventId,
    DateTime selectedDate,
    TimeOfDay? time) {
  String weightId = generateUniqueId();
  EventWeightModel newWeight = EventWeightModel(
    id: weightId,
    eventId: eventId,
    petId: petId,
    userId: FirebaseAuth.instance.currentUser!.uid,
    weight: initialWeight,
    dateTime: selectedDate,
    time: time ?? TimeOfDay.now(),
  );

  Event newEvent = Event(
    id: eventId,
    eventDate: selectedDate,
    dateWhenEventAdded: DateTime.now(),
    title: 'Weight',
    userId: FirebaseAuth.instance.currentUser!.uid,
    petId: petId,
    weightId: newWeight.id,
    description: '$initialWeight kg',
    avatarImage: 'assets/images/dog_avatar_012.png',
    emoticon: '⚖️',
  );

  ref.read(eventServiceProvider).addEvent(newEvent);
  ref.read(eventWeightServiceProvider).addWeight(newWeight);
}

// Funkcja wyświetlająca dialog błędu
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Invalid Input',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark, fontSize: 24)),
        content: SizedBox(
          width: 250,
          child: Text(message,
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 16)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 20),
            ),
          ),
        ],
      );
    },
  );
}

// Główny widget eventTypeCardWeight
Widget eventTypeCardWeight(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'W E I G H T',
    'assets/images/events_type_cards_no_background/weight.png',
    () {
      showWeightModal(context, ref, petId: petId, petIds: petIds);
    },
  );
}
