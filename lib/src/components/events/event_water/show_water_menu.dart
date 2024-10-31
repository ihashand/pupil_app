import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_water_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_water_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';

void showWaterMenu(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  var amountController = TextEditingController(text: '0');
  var nameController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  TimeOfDay? selectedTime;
  bool showDetails = false;

  final double screenHeight = MediaQuery.of(context).size.height;
  double initialSize = screenHeight > 800 ? 0.25 : 0.3;
  double detailsSize = screenHeight > 800 ? 0.5 : 0.6;
  double maxSize = screenHeight > 800 ? 1 : 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                            'W A T E R',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () async {
                              String eventId = generateUniqueId();
                              double waterAmount =
                                  double.tryParse(amountController.text) ?? 0;
                              if (waterAmount > 0) {
                                String userId = ref.read(userIdProvider)!;
                                if (petIds != null && petIds.isNotEmpty) {
                                  for (String id in petIds) {
                                    _saveWaterEvent(
                                      ref,
                                      id,
                                      eventId,
                                      userId,
                                      waterAmount,
                                      selectedDateTime,
                                      name: nameController.text.isNotEmpty
                                          ? nameController.text
                                          : null,
                                      time: selectedTime,
                                    );
                                  }
                                } else if (petId != null) {
                                  _saveWaterEvent(
                                    ref,
                                    petId,
                                    eventId,
                                    userId,
                                    waterAmount,
                                    selectedDateTime,
                                    name: nameController.text.isNotEmpty
                                        ? nameController.text
                                        : null,
                                    time: selectedTime,
                                  );
                                }
                                Navigator.of(context).pop();
                              }
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
                                      double currentAmount = double.tryParse(
                                              amountController.text) ??
                                          0;
                                      if (currentAmount > 0) {
                                        setState(() {
                                          amountController.text =
                                              (currentAmount - 50).toString();
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    width: 150,
                                    height: 35,
                                    child: TextField(
                                      controller: amountController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*')),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: 'ml',
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
                                      double currentAmount = double.tryParse(
                                              amountController.text) ??
                                          0;
                                      setState(() {
                                        amountController.text =
                                            (currentAmount + 50).toString();
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
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: SizedBox(
                                  width: 350,
                                  height: 45,
                                  child: TextField(
                                    controller: nameController,
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Name (optional)',
                                      labelStyle: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12.0, bottom: 5),
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

void _saveWaterEvent(
  WidgetRef ref,
  String petId,
  String eventId,
  String userId,
  double waterAmount,
  DateTime dateTime, {
  String? name,
  TimeOfDay? time,
}) {
  final newWaterEvent = EventWaterModel(
    id: eventId,
    eventId: eventId,
    petId: petId,
    userId: userId,
    water: waterAmount,
    dateTime: dateTime,
    name: name,
    time: time,
  );
  ref.read(eventWaterServiceProvider).addWater(newWaterEvent);

  final description = [
    '$waterAmount ml water',
    if (name != null) 'Name: $name',
  ].join(', ');

  final newEvent = Event(
    id: eventId,
    title: 'Water Intake',
    eventDate: dateTime,
    dateWhenEventAdded: DateTime.now(),
    userId: userId,
    petId: petId,
    description: description,
    avatarImage: 'assets/images/water_bowl.png',
    emoticon: '💧',
  );
  ref.read(eventServiceProvider).addEvent(newEvent, petId);
}
