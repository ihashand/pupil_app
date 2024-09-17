import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_vacine_provider.dart';
import 'package:intl/intl.dart';

Widget eventTypeCardVaccines(
    BuildContext context, WidgetRef ref, String petId) {
  String? selectedVaccineType;
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );

  final List<Map<String, dynamic>> vaccineTypes = [
    {'icon': Icons.vaccines, 'description': 'Rabies', 'color': Colors.red},
    {'icon': Icons.science, 'description': 'Distemper', 'color': Colors.green},
    {'icon': Icons.biotech, 'description': 'Hepatitis', 'color': Colors.blue},
    {
      'icon': Icons.coronavirus,
      'description': 'Bordatella',
      'color': Colors.orange
    },
    {
      'icon': Icons.bug_report,
      'description': 'Leptospirosis',
      'color': Colors.purple
    },
  ];

  void recordVaccineEvent() {
    String eventId = generateUniqueId();
    EventVaccineModel newVaccine = EventVaccineModel(
      id: generateUniqueId(),
      eventId: eventId,
      petId: petId,
      emoticon: selectedVaccineType ?? 'Default',
      description: selectedVaccineType ?? 'Vaccine event',
      dateTime: selectedDate,
    );
    ref.read(eventVaccineServiceProvider).addVaccine(newVaccine);

    Event newEvent = Event(
      id: eventId,
      title: 'Vaccine',
      eventDate: selectedDate,
      dateWhenEventAdded: DateTime.now(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      petId: petId,
      description: selectedVaccineType ?? 'Vaccine event',
      avatarImage: 'assets/images/dog_avatar_014.png',
      emoticon: '💉',
      vaccineId: newVaccine.id,
    );
    ref.read(eventServiceProvider).addEvent(newEvent);
  }

  void showConfirmationBottomSheet(
      BuildContext context, VoidCallback onConfirm) {
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
                            'Confirm Vaccine Event',
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
                              onConfirm();
                              Navigator.of(context).pop();
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
                                  color: Theme.of(context).primaryColorDark),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorDark),
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
                                          foregroundColor: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null && picked != selectedDate) {
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
                              children: vaccineTypes.map((type) {
                                bool isSelected =
                                    type['description'] == selectedVaccineType;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedVaccineType = type['description'];
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
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
                                          child: Icon(type['icon'],
                                              size: 35, color: type['color']),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            type['description'],
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .primaryColorDark),
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

  return eventTypeCard(
    context,
    'V A C C I N E S',
    'assets/images/events_type_cards_no_background/syringe.png',
    () {
      showConfirmationBottomSheet(context, recordVaccineEvent);
    },
  );
}
