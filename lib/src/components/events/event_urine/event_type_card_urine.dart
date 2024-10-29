import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_urine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';

// Funkcja modalu wyboru opcji Urine
void showUrineModal(BuildContext context, WidgetRef ref,
    {String? petId, List<String>? petIds}) {
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );
  String? selectedUrineType;

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
        _saveUrineEvent(
            context, ref, id, eventId, selectedUrineType, selectedDate);
      }
    } else if (petId != null) {
      _saveUrineEvent(
          context, ref, petId, eventId, selectedUrineType, selectedDate);
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
                    padding: const EdgeInsets.all(10.0),
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
                          'Confirm Urine Event',
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
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
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      onPrimary:
                                          Theme.of(context).primaryColorDark,
                                      onSurface:
                                          Theme.of(context).primaryColorDark,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                                dateController.text = DateFormat('dd-MM-yyyy')
                                    .format(selectedDate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
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
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.surface
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          type['emoji'],
                                          style: const TextStyle(fontSize: 35),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          type['description'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          );
        },
      );
    },
  );
}

// Funkcja pomocnicza do zapisywania eventu Urine
void _saveUrineEvent(BuildContext context, WidgetRef ref, String petId,
    String eventId, String? selectedUrineType, DateTime selectedDate) {
  EventUrineModel newUrine = EventUrineModel(
    id: generateUniqueId(),
    eventId: eventId,
    petId: petId,
    color: selectedUrineType ?? 'Default',
    description: selectedUrineType ?? 'Urine event',
    dateTime: selectedDate,
  );
  ref.read(eventUrineServiceProvider).addUrineEvent(newUrine, petId);

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
