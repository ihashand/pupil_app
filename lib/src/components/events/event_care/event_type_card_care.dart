import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_care_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_care_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

void showCareOptions(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  bool showDetails = false;
  String? selectedCareOption;
  final TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );
  TextEditingController otherCareController = TextEditingController();

  final List<Map<String, dynamic>> careOptions = [
    {'icon': '🛁', 'description': 'Bathing'},
    {'icon': '✂️', 'description': 'Nail Trimming'},
    {'icon': '🧼', 'description': 'Brushing'},
    {'icon': '👀', 'description': 'Eye Cleaning'},
    {'icon': '👂', 'description': 'Ear Cleaning'},
    {'icon': '🧴', 'description': 'Cream Application'},
    {'icon': '🪲', 'description': 'Tick Check'},
    {'icon': '🐜', 'description': 'Flea Check'},
    {'icon': '🪥', 'description': 'Teeth Brushing'},
    {'icon': '👣', 'description': 'Paw Care'},
    {'icon': '🦷', 'description': 'Dental Check'},
    {'icon': '✂️', 'description': 'Trimming Hair Around Eyes'},
    {'icon': '🔍', 'description': 'Skin Check'},
    {'icon': '💆‍♂️', 'description': 'Relaxation Massage'},
    {'icon': '👃', 'description': 'Nose Health Check'},
    {'icon': '👁️', 'description': 'Eye Drops'},
    {'icon': '🧴', 'description': 'Moisturizing Paw Pads'},
    {'icon': '❓', 'description': 'Other'},
  ];

  void recordCareEvent() {
    String eventId = generateUniqueId();
    String careDescription = selectedCareOption == "Other"
        ? otherCareController.text
        : selectedCareOption ?? 'Care';
    String emoji = careOptions.firstWhere(
      (option) => option['description'] == selectedCareOption,
      orElse: () => {'icon': ''},
    )['icon'] as String;

    if (petIds != null && petIds.isNotEmpty) {
      for (String id in petIds) {
        _saveCareEvent(context, ref, id, eventId, careDescription, emoji,
            selectedDate, selectedTime);
      }
    } else if (petId != null) {
      _saveCareEvent(context, ref, petId, eventId, careDescription, emoji,
          selectedDate, selectedTime);
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final double screenHeight = MediaQuery.of(context).size.height;
          double initialSize = screenHeight > 800 ? 0.3 : 0.4;
          double detailsSize = screenHeight > 800 ? 0.55 : 0.75;

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: showDetails ? detailsSize : initialSize,
            minChildSize: initialSize,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nagłówek
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: Theme.of(context).primaryColorDark),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              'C A R E',
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
                                if (selectedCareOption != null) {
                                  recordCareEvent();
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Pierwszy kontener z wyborem Care i przyciskiem "More Details"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: careOptions.map((option) {
                                  bool isSelected = selectedCareOption ==
                                      option['description'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCareOption =
                                            option['description'];
                                        if (selectedCareOption == "Other") {
                                          otherCareController.clear();
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: isSelected
                                                ? Colors.blue
                                                : Colors.transparent,
                                            child: Text(
                                              option['icon'],
                                              style:
                                                  const TextStyle(fontSize: 30),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            option['description'],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 15),
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
                    // Drugi kontener z wyborem daty, godziny i przyciskiem "ZAPISZ"
                    if (showDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              if (selectedCareOption == "Other") ...[
                                TextField(
                                  controller: otherCareController,
                                  decoration: InputDecoration(
                                    labelText: "Enter Care Description",
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
                                ),
                                const SizedBox(height: 10),
                              ],
                              GestureDetector(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                      dateController.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(selectedDate);
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Date',
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
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  final pickedTime = await showStyledTimePicker(
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
                                    selectedTime != null
                                        ? selectedTime!.format(context)
                                        : 'Select Time',
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

// Funkcja pomocnicza do zapisywania eventu Care
void _saveCareEvent(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String eventId,
    String careDescription,
    String emoji,
    DateTime selectedDate,
    TimeOfDay? time) {
  EventCareModel newCare = EventCareModel(
    id: generateUniqueId(),
    eventId: eventId,
    petId: petId,
    careType: careDescription,
    emoji: emoji,
    description: careDescription,
    dateTime: selectedDate,
    time: time,
  );

  ref.read(eventCareServiceProvider).addCare(newCare);

  Event newEvent = Event(
    id: eventId,
    title: 'Care',
    eventDate: selectedDate,
    dateWhenEventAdded: DateTime.now(),
    userId: FirebaseAuth.instance.currentUser!.uid,
    petId: petId,
    description: careDescription,
    avatarImage: 'assets/images/dog_avatar_014.png',
    emoticon: emoji,
    careId: newCare.id,
  );

  ref.read(eventServiceProvider).addEvent(newEvent, petId);
}

// Główny widget eventTypeCardCare, który wywołuje showCareOptions
Widget eventTypeCardCare(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'C A R E',
    'assets/images/events_type_cards_no_background/wanna.png',
    () {
      showCareOptions(context, ref, petId: petId, petIds: petIds);
    },
  );
}
