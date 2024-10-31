import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_urine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';

void showUrineModal(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  bool showDetails = false;
  String? selectedUrineType;

  final TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );

  final List<Map<String, dynamic>> urineTypes = [
    {'emoji': '🟦', 'color': Colors.blue, 'description': 'Over-hydrated'},
    {'emoji': '🟨', 'color': Colors.yellow[100], 'description': 'Normal'},
    {'emoji': '🟧', 'color': Colors.yellow, 'description': 'Dehydrated'},
    {'emoji': '🟥', 'color': Colors.red, 'description': 'UTI'},
    {'emoji': '🟩', 'color': Colors.green, 'description': 'Kidneys'},
    {'emoji': '🟫', 'color': Colors.brown, 'description': 'Bleeding'},
  ];

  void recordUrineEvent() {
    String eventId = generateUniqueId();
    if (petIds != null && petIds.isNotEmpty) {
      for (String id in petIds) {
        _saveUrineEvent(context, ref, id, eventId, selectedUrineType,
            selectedDate, selectedTime);
      }
    } else if (petId != null) {
      _saveUrineEvent(context, ref, petId, eventId, selectedUrineType,
          selectedDate, selectedTime);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'U R I N E',
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
                            recordUrineEvent();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Kontener z przyciskiem „More”
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 5),
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Padding(
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
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                      ),
                    ),
                  ),
                  // Drugi kontener z wyborem typu „Urine” (po kliknięciu „More”)
                  if (showDetails)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: urineTypes.map((type) {
                              bool isSelected =
                                  selectedUrineType == type['description'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedUrineType = type['description'];
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
                                            ? type['color'] as Color
                                            : Colors.transparent,
                                        child: Text(
                                          type['emoji'],
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        type['description'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  // Trzeci kontener z wyborem daty i godziny
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
                            // Wybór daty
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
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('dd-MM-yyyy').format(selectedDate),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Wybór godziny
                            GestureDetector(
                              onTap: () async {
                                final pickedTime = await showStyledTimePicker(
                                  context: context,
                                  initialTime: selectedTime ?? TimeOfDay.now(),
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
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColorDark,
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
            ),
          );
        },
      );
    },
  );
}

// Funkcja pomocnicza do zapisywania eventu Urine
void _saveUrineEvent(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String eventId,
    String? selectedUrineType,
    DateTime selectedDate,
    TimeOfDay? time) {
  EventUrineModel newUrine = EventUrineModel(
    id: generateUniqueId(),
    eventId: eventId,
    petId: petId,
    color: selectedUrineType ?? 'Default',
    description: selectedUrineType ?? 'Urine event',
    dateTime: selectedDate,
    time: time,
    userId: ref.read(userIdProvider)!,
  );

  ref.read(eventUrineServiceProvider).addUrineEvent(newUrine);

  Event newEvent = Event(
    id: eventId,
    title: 'Urine',
    eventDate: selectedDate,
    dateWhenEventAdded: DateTime.now(),
    userId: FirebaseAuth.instance.currentUser!.uid,
    petId: petId,
    description: selectedUrineType ?? 'Urine event',
    avatarImage: 'assets/images/dog_avatar_014.png',
    emoticon: '💦',
    urineId: newUrine.id,
  );

  ref.read(eventServiceProvider).addEvent(newEvent, petId);
}

// Główny widget eventTypeCardUrine
Widget eventTypeCardUrine(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  return eventTypeCard(
    context,
    'U R I N E',
    'assets/images/events_type_cards_no_background/piee.png',
    () {
      showUrineModal(context, ref, petId: petId, petIds: petIds);
    },
  );
}
