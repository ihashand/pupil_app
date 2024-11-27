import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/build_icon_for_event.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_food_simple_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_food_simple_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';

void showFoodSimpleMenu(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  var amountController = TextEditingController();
  var nameController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  TimeOfDay? selectedTime;
  String selectedFoodType = '';
  int? satisfactionLevel;
  bool showDetails = false;

  final double screenHeight = MediaQuery.of(context).size.height;
  double initialSize = screenHeight > 800 ? 0.29 : 0.35;
  double detailsSize = screenHeight > 800 ? 0.72 : 0.9;
  double maxSize = screenHeight > 800 ? 1 : 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: StatefulBuilder(
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
                              'F O O D',
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
                                double? foodAmount = showDetails
                                    ? double.tryParse(amountController.text)
                                    : null;
                                String userId = ref.read(userIdProvider)!;

                                if (selectedFoodType.isNotEmpty) {
                                  if (petIds != null && petIds.isNotEmpty) {
                                    for (String id in petIds) {
                                      _saveFoodEvent(
                                        ref,
                                        id,
                                        eventId,
                                        userId,
                                        selectedFoodType,
                                        foodAmount,
                                        selectedDateTime,
                                        name: nameController.text.isNotEmpty
                                            ? nameController.text
                                            : null,
                                        time: selectedTime,
                                        satisfactionLevel: satisfactionLevel,
                                      );
                                    }
                                  } else if (petId != null) {
                                    _saveFoodEvent(
                                      ref,
                                      petId,
                                      eventId,
                                      userId,
                                      selectedFoodType,
                                      foodAmount,
                                      selectedDateTime,
                                      name: nameController.text.isNotEmpty
                                          ? nameController.text
                                          : null,
                                      time: selectedTime,
                                      satisfactionLevel: satisfactionLevel,
                                    );
                                  }
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8, bottom: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  buildIconForEvent(
                                      assetPath:
                                          'assets/images/food/food_wet.png',
                                      type: 'Wet',
                                      selectedType: selectedFoodType,
                                      onTap: (String type) {
                                        setState(() {
                                          selectedFoodType = type;
                                        });
                                      },
                                      context: context,
                                      activeColor: Colors.blue,
                                      iconSize: 60,
                                      fontSize: 13),
                                  buildIconForEvent(
                                      assetPath:
                                          'assets/images/food/food_dry.png',
                                      type: 'Dry',
                                      selectedType: selectedFoodType,
                                      onTap: (String type) {
                                        setState(() {
                                          selectedFoodType = type;
                                        });
                                      },
                                      context: context,
                                      activeColor: Colors.orange,
                                      iconSize: 60,
                                      fontSize: 13,
                                      paddingTop: 15),
                                  buildIconForEvent(
                                    assetPath:
                                        'assets/images/food/food_other.png',
                                    type: 'Other',
                                    selectedType: selectedFoodType,
                                    onTap: (String type) {
                                      setState(() {
                                        selectedFoodType = type;
                                      });
                                    },
                                    context: context,
                                    activeColor: Colors.red,
                                    iconSize: 60,
                                    fontSize: 13,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: showDetails
                                    ? const EdgeInsets.only(top: 1, bottom: 5)
                                    : const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                child: showDetails
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.more_horiz,
                                          color: Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.6),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                      )
                                    : SizedBox(
                                        width: 125,
                                        height: 25,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              showDetails = !showDetails;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .primaryColorDark,
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
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontWeight: FontWeight.bold,
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
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 4, bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 5),
                                  child: Text(
                                    'Satisfaction Level',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 11),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: List.generate(3, (index) {
                                    int level = index + 1;
                                    Color levelColor;
                                    switch (level) {
                                      case 1:
                                        levelColor = Colors.red;
                                        break;
                                      case 2:
                                        levelColor = Colors.amber;
                                        break;
                                      case 3:
                                        levelColor = Colors.green;
                                        break;
                                      default:
                                        levelColor = Colors.grey;
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          satisfactionLevel = level;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 15,
                                            bottom: 10),
                                        child: Column(
                                          children: [
                                            Icon(
                                              level == 1
                                                  ? Icons.sentiment_dissatisfied
                                                  : level == 2
                                                      ? Icons.sentiment_neutral
                                                      : Icons
                                                          .sentiment_satisfied,
                                              size: 30,
                                              color: satisfactionLevel == level
                                                  ? levelColor
                                                  : Colors.grey,
                                            ),
                                            Text(
                                              level == 1
                                                  ? 'Low'
                                                  : level == 2
                                                      ? 'Neutral'
                                                      : 'High',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (showDetails)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 4, bottom: 4),
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
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
                                            color: Theme.of(context)
                                                .primaryColorDark,
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
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: SizedBox(
                                      width: 350,
                                      height: 45,
                                      child: TextField(
                                        controller: amountController,
                                        decoration: InputDecoration(
                                          labelText: 'Amount (grams, optional)',
                                          labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontSize: 11),
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
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*')),
                                        ],
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
                                                fontSize: 13),
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
                                    padding: const EdgeInsets.only(
                                        top: 12.0, bottom: 12),
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
                                                fontSize: 13),
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
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

void _saveFoodEvent(
  WidgetRef ref,
  String petId,
  String eventId,
  String userId,
  String foodType,
  double? foodAmount,
  DateTime dateTime, {
  String? name,
  TimeOfDay? time,
  int? satisfactionLevel,
}) {
  // Tworzenie i zapisanie EventFoodSimpleModel
  final newFoodEvent = EventFoodSimpleModel(
    id: eventId,
    eventId: eventId,
    petId: petId,
    userId: userId,
    foodType: foodType,
    foodAmount: foodAmount,
    dateTime: dateTime,
    name: name,
    time: time,
    satisfactionLevel: satisfactionLevel,
  );
  ref.read(foodSimpleServiceProvider).addFood(newFoodEvent);

  // Tworzenie opisu do Event
  final description = [
    if (foodAmount != null) '$foodAmount grams of food',
    if (name != null && name.isNotEmpty) 'Food: $name',
    'Type: $foodType',
    if (satisfactionLevel != null)
      satisfactionLevel == 1
          ? 'Satisfaction: Low'
          : satisfactionLevel == 2
              ? 'Satisfaction: Neutral'
              : 'Satisfaction: High',
  ].join(', ');

  // Tworzenie i zapisanie Event
  final newEvent = Event(
    id: eventId,
    title: 'Food Intake',
    eventDate: dateTime,
    dateWhenEventAdded: DateTime.now(),
    userId: userId,
    petId: petId,
    description: description,
    avatarImage: foodType == 'Wet'
        ? 'assets/images/food/food_wet.png'
        : foodType == 'Dry'
            ? 'assets/images/food/food_dry.png'
            : 'assets/images/food/food_other.png',
    emoticon: '🍲',
  );
  ref.read(eventServiceProvider).addEvent(newEvent);
}
