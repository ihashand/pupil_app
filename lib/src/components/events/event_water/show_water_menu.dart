import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_water_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_water_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';

void showWaterMenu(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  var amountController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  bool showDetails = false;
  int selectedWaterLevel = 0; // 0 - brak, 1 - mało, 2 - średnio, 3 - dużo

  final double screenHeight = MediaQuery.of(context).size.height;

  // Definiujemy proporcje dla różnych rozmiarów ekranu
  double initialSize = screenHeight > 800 ? 0.45 : 0.55;
  double maxSize = screenHeight > 800 ? 0.85 : 0.9;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: initialSize,
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 12.0),
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
                              'W A T E R',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.check,
                                  color: Theme.of(context).primaryColorDark),
                              onPressed: () async {
                                String eventId = generateUniqueId();
                                double? waterAmount = showDetails
                                    ? double.tryParse(amountController.text)
                                    : null;
                                String? waterLevel;
                                if (!showDetails) {
                                  waterLevel = selectedWaterLevel == 1
                                      ? 'Low'
                                      : selectedWaterLevel == 2
                                          ? 'Medium'
                                          : selectedWaterLevel == 3
                                              ? 'High'
                                              : null;
                                }
                                if (petIds != null && petIds.isNotEmpty) {
                                  for (String id in petIds) {
                                    _saveWaterEvent(
                                        ref,
                                        id,
                                        eventId,
                                        waterAmount,
                                        waterLevel,
                                        selectedDateTime);
                                  }
                                } else if (petId != null) {
                                  _saveWaterEvent(
                                      ref,
                                      petId,
                                      eventId,
                                      waterAmount,
                                      waterLevel,
                                      selectedDateTime);
                                }

                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            if (showDetails)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextFormField(
                                  controller: amountController,
                                  decoration: InputDecoration(
                                    labelText: 'Amount (ml)',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
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
                                  keyboardType: TextInputType.number,
                                ),
                              )
                            else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(3, (index) {
                                  int level = index + 1;
                                  Color color;
                                  if (level == 1) {
                                    color = Colors.green;
                                  } else if (level == 2) {
                                    color = Colors.amber;
                                  } else {
                                    color = Colors.red;
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedWaterLevel = level;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.water_drop,
                                          size: 50,
                                          color: selectedWaterLevel == level
                                              ? color
                                              : Colors.blue,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          level == 1
                                              ? 'Low'
                                              : level == 2
                                                  ? 'Medium'
                                                  : 'High',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    showDetails = !showDetails;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                                child: Text(
                                  showDetails ? 'Water Level' : 'Amount in ml',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 8),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate =
                                await showStyledDatePicker(
                              context: context,
                              initialDate: selectedDateTime,
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDateTime = pickedDate;
                              });
                            }
                          },
                          child: Center(
                            child: Text(
                              'Date: ${DateFormat('dd-MM-yyyy').format(selectedDateTime)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 16,
                              ),
                            ),
                          ),
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

void _saveWaterEvent(WidgetRef ref, String petId, String eventId,
    double? waterAmount, String? waterLevel, DateTime dateTime) {
  final description = [
    if (waterAmount != null) '$waterAmount ml water',
    if (waterLevel != null) 'Water intake: $waterLevel',
  ].join(', ');

  final newWaterEvent = EventWaterModel(
    id: eventId,
    eventId: eventId,
    petId: petId,
    water: waterAmount,
    waterLevel: waterLevel,
    dateTime: dateTime,
  );

  final newEvent = Event(
    id: eventId,
    title: 'Water Intake',
    eventDate: dateTime,
    dateWhenEventAdded: DateTime.now(),
    userId: ref.read(userIdProvider)!,
    petId: petId,
    description: description,
    avatarImage: 'assets/images/water_bowl.png',
    emoticon: '💧',
  );

  ref.read(eventWaterServiceProvider).addWater(newWaterEvent);
  ref.read(eventServiceProvider).addEvent(newEvent, petId);
}
